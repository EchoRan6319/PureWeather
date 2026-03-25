import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_localizations.dart';
import '../core/constants/api_config.dart';

class DeepSeekService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  DeepSeekService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 120),
                headers: const {
                  'Content-Type': 'application/json',
                },
              ),
            ),
        _apiKey = apiKey ?? ApiConfig.deepseekApiKey,
        _baseUrl = baseUrl ?? ApiConfig.deepseekBaseUrl;

  String _buildSystemPrompt(String? weatherContext) {
    final isEnglish = AppLocalizations.isEnglishCurrentLocale;
    final hasWeather = weatherContext != null && weatherContext.trim().isNotEmpty;

    final dataSection = hasWeather
        ? (isEnglish
              ? '[Current Weather Data]\n$weatherContext'
              : '【当前天气信息】\n$weatherContext')
        : (isEnglish
              ? '(No weather data available. Remind the user to add a city and refresh weather first.)'
              : '（暂无天气数据，请先提醒用户添加城市并刷新天气）');

    if (isEnglish) {
      return '''You are "PureWeather Assistant". Provide accurate, readable, and actionable advice based on weather data.

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

    return '''你是“轻氧天气助手”。请基于天气数据给出准确、易读、可执行的建议。

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

  String _sanitizeAiResponse(String input) {
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

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  Stream<String> chatStream({
    required String userMessage,
    required List<ChatMessage> history,
    String? weatherContext,
  }) async* {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': _buildSystemPrompt(weatherContext),
      },
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await _dio.post<ResponseBody>(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'deepseek-chat',
          'messages': messages,
          'stream': true,
          'temperature': 0.7,
          'max_tokens': 2048,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        yield AppLocalizations.tr('抱歉，无法连接到AI服务。');
        return;
      }

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        final lines = text.split('\n');

        for (final line in lines) {
          if (!line.startsWith('data: ')) {
            continue;
          }

          final data = line.substring(6);
          if (data == '[DONE]') {
            continue;
          }

          try {
            final json = jsonDecode(data);
            final content = json['choices']?[0]?['delta']?['content'];
            if (content != null) {
              yield _sanitizeAiResponse(content);
            }
          } catch (_) {
            continue;
          }
        }
      }
    } catch (e) {
      yield AppLocalizations.tr('抱歉，发生了错误：{error}', args: {'error': e.toString()});
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
}

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }
}

final deepSeekServiceProvider = Provider<DeepSeekService>((ref) {
  return DeepSeekService();
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
      messages: [...state.messages, ChatMessage(role: 'user', content: content)],
    );
  }

  void addAssistantMessage(String content) {
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: 'assistant', content: content)],
    );
  }

  void clearHistory() {
    state = ChatSession();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatSession>((ref) {
  return ChatNotifier();
});
