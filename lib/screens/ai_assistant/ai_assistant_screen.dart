import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../services/deepseek_service.dart';
import '../../providers/weather_provider.dart';
import '../../providers/city_provider.dart';
import '../../models/weather_models.dart';

/// 天气助手屏幕
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

/// 天气助手屏幕状态
class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  /// 消息输入控制器
  final _messageController = TextEditingController();
  
  /// 滚动控制器
  final _scrollController = ScrollController();
  
  /// 焦点节点
  final _focusNode = FocusNode();
  
  /// 是否正在输入
  bool _isTyping = false;
  
  /// 当前响应内容
  String _currentResponse = '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    _messageController.clear();
    _focusNode.unfocus();

    ref.read(chatProvider.notifier).addUserMessage(message);

    setState(() {
      _isTyping = true;
      _currentResponse = '';
    });

    _scrollToBottom();

    final weatherState = ref.read(weatherProvider);
    final defaultCity = ref.read(defaultCityProvider);
    final weatherContext = _buildWeatherContext(weatherState, defaultCity);

    final service = ref.read(deepSeekServiceProvider);
    final history = ref
        .read(chatProvider)
        .messages
        .where((m) => m.role != 'system')
        .toList();

    try {
      final response = service.chatStream(
        userMessage: message,
        history: history,
        weatherContext: weatherContext,
      );

      await for (final chunk in response) {
        setState(() {
          _currentResponse += chunk;
        });
        _scrollToBottom();
      }

      ref.read(chatProvider.notifier).addAssistantMessage(_currentResponse);
    } catch (e) {
      ref.read(chatProvider.notifier).addAssistantMessage('抱歉，发生了错误。请稍后再试。');
    } finally {
      setState(() {
        _isTyping = false;
        _currentResponse = '';
      });
    }
  }

  /// 构建天气上下文信息
  /// 
  /// [weatherState] 天气状态
  /// [location] 位置信息
  /// 
  /// 返回天气上下文字符串
  String _buildWeatherContext(WeatherState weatherState, Location? location) {
    final weather = weatherState.weatherData;
    if (weather == null || location == null) return '';

    return '''
位置: ${location.name}, ${location.adm1}
当前温度: ${weather.current.temp}°C
体感温度: ${weather.current.feelsLike}°C
天气状况: ${weather.current.text}
湿度: ${weather.current.humidity}%
风速: ${weather.current.windSpeed} km/h
风向: ${weather.current.windDir}
今日最高温: ${weather.daily.first.tempMax}°C
今日最低温: ${weather.daily.first.tempMin}°C
''';
  }

  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatSession = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('天气助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(chatProvider.notifier).clearHistory();
            },
            tooltip: '清空对话',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.invertedStylus,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: chatSession.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildChatList(chatSession),
                ),
              ),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              '你好，我是轻氧天气助手',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              '我可以帮你解答天气相关问题，提供穿衣建议、出行提醒等',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAction('今天适合户外运动吗？'),
                _buildQuickAction('明天需要带伞吗？'),
                _buildQuickAction('今天穿什么合适？'),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  /// 构建快速操作按钮
  /// 
  /// [text] 按钮文本
  /// 
  /// 返回ActionChip实例
  Widget _buildQuickAction(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 1,
      ),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }

  /// 构建聊天列表
  /// 
  /// [session] 聊天会话
  /// 
  /// 返回ListView.builder实例
  Widget _buildChatList(ChatSession session) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          session.messages.length + (_currentResponse.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < session.messages.length) {
          final message = session.messages[index];
          return _ChatBubble(
            message: message.content,
            isUser: message.role == 'user',
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
        } else {
          return _ChatBubble(message: _currentResponse, isUser: false);
        }
      },
    );
  }

  /// 构建输入指示器
  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 18,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '正在思考...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '输入消息...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.send),
            onPressed: _isTyping ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// 聊天气泡组件
class _ChatBubble extends StatelessWidget {
  /// 消息内容
  final String message;
  
  /// 是否是用户消息
  final bool isUser;

  /// 创建聊天气泡实例
  /// 
  /// [message] 消息内容
  /// [isUser] 是否是用户消息
  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
