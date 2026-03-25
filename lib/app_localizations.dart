import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Locale _currentLocale = const Locale('zh', 'CN');

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(result != null, 'No AppLocalizations found in context.');
    return result!;
  }

  static void updateCurrentLocale(Locale locale) {
    _currentLocale = locale;
  }

  static String tr(
    String zhText, {
    Map<String, Object?> args = const {},
    Locale? locale,
  }) {
    final targetLocale = locale ?? _currentLocale;
    final useEnglish = _isEnglish(targetLocale);
    final template = useEnglish ? (_enUs[zhText] ?? zhText) : zhText;
    return _format(template, args);
  }

  String translate(String zhText, {Map<String, Object?> args = const {}}) {
    return tr(zhText, args: args, locale: locale);
  }

  static bool _isEnglish(Locale locale) {
    return locale.languageCode.toLowerCase() == 'en';
  }

  static bool get isEnglishCurrentLocale => _isEnglish(_currentLocale);

  static String _format(String template, Map<String, Object?> args) {
    var formatted = template;
    args.forEach((key, value) {
      formatted = formatted.replaceAll('{$key}', '${value ?? ''}');
    });
    return formatted;
  }

  static const Map<String, String> _enUs = <String, String>{
    '轻氧天气': 'PureWeather',
    '设置': 'Settings',
    '天气': 'Weather',
    '天气助手': 'Weather Assistant',
    '天气卡片排序': 'Weather Card Order',
    '恢复默认': 'Reset',
    '按住并拖动卡片右侧的图标，调整它们在天气详情页中的显示顺序。':
        'Press and drag the icon on the right of a card to change the display order on the weather details page.',
    '完成': 'Done',
    '个性化': 'Personalization',
    '主题模式': 'Theme Mode',
    'A屏黑主题': 'AMOLED Black Theme',
    '纯黑背景，更适合AMOLED屏幕': 'Pure black background, better for AMOLED displays.',
    '主题颜色': 'Theme Color',
    '跟随壁纸': 'Follow Wallpaper',
    '自定义颜色': 'Custom Color',
    '动态取色': 'Dynamic Color',
    '根据壁纸自动生成主题色': 'Generate theme colors from wallpaper automatically.',
    '跟随系统': 'Follow System',
    '默认跟随系统': 'Follow System (Default)',
    '自动跟随系统语言': 'Automatically follow system language',
    '简体中文': 'Simplified Chinese',
    '始终使用简体中文': 'Always use Simplified Chinese',
    '浅色模式': 'Light Mode',
    '深色模式': 'Dark Mode',
    '自动切换浅色或深色主题': 'Automatically switch between light and dark themes.',
    '使用浅色主题显示': 'Use light theme.',
    '使用深色主题显示': 'Use dark theme.',
    '选择主题颜色': 'Choose Theme Color',
    '预设颜色': 'Preset Colors',
    '壁纸取色': 'Pick From Wallpaper',
    '检测颜色: #{color}': 'Detected color: #{color}',
    '动态取色不可用': 'Dynamic color unavailable',
    '可能原因：\n• 设备系统版本低于 Android 12\n• 设备制造商禁用了动态取色\n• 系统设置中未启用 Material You':
        'Possible reasons:\n• Device version is below Android 12\n• Device manufacturer disabled dynamic color\n• Material You is not enabled in system settings',
    '十六进制颜色代码': 'Hex Color Code',
    '预览效果': 'Preview',
    '主色': 'Primary',
    '次色': 'Secondary',
    '三色': 'Tertiary',
    '应用': 'Apply',
    '24小时预报': '24-Hour Forecast',
    '显示未来24小时的天气变化趋势': 'Shows weather trends for the next 24 hours.',
    '7天预报': '7-Day Forecast',
    '显示未来7天的天气概况': 'Shows a weather overview for the next 7 days.',
    '空气质量': 'Air Quality',
    '显示当前空气质量指数和污染物信息': 'Shows current AQI and pollutant details.',
    '详细信息': 'Details',
    '显示湿度、气压、能见度等详细数据':
        'Shows detailed data such as humidity, pressure, and visibility.',
    '生活指数': 'Life Indices',
    '显示穿衣、运动、洗车等生活建议':
        'Shows daily suggestions for clothing, exercise, car wash, and more.',
    '导航': 'Navigation',
    '最高': 'High',
    '最低': 'Low',
    '体感': 'Feels Like',
    '加载天气失败': 'Failed to load weather',
    '重试': 'Retry',
    '请先添加城市': 'Please add a city first',
    '城市管理': 'City Management',
    '已切换到 {location}': 'Switched to {location}',
    '确定删除 {city} 吗？': 'Delete {city}?',
    '确定要删除 {city} 吗？': 'Are you sure you want to delete {city}?',
    '点击右上角“导航”按钮手动添加城市':
        'Tap the navigation button in the top-right corner to add a city manually.',
    '降雨预测': 'Rain Forecast',
    '湿度': 'Humidity',
    '日出': 'Sunrise',
    '能见度': 'Visibility',
    '气压': 'Pressure',
    '日落': 'Sunset',
    '删除城市': 'Delete City',
    '取消': 'Cancel',
    '删除': 'Delete',
    '搜索城市': 'Search city',
    '定位当前位置': 'Use current location',
    '添加': 'Add',
    '还没有添加城市': 'No cities added yet',
    '搜索城市或使用定位添加': 'Search for a city or use location to add one',
    '定位': 'Location',
    '默认': 'Default',
    '未知位置': 'Unknown location',
    '无法获取位置，请检查权限设置':
        'Unable to get location. Please check permission settings.',
    '已删除全部城市，定位失败。请搜索城市或检查定位权限。':
        'All cities were deleted and location failed. Please search for a city or check location permissions.',
    '请稍候': 'Please wait',
    '正在获取天气信息...': 'Fetching weather data...',
    '定位失败: {error}': 'Location failed: {error}',
    '主要污染物: {value}': 'Primary Pollutant: {value}',
    '{count}条预警': '{count} alerts',
    '发布时间: {time}': 'Published: {time}',
    '今天': 'Today',
    '昨天': 'Yesterday',
    '前天': 'The day before yesterday',
    '小时数据已过期或时间解析失败': 'Hourly data has expired or time parsing failed.',
    '暂无小时预报数据': 'No hourly forecast data available.',
    '当前位置': 'Current Location',
    '中国': 'China',
    '红色': 'Red',
    '橙色': 'Orange',
    '黄色': 'Yellow',
    '蓝色': 'Blue',
    '🔴 红色预警 - 极端天气': '🔴 Red Alert - Extreme Weather',
    '🟠 橙色预警 - 严重天气': '🟠 Orange Alert - Severe Weather',
    '🟡 黄色预警 - 较重天气': '🟡 Yellow Alert - Significant Weather',
    '🔵 蓝色预警 - 一般天气': '🔵 Blue Alert - General Weather',
    '版本 {version}': 'Version {version}',
    '关于轻氧天气': 'About PureWeather',
    '我知道了': 'Got it',
    '关于': 'About',
    '应用介绍': 'About the App',
    '轻氧天气是一款使用 Material You Design 的现代化跨平台天气应用，支持全平台。':
        'PureWeather is a modern cross-platform weather app designed with Material You.',
    '开源协议': 'Open Source License',
    '开发者': 'Developer',
    '特别鸣谢': 'Special Thanks',
    '和风天气': 'QWeather',
    '提供天气数据': 'Provides weather data',
    '彩云天气': 'Caiyun Weather',
    '提供分钟级降雨预报': 'Provides minute-level rain forecast',
    '高德地图': 'AMap',
    '提供城市搜索和定位服务': 'Provides city search and location services',
    '提供天气助手的 AI 问答功能': 'Provides AI Q&A for the weather assistant',
    '用户协议': 'User Agreement',
    '隐私政策': 'Privacy Policy',
    '生效日期：2026年2月16日\n\n轻氧天气（以下简称"我们"）非常重视您的隐私。本协议阐述了我们如何处理您的个人信息。':
        'Effective date: February 16, 2026\n\nPureWeather ("we") takes your privacy seriously. This policy explains how we handle your personal information.',
    '1. 信息收集': '1. Information Collection',
    '我们仅在您使用应用期间收集必要的信息，包括：\n• 位置信息：仅用于获取您当前位置的天气预报。您可以随时在系统中关闭该权限。\n• 天气查询历史：仅用于天气助手功能，帮助您获取更准确的天气相关回答。':
        'We only collect necessary information while you use the app, including:\n• Location information: used only to fetch weather for your current location. You can disable this permission at any time in system settings.\n• Weather query history: used only for the weather assistant to provide more accurate weather-related answers.',
    '2. 信息使用': '2. Use of Information',
    '收集的信息仅用于向您提供准确的天气预报、相关推送服务和天气助手功能。我们不会将您的个人信息出售给第三方。':
        'Collected information is only used to provide accurate weather forecasts, related push services, and weather assistant features. We do not sell your personal information to third parties.',
    '3. 数据存储': '3. Data Storage',
    '您的位置偏好设置和城市信息存储在设备本地（SharedPreferences），除非您手动清理应用数据，否则信息将保留在您的设备上。':
        'Your location preferences and city information are stored locally on your device (SharedPreferences). Data remains on your device unless you manually clear app data.',
    '4. 第三方服务': '4. Third-Party Services',
    '本应用使用以下第三方服务：\n• 和风天气（QWeather）及彩云天气：提供天气数据，您的位置坐标（经纬度）将发送至其服务器以换取天气数据。\n• 高德地图：提供城市搜索和定位服务，您的位置坐标（经纬度）将发送至其服务器以获取位置信息。\n• DeepSeek：提供天气助手的AI问答功能，您的天气查询问题将发送至其服务器以获取智能回答。':
        'This app uses the following third-party services:\n• QWeather and Caiyun Weather: provide weather data. Your location coordinates (latitude/longitude) are sent to their servers to retrieve weather data.\n• AMap: provides city search and location services. Your location coordinates are sent to its servers to retrieve location information.\n• DeepSeek: provides AI Q&A for the weather assistant. Your weather questions are sent to its servers to get responses.',
    '欢迎使用轻氧天气！请在使用前阅读以下条款。':
        'Welcome to PureWeather! Please read the following terms before use.',
    '1. 服务内容': '1. Service Content',
    '轻氧天气为您提供天气查询、极端天气预警、定时播报、城市搜索定位及天气助手等非商业服务。':
        'PureWeather provides non-commercial services including weather lookup, severe weather alerts, scheduled broadcasts, city search/location, and a weather assistant.',
    '2. 使用规范': '2. Usage Rules',
    '您不得将本应用用于任何非法目的，或以任何方式干扰应用的正常运行。在使用天气助手功能时，您应遵守相关法律法规，不得发送违法或不当内容。':
        'You must not use this app for illegal purposes or interfere with normal operation in any way. When using the weather assistant, you must comply with applicable laws and must not send illegal or inappropriate content.',
    '3. 免责声明': '3. Disclaimer',
    '• 天气数据由第三方提供，受气象、地理、网络等多种因素影响，数据的准时性、准确性可能存在偏差。本应用不承担因天气数据错误导致的任何直接或间接损失。\n• 定位服务由高德地图提供，其准确性和可用性受设备硬件和网络环境影响。\n• 天气助手功能由DeepSeek提供，其回答基于AI模型，可能存在一定的局限性和误差，仅供参考。':
        '• Weather data is provided by third parties and can be affected by meteorological, geographic, and network factors. Timeliness and accuracy may vary. This app is not liable for any direct or indirect loss caused by weather data errors.\n• Location services are provided by AMap, and their accuracy/availability depend on device hardware and network conditions.\n• The weather assistant is powered by DeepSeek. Responses are generated by AI models and may have limitations or errors. For reference only.',
    '本应用使用和风天气、彩云天气、高德地图和DeepSeek等第三方服务，您在使用本应用时即表示同意这些第三方服务的相关条款。':
        'This app uses third-party services such as QWeather, Caiyun Weather, AMap, and DeepSeek. By using this app, you agree to the relevant terms of these third-party services.',
    '5. 协议变更': '5. Agreement Updates',
    '我们保留随时修改本协议的权利，修改后的协议将在应用内公布。':
        'We reserve the right to modify this agreement at any time. Updated terms will be published in the app.',
    '刷新间隔': 'Refresh Interval',
    '自动刷新': 'Auto Refresh',
    '每 {minutes} 分钟自动更新': 'Auto-refresh every {minutes} minutes',
    '{minutes} 分钟': '{minutes} min',
    '温度单位': 'Temperature Unit',
    '语言': 'Language',
    '摄氏度': 'Celsius',
    '华氏度': 'Fahrenheit',
    '温度显示为摄氏度': 'Display temperature in Celsius',
    '温度显示为华氏度': 'Display temperature in Fahrenheit',
    '位置显示精度': 'Location Display Accuracy',
    '街道级别': 'Street Level',
    '区县级别': 'District/County Level',
    '展示区/县': 'Show district/county',
    '定位到行政区级别': 'Locate to district-level area.',
    '展示附近地标/街道': 'Show nearby landmarks/street',
    '精确定位到街道级别': 'Locate to street level.',
    '每15分钟自动更新天气数据': 'Automatically refresh weather every 15 minutes.',
    '每30分钟自动更新天气数据': 'Automatically refresh weather every 30 minutes.',
    '每小时自动更新天气数据': 'Automatically refresh weather every hour.',
    '每2小时自动更新天气数据': 'Automatically refresh weather every 2 hours.',
    '显示': 'Display',
    '显示天气助手': 'Show Weather Assistant',
    '在底部导航栏显示天气助手页面':
        'Show Weather Assistant page in the bottom navigation bar',
    '数据': 'Data',
    '高级': 'Advanced',
    '预测式返回手势': 'Predictive Back Gesture',
    '返回时显示预览动画（Android 14+）': 'Show preview animation on back (Android 14+)',
    '关闭': 'Close',
    '重置': 'Reset',
    '通知': 'Notifications',
    '通知权限': 'Notification Permission',
    '定位权限': 'Location Permission',
    '需要通知权限': 'Notification Permission Required',
    '需要开启实时更新权限': 'Live Update Permission Required',
    '需要{title}': '{title} Required',
    '稍后设置': 'Set Later',
    '去设置': 'Go to Settings',
    '去检查': 'Check',
    '去开启': 'Enable',
    '以后再说': 'Maybe Later',
    '已开启': 'Enabled',
    '天气预警': 'Weather Alerts',
    '天气预警通知': 'Weather Alert Notifications',
    '接收极端天气预警推送': 'Receive severe weather alert pushes',
    '接收极端天气预警通知': 'Receive severe weather alert notifications.',
    'Android 16+ 在通知栏持续显示当前天气':
        'Show current weather persistently in the notification shade on Android 16+',
    '轻氧天气需要定位权限来获取您当前位置的天气信息。请在设置中授予定位权限。':
        'PureWeather needs location permission to get weather for your current location. Please grant location permission in settings.',
    '轻氧天气需要通知权限来推送天气预警信息。请在设置中授予通知权限。':
        'PureWeather needs notification permission to send weather alerts. Please grant notification permission in settings.',
    '轻氧天气需要通知权限才能推送天气预警。请在系统设置中授予通知权限。':
        'PureWeather needs notification permission to send weather alerts. Please grant it in system settings.',
    '无法打开系统实时更新设置页': 'Unable to open system live update settings page.',
    '系统当前未允许应用发布实时更新（Promoted）通知。请先在系统页面开启，再返回打开本开关。':
        'The system currently does not allow this app to post Promoted live update notifications. Enable it in system settings first, then return and turn on this switch.',
    '定时播报': 'Scheduled Broadcast',
    '设置每日定时推送天气信息': 'Set daily scheduled weather broadcasts',
    '设置每日定时推送天气信息。Android 16+ 将优先尝试实时更新通知，不满足条件时自动回退普通通知。':
        'Set daily scheduled weather broadcasts. On Android 16+, live update notifications are preferred and automatically fall back to regular notifications when unavailable.',
    '自定义天气详情页卡片显示顺序': 'Customize display order of weather detail cards',
    '基本设置': 'Basic Settings',
    '启用定时播报': 'Enable Scheduled Broadcast',
    '开启后将在设定时间推送天气信息（优先实时更新）':
        'When enabled, weather notifications are pushed at configured times (live updates preferred).',
    '播报时间': 'Broadcast Time',
    '早间播报': 'Morning Broadcast',
    '推送今日天气情况': 'Push today weather summary',
    '晚间播报': 'Evening Broadcast',
    '推送次日天气情况': 'Push tomorrow weather summary',
    '播报内容': 'Broadcast Content',
    '包含风力风向': 'Include Wind',
    '在播报中显示风向和风力等级': 'Show wind direction and wind level in broadcasts',
    '包含湿度信息': 'Include Humidity',
    '在播报中显示空气湿度': 'Show humidity in broadcasts',
    '测试': 'Test',
    '测试早间播报': 'Test Morning Broadcast',
    '立即发送一条早间播报通知': 'Send one morning broadcast notification now',
    '测试晚间播报': 'Test Evening Broadcast',
    '立即发送一条晚间播报通知': 'Send one evening broadcast notification now',
    '改善后台稳定性': 'Improve Background Stability',
    '重要提示': 'Important Notice',
    '定时播报需要通知权限才能推送天气信息':
        'Scheduled broadcast needs notification permission to push weather information',
    '定时播报需要定位权限才能获取当前位置的天气信息':
        'Scheduled broadcast needs location permission to get weather for current location',
    '定时播报需要"闹钟和提醒"权限才能准时推送。':
        'Scheduled broadcasts need the "Alarms & reminders" permission for on-time delivery.',
    '请确保以下设置已开启：': 'Please ensure the following setting is enabled:',
    '• 设置 → 应用 → 轻氧天气 → 权限 → 闹钟和提醒':
        '• Settings → Apps → PureWeather → Permissions → Alarms & reminders',
    '点击"去检查"跳转到设置页面确认。': 'Tap "Check" to open settings and confirm.',
    '{message}。请在系统设置中授予权限。': '{message}. Please grant it in system settings.',
    '测试播报已发送': 'Test broadcast has been sent',
    '发送失败: {error}': 'Send failed: {error}',
    '定时推送天气信息': 'Scheduled weather information push.',
    '点击查看今日天气详情': 'Tap to view today weather details',
    '点击查看明日天气详情': 'Tap to view tomorrow weather details',
    ' (来自本地缓存)': ' (from local cache)',
    '\n(来自本地缓存)': '\n(from local cache)',
    '早安天气': 'Morning Weather',
    '晚间天气': 'Evening Weather',
    '早上好 ☀️ {city}': 'Good morning ☀️ {city}',
    '晚上好 🌙 {city}': 'Good evening 🌙 {city}',
    '当前温度：{temp}°C': 'Current temperature: {temp}°C',
    '今日天气：{text}': 'Today weather: {text}',
    '晚间预报：{text}': 'Evening forecast: {text}',
    '明日天气：{text}': 'Tomorrow weather: {text}',
    '温度：{min}°C ~ {max}°C': 'Temperature: {min}°C ~ {max}°C',
    '风向风力：{dir} {scale}级': 'Wind: {dir} level {scale}',
    '湿度：{humidity}%': 'Humidity: {humidity}%',
    '降水量：{precip}mm': 'Precipitation: {precip}mm',
    '暂无明日天气数据': 'No tomorrow weather data',
    '未找到保存的城市，请先打开应用获取位置':
        'No saved city found. Open the app first to obtain location.',
    '天气数据获取失败: {error}': 'Failed to fetch weather data: {error}',
    '定时播报实时更新仅支持 Android':
        'Scheduled-broadcast live updates are supported on Android only',
    '定时调度实时更新仅支持 Android':
        'Scheduled live updates are supported on Android only',
    '实时更新开关未开启': 'Live update switch is not enabled',
    '当前平台不是 Android': 'Current platform is not Android',
    '当前没有可用于实时更新的天气数据': 'No weather data available for live updates',
    '当前系统不支持实时更新通知（需 Android 16+）':
        'Live update notifications are not supported on this system (Android 16+ required)',
    '该功能仅支持 Android 16 及以上系统':
        'This feature is only supported on Android 16 and above',
    '系统未允许应用发布 Promoted 实时更新通知':
        'The system does not allow this app to post Promoted live update notifications',
    '未授予通知权限': 'Notification permission not granted',
    '{value}级': 'Level {value}',
    '{text} · 体感{feelsLike}° · {time} 更新':
        '{text} · Feels like {feelsLike}° · Updated {time}',
    '实时更新通知发送成功': 'Live update notification sent successfully',
    '实时更新通知发送失败': 'Failed to send live update notification',
    '通道调用异常: {error}': 'Channel call exception: {error}',
    '原生返回结果格式无效': 'Native return result format is invalid',
    '调度实时更新通知异常: {error}':
        'Exception while scheduling live update notification: {error}',
    '该位置不在和风天气支持范围内（仅支持中国境内）':
        'This location is outside QWeather coverage (mainland China only)',
    '网络连接失败，请检查网络': 'Network connection failed. Please check your network.',
    '连接超时，请重试': 'Connection timeout. Please try again.',
    '响应超时，请重试': 'Response timeout. Please try again.',
    'API地址不存在，请检查API配置':
        'API endpoint not found. Please check API configuration.',
    'HTTP错误: {code}': 'HTTP error: {code}',
    '网络请求失败': 'Network request failed',
    '请求错误，请检查参数': 'Request error. Please check parameters.',
    'API密钥无效或已过期': 'API key is invalid or expired',
    '超过访问次数限制': 'Request limit exceeded',
    '无访问权限': 'No access permission',
    '查询的数据不存在': 'Requested data does not exist',
    '请求过于频繁，请稍后再试': 'Requests are too frequent. Please try again later.',
    '服务暂时不可用': 'Service is temporarily unavailable',
    'API错误码: {code}': 'API error code: {code}',
    '清空对话': 'Clear Conversation',
    '你好，我是轻氧天气助手': 'Hi, I am the PureWeather Assistant',
    '我可以帮你解答天气相关问题，提供穿衣建议、出行提醒等':
        'I can answer weather-related questions and provide clothing and travel suggestions.',
    '今天适合户外运动吗？': 'Is today suitable for outdoor exercise?',
    '明天需要带伞吗？': 'Do I need an umbrella tomorrow?',
    '今天穿什么合适？': 'What should I wear today?',
    '正在思考...': 'Thinking...',
    '输入消息...': 'Type a message...',
    '抱歉，无法连接到AI服务。': 'Sorry, unable to connect to the AI service.',
    '抱歉，发生了错误：{error}': 'Sorry, an error occurred: {error}',
    '抱歉，发生了错误。请稍后再试。': 'Sorry, something went wrong. Please try again later.',
    '实时更新通知': 'Live Update Notification',
    '实时更新诊断面板': 'Live Update Diagnostics Panel',
    '实时更新诊断（Debug）': 'Live Update Diagnostics (Debug)',
    '仅 Debug 版本可见，查看失败卡点':
        'Only visible in Debug builds, used to inspect failure checkpoints.',
    '每次尝试会记录：系统支持、通知权限、Promoted 权限、可推广特征等检查结果。':
        'Each attempt records checks such as system support, notification permission, Promoted permission, and promotable features.',
    '暂无诊断记录。触发一次实时更新后再回来查看。':
        'No diagnostic records yet. Trigger a live update and check again.',
    '标题预览：{title}': 'Title preview: {title}',
    '开关': 'Switch',
    '有天气数据': 'Has weather data',
    '系统支持': 'System support',
    'Promoted权限': 'Promoted permission',
    '可推广特征': 'Promotable characteristics',
    '清空记录': 'Clear Records',
    // Dynamic weather text fallback translations
    '晴': 'Sunny',
    '少云': 'Mostly Clear',
    '晴间多云': 'Partly Cloudy',
    '多云': 'Cloudy',
    '阴': 'Overcast',
    '有风': 'Windy',
    '平静': 'Calm',
    '微风': 'Light Breeze',
    '和风': 'Moderate Breeze',
    '清风': 'Fresh Breeze',
    '强风/劲风': 'Strong Breeze',
    '疾风': 'High Wind',
    '大风': 'Gale',
    '烈风': 'Strong Gale',
    '风暴': 'Storm',
    '狂爆风': 'Violent Storm',
    '飓风': 'Hurricane',
    '热带风暴': 'Tropical Storm',
    '阵雨': 'Shower',
    '强阵雨': 'Heavy Shower',
    '雷阵雨': 'Thundershower',
    '强雷阵雨': 'Severe Thundershower',
    '雷阵雨伴有冰雹': 'Thundershower with Hail',
    '小雨': 'Light Rain',
    '中雨': 'Moderate Rain',
    '大雨': 'Heavy Rain',
    '暴雨': 'Storm Rain',
    '大暴雨': 'Heavy Storm Rain',
    '特大暴雨': 'Extreme Storm Rain',
    '冻雨': 'Freezing Rain',
    '雨夹雪': 'Sleet',
    '阵雪': 'Snow Flurry',
    '小雪': 'Light Snow',
    '中雪': 'Moderate Snow',
    '大雪': 'Heavy Snow',
    '暴雪': 'Snowstorm',
    '雾': 'Fog',
    '浓雾': 'Dense Fog',
    '强浓雾': 'Heavy Dense Fog',
    '轻雾': 'Light Fog',
    '大雾': 'Heavy Fog',
    '特强浓雾': 'Severe Dense Fog',
    '霾': 'Haze',
    '中度霾': 'Moderate Haze',
    '重度霾': 'Heavy Haze',
    '严重霾': 'Severe Haze',
    '浮尘': 'Dust',
    '扬沙': 'Sand',
    '沙尘暴': 'Duststorm',
    '强沙尘暴': 'Severe Duststorm',
    '热': 'Hot',
    '冷': 'Cold',
    // Wind directions
    '北风': 'North Wind',
    '东北风': 'Northeast Wind',
    '东风': 'East Wind',
    '东南风': 'Southeast Wind',
    '南风': 'South Wind',
    '西南风': 'Southwest Wind',
    '西风': 'West Wind',
    '西北风': 'Northwest Wind',
    '无持续风向': 'Variable Wind',
    // Wind direction abbreviations from API
    'N': 'North Wind',
    'NNE': 'North-Northeast Wind',
    'NE': 'Northeast Wind',
    'ENE': 'East-Northeast Wind',
    'E': 'East Wind',
    'ESE': 'East-Southeast Wind',
    'SE': 'Southeast Wind',
    'SSE': 'South-Southeast Wind',
    'S': 'South Wind',
    'SSW': 'South-Southwest Wind',
    'SW': 'Southwest Wind',
    'WSW': 'West-Southwest Wind',
    'W': 'West Wind',
    'WNW': 'West-Northwest Wind',
    'NW': 'Northwest Wind',
    'NNW': 'North-Northwest Wind',
    'VAR': 'Variable Wind',
    'CALM': 'Calm',
    // Air quality categories
    '优': 'Excellent',
    '良': 'Good',
    '轻度污染': 'Light Pollution',
    '中度污染': 'Moderate Pollution',
    '重度污染': 'Heavy Pollution',
    '严重污染': 'Severe Pollution',
    // Life indices
    '运动指数': 'Exercise Index',
    '洗车指数': 'Car Wash Index',
    '穿衣指数': 'Clothing Index',
    '紫外线指数': 'UV Index',
    '旅游指数': 'Travel Index',
    '过敏指数': 'Allergy Index',
    '适宜': 'Suitable',
    '较适宜': 'Relatively Suitable',
    '舒适': 'Comfortable',
    '弱': 'Weak',
    '易发': 'Prone',
    '一般': 'Moderate',
    '较不宜': 'Less Suitable',
    '不宜': 'Not Suitable',
    '强': 'Strong',
    '很强': 'Very Strong',
    '极强': 'Extreme',
    '早上播报': 'Morning Broadcast',
    'Android 系统可能会为了省电而延迟后台通知。':
        'Android may delay background notifications to save battery.',
    '建议将应用设为"不限制"电池使用，以确保天气播报准时送达。':
        'Set app battery usage to "Unrestricted" to ensure broadcasts arrive on time.',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String zhText, {Map<String, Object?> args = const {}}) {
    return l10n.translate(zhText, args: args);
  }
}
