import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../app_localizations.dart';
import '../../services/deepseek_service.dart';
import '../../providers/weather_provider.dart';
import '../../providers/city_provider.dart';
import '../../models/weather_models.dart';
import '../../core/theme/app_theme.dart';

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
      ref
          .read(chatProvider.notifier)
          .addAssistantMessage(context.tr('抱歉，发生了错误。请稍后再试。'));
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

    // 构建完整的天气数据JSON
    final weatherData = {
      'location': {
        'name': location.name,
        'adm1': location.adm1,
        'adm2': location.adm2,
        'country': location.country,
        'lat': location.lat,
        'lon': location.lon
      },
      'current': {
        'temp': weather.current.temp,
        'feelsLike': weather.current.feelsLike,
        'text': weather.current.text,
        'humidity': weather.current.humidity,
        'windSpeed': weather.current.windSpeed,
        'windDir': weather.current.windDir,
        'windScale': weather.current.windScale,
        'precip': weather.current.precip,
        'pressure': weather.current.pressure,
        'vis': weather.current.vis,
        'cloud': weather.current.cloud,
        'obsTime': weather.current.obsTime
      },
      'daily': weather.daily.map((day) => {
        'fxDate': day.fxDate,
        'tempMax': day.tempMax,
        'tempMin': day.tempMin,
        'textDay': day.textDay,
        'textNight': day.textNight,
        'windDirDay': day.windDirDay,
        'windScaleDay': day.windScaleDay,
        'windDirNight': day.windDirNight,
        'windScaleNight': day.windScaleNight,
        'humidity': day.humidity,
        'precip': day.precip,
        'uvIndex': day.uvIndex
      }).toList(),
      'hourly': weather.hourly.take(24).map((hour) => {
        'fxTime': hour.fxTime,
        'temp': hour.temp,
        'text': hour.text,
        'windDir': hour.windDir,
        'windScale': hour.windScale,
        'pop': hour.pop,
        'precip': hour.precip
      }).toList(),
      'alerts': weather.alerts.map((alert) => {
        'title': alert.title,
        'level': alert.level,
        'typeName': alert.typeName,
        'text': alert.text,
        'pubTime': alert.pubTime
      }).toList(),
      'airQuality': weatherState.airQuality != null ? {
        'aqi': weatherState.airQuality!.aqi,
        'level': weatherState.airQuality!.level,
        'category': weatherState.airQuality!.category,
        'pm2p5': weatherState.airQuality!.pm2p5,
        'pm10': weatherState.airQuality!.pm10,
        'no2': weatherState.airQuality!.no2,
        'so2': weatherState.airQuality!.so2,
        'co': weatherState.airQuality!.co,
        'o3': weatherState.airQuality!.o3
      } : null,
      'indices': weatherState.weatherIndices?.map((index) => {
        'type': index.type,
        'name': index.name,
        'level': index.level,
        'category': index.category,
        'text': index.text,
      }).toList(),
      'lastUpdated': weather.lastUpdated.toIso8601String()
    };

    // 将天气数据转换为字符串表示
    final weatherJson = weatherData.toString();

    // 构建系统提示，告诉AI如何使用这些数据
    return '''
你是一个智能天气助手，需要根据以下天气数据回答用户的问题。请使用提供的天气数据提供准确的天气信息。

天气数据: $weatherJson

请根据以上数据回答用户的问题，确保信息准确且符合实际天气状况。
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
        title: Text(context.tr('天气助手')),
        actions: [
          if (chatSession.messages.isNotEmpty)
            IconButton.filledTonal(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(chatProvider.notifier).clearHistory();
              },
              tooltip: context.tr('清空对话'),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 900 : double.infinity,
                  ),
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
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                context.tr('你好，我是轻氧天气助手'),
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                context.tr('我可以帮你解答天气相关问题，提供穿衣建议、出行提醒等'),
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
                  _buildQuickAction(context.tr('今天适合户外运动吗？')),
                  _buildQuickAction(context.tr('明天需要带伞吗？')),
                  _buildQuickAction(context.tr('今天穿什么合适？')),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
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
      label: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: context.uiTokens.cardBorder,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.uiTokens.cardBorder),
      ),
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
            context.tr('正在思考...'),
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
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.uiTokens.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: context.tr('输入消息...'),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: context.uiTokens.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: context.uiTokens.selectedBorder),
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

  String _formatAssistantMessage(String input) {
    var text = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Keep numbered items readable even when model returns one long line.
    text = text.replaceAll(RegExp(r'(?<!\n)(\d+[.、])\s*'), '\n\$1 ');

    // Break long paragraphs at sentence punctuation for readability.
    text = text.replaceAll(RegExp(r'(?<=[。！？；.!?;])(?=[^\n])'), '\n');

    // Avoid too many blank lines after formatting.
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = isUser ? message : _formatAssistantMessage(message);
    final tokens = context.uiTokens;
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
              ? tokens.selectedBackground
              : tokens.cardBackground,
          border: Border.all(
            color: isUser ? tokens.selectedBorder : tokens.cardBorder,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          displayMessage,
          softWrap: true,
          overflow: TextOverflow.visible,
          textWidthBasis: TextWidthBasis.parent,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser
                ? tokens.selectedForeground
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
