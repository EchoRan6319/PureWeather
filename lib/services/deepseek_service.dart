import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_config.dart';

class DeepSeekService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  DeepSeekService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
  })  : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
          headers: {
            'Content-Type': 'application/json',
          },
        )),
        _apiKey = apiKey ?? ApiConfig.deepseekApiKey,
        _baseUrl = baseUrl ?? ApiConfig.deepseekBaseUrl;

  Stream<String> chatStream({
    required String userMessage,
    required List<ChatMessage> history,
    String? weatherContext,
  }) async* {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': '''你是一个专业的天气助手，名叫"轻氧天气助手"。你的任务是：

1. **天气信息解读**：用通俗易懂的语言解释当前天气状况
2. **穿衣建议**：根据温度、湿度、风速等给出穿衣建议
3. **出行提醒**：提醒用户是否需要带伞、防晒、添衣等
4. **健康提醒**：根据天气状况给出健康建议（如空气质量、过敏原等）
5. **天气科普**：解释天气现象背后的原理

**回答要求**：
- 用简洁、友好的语气，适当使用表情符号
- **禁止使用任何Markdown格式符号**（如**、*、##等），只使用纯文本
- 回答要实用且易于理解
- 主动提供相关建议，不要只回答表面问题
- 如果用户问的问题与天气无关，礼貌地引导回到天气话题

**当前天气数据解读指南**：
- temp（温度）：实际气温
- feelsLike（体感温度）：人体感受到的温度，受湿度和风速影响
- humidity（湿度）：空气湿度，影响体感舒适度
- windSpeed（风速）：风速大小，影响体感温度
- text（天气状况）：天气现象文字描述
- tempMax/tempMin：当日最高/最低温度

${weatherContext != null ? '【当前天气信息】\n$weatherContext' : '（暂无天气数据，请提醒用户先添加城市）'}''',
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
        yield '抱歉，无法连接到AI服务。';
        return;
      }

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        final lines = text.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) {
                yield content;
              }
            } catch (_) {
              continue;
            }
          }
        }
      }
    } catch (e) {
      yield '抱歉，发生了错误：${e.toString()}';
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
    return buffer.toString();
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
