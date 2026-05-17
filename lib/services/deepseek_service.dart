import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_localizations.dart';
import '../providers/settings_provider.dart';

class DeepSeekService {
  final Dio _dio;
  final AiProviderType _providerType;
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  DeepSeekService({
    Dio? dio,
    AiProviderType providerType = AiProviderType.openAiCompatible,
    String apiKey = '',
    String baseUrl = 'https://api.openai.com/v1',
    String model = '',
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 60),
               receiveTimeout: const Duration(seconds: 120),
               headers: const {'Content-Type': 'application/json'},
             ),
           ),
       _providerType = providerType,
       _apiKey = apiKey,
       _baseUrl = baseUrl,
       _model = model;

  bool get isConfigured =>
      _apiKey.trim().isNotEmpty &&
      _baseUrl.trim().isNotEmpty &&
      _model.trim().isNotEmpty;

  String get _normalizedBaseUrl =>
      _baseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  String _buildSystemPrompt(String? weatherContext) {
    final isEnglish = AppLocalizations.isEnglishCurrentLocale;
    final hasWeather =
        weatherContext != null && weatherContext.trim().isNotEmpty;

    final dataSection = hasWeather
        ? (isEnglish
              ? '[Current Weather Data]\n$weatherContext'
              : '【当前天气信息】\n$weatherContext')
        : (isEnglish
              ? '(No weather data available. Remind the user to add a city and refresh weather first.)'
              : '（暂无天气数据，请先提醒用户添加城市并刷新天气）');

    if (isEnglish) {
      return '''You are "Aurora Weather Assistant". Provide accurate, readable, and actionable advice based on weather data.

Output plain text only. Do not use Markdown control markers (such as headings, bold, code blocks, or link wrappers).

Use this fixed structure:
Conclusion: one sentence with the direct judgment first.
Reasons: up to 3 lines, one point per line.
Suggestions: actionable steps, prioritized by "now / today / tomorrow".
Extra: clearly mention alerts, temperature differences, precipitation, or air-quality risks if present.

Style requirements:
1. Use concise short sentences.
2. Prefer explicit time points and thresholds (temperature, precipitation chance, wind level, etc.).
3. If the user question is incomplete, give the best available answer first, then suggest one follow-up question.

$dataSection''';
    }

    return '''你是“极光天气助手”。请基于天气数据给出准确、易读、可执行的建议。

只输出纯文本，禁止使用 Markdown 控制标记（例如：#标题、**加粗**、反引号代码块、链接包装符号等），但保留正常中文标点和常用符号。

请按固定结构回答：
结论：一句话先给判断。
原因：最多 3 条，每条一行。
建议：给出可执行动作，优先按“现在/今天/明天”组织。
补充：如有预警、温差、降水、空气质量风险，明确提醒。

表达要求：
1. 使用简洁中文短句，避免大段文字。
2. 优先给出时间点和阈值（如气温、降水概率、风力等级）。
3. 用户问题不完整时，先给最佳可用答案，再补一句可追问项。

$dataSection''';
  }

  String _sanitizeAiResponse(String input, {bool trim = true}) {
    var text = input;

    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    text = text.replaceAll('**', '');
    text = text.replaceAll('__', '');
    text = text.replaceAll('~~', '');
    text = text.replaceAll('`', '');

    text = text.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s{0,3}>\s?', multiLine: true), '');

    text = text.replaceAll(RegExp(r'!\[([^\]]*)\]\(([^)]*)\)'), r'$1');
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\(([^)]*)\)'), r'$1');

    // Remove hidden control characters that may be rendered as garbled symbols.
    text = text.replaceAll(
      RegExp(r'[\u0000-\u0008\u000B-\u001F\u007F\u200B-\u200D\uFEFF]'),
      '',
    );
    text = text.replaceAll('§', '');

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return trim ? text.trim() : text;
  }

  Stream<String> chatStream({
    required String userMessage,
    required List<ChatMessage> history,
    String? weatherContext,
  }) async* {
    if (!isConfigured) {
      yield AppLocalizations.tr('请先在设置 > AI 设置中填写 API Key、接口地址和模型名称。');
      return;
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _buildSystemPrompt(weatherContext)},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final stream = switch (_providerType) {
        AiProviderType.anthropic => _anthropicChatStream(messages),
        AiProviderType.openAiCompatible => _openAiCompatibleChatStream(
          messages,
        ),
      };

      await for (final chunk in stream) {
        yield chunk;
      }
    } catch (e) {
      yield AppLocalizations.tr(
        '抱歉，发生了错误：{error}',
        args: {'error': e.toString()},
      );
    }
  }

  Stream<String> _openAiCompatibleChatStream(
    List<Map<String, String>> messages,
  ) async* {
    final response = await _dio.post<ResponseBody>(
      '$_normalizedBaseUrl/chat/completions',
      data: {
        'model': _model.trim(),
        'messages': messages,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 2048,
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${_apiKey.trim()}'},
        responseType: ResponseType.stream,
      ),
    );

    yield* _parseSseStream(response.data, (parsed) {
      final content = parsed['choices']?[0]?['delta']?['content'];
      return content is String ? content : null;
    });
  }

  Stream<String> _anthropicChatStream(
    List<Map<String, String>> messages,
  ) async* {
    final systemPrompt = messages
        .where((m) => m['role'] == 'system')
        .map((m) => m['content'] ?? '')
        .where((content) => content.isNotEmpty)
        .join('\n\n');
    final chatMessages = messages
        .where((m) => m['role'] == 'user' || m['role'] == 'assistant')
        .map((m) => {'role': m['role'], 'content': m['content']})
        .toList();

    final response = await _dio.post<ResponseBody>(
      '$_normalizedBaseUrl/messages',
      data: {
        'model': _model.trim(),
        'system': systemPrompt,
        'messages': chatMessages,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 2048,
      },
      options: Options(
        headers: {
          'x-api-key': _apiKey.trim(),
          'anthropic-version': '2023-06-01',
        },
        responseType: ResponseType.stream,
      ),
    );

    yield* _parseSseStream(response.data, (parsed) {
      if (parsed['type'] == 'content_block_delta') {
        final text = parsed['delta']?['text'];
        return text is String ? text : null;
      }
      if (parsed['type'] == 'error') {
        final message = parsed['error']?['message'];
        return message is String ? message : null;
      }
      return null;
    });
  }

  Stream<String> _parseSseStream(
    ResponseBody? responseBody,
    String? Function(dynamic parsed) extractContent,
  ) async* {
    final stream = responseBody?.stream;
    if (stream == null) {
      yield AppLocalizations.tr('抱歉，无法连接到AI服务。');
      return;
    }

    final lineBuffer = StringBuffer();

    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      lineBuffer.write(text);

      final buffered = lineBuffer.toString();
      final lines = buffered.split('\n');

      // 最后一段可能不完整（TCP 分包），保留在 buffer 中
      lineBuffer.clear();
      lineBuffer.write(lines.last);

      // 除最后一段外，都是完整行
      for (var i = 0; i < lines.length - 1; i++) {
        final content = _parseSseDataLine(lines[i], extractContent);
        if (content != null) {
          yield _sanitizeAiResponse(content, trim: false);
        }
      }
    }

    final remaining = lineBuffer.toString();
    final content = _parseSseDataLine(remaining, extractContent);
    if (content != null) {
      yield _sanitizeAiResponse(content, trim: false);
    }
  }

  String? _parseSseDataLine(
    String rawLine,
    String? Function(dynamic parsed) extractContent,
  ) {
    final line = rawLine.trim();
    if (!line.startsWith('data: ')) return null;

    final data = line.substring(6);
    if (data == '[DONE]') return null;

    try {
      return extractContent(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  Future<String> chat({
    required String userMessage,
    required List<ChatMessage> history,
    String? weatherContext,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in chatStream(
      userMessage: userMessage,
      history: history,
      weatherContext: weatherContext,
    )) {
      buffer.write(chunk);
    }
    return _sanitizeAiResponse(buffer.toString());
  }

  String sanitizeResponse(String input) {
    return _sanitizeAiResponse(input);
  }
}

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(role: json['role'], content: json['content']);
  }
}

final deepSeekServiceProvider = Provider<DeepSeekService>((ref) {
  final settings = ref.watch(settingsProvider);
  return DeepSeekService(
    providerType: settings.aiProviderType,
    apiKey: settings.aiApiKey,
    baseUrl: settings.aiBaseUrl,
    model: settings.aiModel,
  );
});

class ChatSession {
  final List<ChatMessage> messages;

  ChatSession({List<ChatMessage>? messages}) : messages = messages ?? [];

  ChatSession copyWith({List<ChatMessage>? messages}) {
    return ChatSession(messages: messages ?? this.messages);
  }
}

class ChatNotifier extends StateNotifier<ChatSession> {
  ChatNotifier() : super(ChatSession());

  void addUserMessage(String content) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: 'user', content: content),
      ],
    );
  }

  void addAssistantMessage(String content) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(role: 'assistant', content: content),
      ],
    );
  }

  void clearHistory() {
    state = ChatSession();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatSession>((ref) {
  return ChatNotifier();
});
