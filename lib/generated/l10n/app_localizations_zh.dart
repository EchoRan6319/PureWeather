// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get app_name => '轻氧天气';

  @override
  String get morning_broadcast => '早上播报';

  @override
  String get evening_broadcast => '晚间播报';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get follow_system => '跟随系统';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English (US)';

  @override
  String get weather_details => '天气详情';

  @override
  String get temp => '温度';

  @override
  String get wind => '风力';

  @override
  String get humidity => '湿度';

  @override
  String get air_quality => '空气质量';

  @override
  String get forecast_24h => '24小时预报';

  @override
  String get forecast_7d => '7天预报';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get no_data => '暂无数据';

  @override
  String get cache_tag => '(来自本地缓存)';

  @override
  String get battery_optimization_title => '改善后台稳定性';

  @override
  String get battery_optimization_content =>
      'Android 系统可能会为了省电而延迟后台通知。\n\n建议将应用设为\"不限制\"电池使用，以确保天气播报准时送达。';

  @override
  String get go_to_settings => '去设置';

  @override
  String get later => '以后再说';

  @override
  String get unknown_location => '未知位置';

  @override
  String get max_temp => '最高';

  @override
  String get min_temp => '最低';

  @override
  String get feels_like => '体感';

  @override
  String get load_weather_failed => '加载天气失败';

  @override
  String get add_city_first => '请先添加城市';

  @override
  String get add_city_desc => '点击右上角“位置”图标添加城市';

  @override
  String get rain_prediction => '降雨预测';

  @override
  String get detailed_info => '详细信息';

  @override
  String get wind_speed => '风速';

  @override
  String get locate_failed => '定位失败，请检查权限';

  @override
  String get sunrise => '日出';

  @override
  String get sunset => '日落';

  @override
  String get today => '今天';

  @override
  String get personalization => '个性化';

  @override
  String get theme_mode => '主题模式';

  @override
  String get theme_color => '主题颜色';

  @override
  String get dynamic_color => '动态取色';

  @override
  String get dynamic_color_desc => '根据壁纸自动生成主题色';

  @override
  String get light_mode => '浅色模式';

  @override
  String get dark_mode => '深色模式';

  @override
  String get custom_color => '自定义颜色';

  @override
  String get wallpaper_color => '跟随壁纸';

  @override
  String get notification => '通知';

  @override
  String get weather_alert => '天气预警通知';

  @override
  String get weather_alert_desc => '接收极端天气预警推送';

  @override
  String get scheduled_broadcast => '定时播报';

  @override
  String get scheduled_broadcast_desc => '设置每日定时推送天气信息';

  @override
  String get display => '显示';

  @override
  String get show_ai_assistant => '显示天气助手';

  @override
  String get show_ai_assistant_desc => '在底部导航栏显示天气助手页面';

  @override
  String get temperature_unit => '温度单位';

  @override
  String get location_accuracy => '位置显示精度';

  @override
  String get location_accuracy_street => '街道级别';

  @override
  String get location_accuracy_district => '区县级别';

  @override
  String get card_order => '天气卡片排序';

  @override
  String get card_order_desc => '自定义天气详情页卡片显示顺序';

  @override
  String get wind_speed_unit => '风速单位';

  @override
  String get wind_unit_ms => '米/秒 (m/s)';

  @override
  String get wind_unit_kmph => '公里/小时 (km/h)';

  @override
  String get wind_unit_mph => '英里/小时 (mph)';

  @override
  String get data => '数据';

  @override
  String get auto_refresh => '自动刷新';

  @override
  String auto_refresh_desc(Object interval) {
    return '每 $interval 分钟自动更新';
  }

  @override
  String get refresh_interval => '刷新间隔';

  @override
  String get minutes => '分钟';

  @override
  String get advanced => '高级';

  @override
  String get predictive_back => '预测式返回手势';

  @override
  String get predictive_back_desc => '返回时显示预览动画 (Android 14+)';

  @override
  String get about => '关于';

  @override
  String get about_app => '关于轻氧天气';

  @override
  String get privacy_policy => '隐私政策';

  @override
  String get user_agreement => '用户协议';

  @override
  String get pressure => '气压';

  @override
  String get visibility => '能见度';

  @override
  String get cloudiness => '云量';

  @override
  String get uv_index => '紫外线指数';

  @override
  String get dew_point => '露点温度';

  @override
  String get aqi_excellent => '优';

  @override
  String get aqi_good => '良';

  @override
  String get aqi_lightly_polluted => '轻度污染';

  @override
  String get aqi_moderately_polluted => '中度污染';

  @override
  String get aqi_heavily_polluted => '重度污染';

  @override
  String get aqi_severely_polluted => '严重污染';

  @override
  String get condition_sunny => '晴';

  @override
  String get condition_cloudy => '多云';

  @override
  String get condition_few_clouds => '少云';

  @override
  String get condition_partly_cloudy => '晴间多云';

  @override
  String get condition_overcast => '阴';

  @override
  String get condition_shower => '阵雨';

  @override
  String get condition_heavy_shower => '强阵雨';

  @override
  String get condition_thundershower => '雷阵雨';

  @override
  String get condition_heavy_thundershower => '强雷阵雨';

  @override
  String get condition_hail => '雷阵雨伴有冰雹';

  @override
  String get condition_light_rain => '小雨';

  @override
  String get condition_moderate_rain => '中雨';

  @override
  String get condition_heavy_rain => '大雨';

  @override
  String get condition_extreme_rain => '极端降雨';

  @override
  String get condition_drizzle => '毛毛雨';

  @override
  String get condition_storm => '暴雨';

  @override
  String get condition_heavy_storm => '大暴雨';

  @override
  String get condition_extreme_storm => '特大暴雨';

  @override
  String get condition_freezing_rain => '冻雨';

  @override
  String get condition_light_snow => '小雪';

  @override
  String get condition_moderate_snow => '中雪';

  @override
  String get condition_heavy_snow => '大雪';

  @override
  String get condition_blizzard => '暴雪';

  @override
  String get condition_sleet => '雨夹雪';

  @override
  String get condition_mist => '薄雾';

  @override
  String get condition_fog => '雾';

  @override
  String get condition_haze => '霾';

  @override
  String get condition_dust => '扬沙';

  @override
  String get condition_sand => '浮尘';

  @override
  String get condition_sandstorm => '沙尘暴';

  @override
  String get condition_heavy_sandstorm => '强沙尘暴';

  @override
  String get condition_dense_fog => '浓雾';

  @override
  String get condition_heat => '热';

  @override
  String get condition_cold => '冷';

  @override
  String get condition_unknown => '未知';

  @override
  String get wind_dir_n => '北';

  @override
  String get wind_dir_ne => '东北';

  @override
  String get wind_dir_e => '东';

  @override
  String get wind_dir_se => '东南';

  @override
  String get wind_dir_s => '南';

  @override
  String get wind_dir_sw => '西南';

  @override
  String get wind_dir_w => '西';

  @override
  String get wind_dir_nw => '西北';

  @override
  String get wind_dir_calm => '静风';

  @override
  String get wind_dir_variable => '风向不定';

  @override
  String wind_scale(Object scale) {
    return '$scale级';
  }

  @override
  String get main_pollutant => '主要污染物';

  @override
  String get ai_assistant_title => '天气助手';

  @override
  String get ai_assistant_greeting => '你好，我是轻氧天气助手';

  @override
  String get ai_assistant_description => '我可以帮你解答天气相关问题，提供穿衣建议、出行提醒等';

  @override
  String get ai_quick_action_1 => '今天适合户外运动吗？';

  @override
  String get ai_quick_action_2 => '明天需要带伞吗？';

  @override
  String get ai_quick_action_3 => '今天穿什么合适？';

  @override
  String get ai_thinking => '正在思考...';

  @override
  String get ai_input_hint => '输入消息...';

  @override
  String get ai_error_message => '抱歉，发生了错误。请稍后再试。';

  @override
  String get clear_chat => '清空对话';
}
