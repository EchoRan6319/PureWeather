import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @app_name.
  ///
  /// In zh, this message translates to:
  /// **'轻氧天气'**
  String get app_name;

  /// No description provided for @morning_broadcast.
  ///
  /// In zh, this message translates to:
  /// **'早上播报'**
  String get morning_broadcast;

  /// No description provided for @evening_broadcast.
  ///
  /// In zh, this message translates to:
  /// **'晚间播报'**
  String get evening_broadcast;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @follow_system.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get follow_system;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English (US)'**
  String get english;

  /// No description provided for @weather_details.
  ///
  /// In zh, this message translates to:
  /// **'天气详情'**
  String get weather_details;

  /// No description provided for @temp.
  ///
  /// In zh, this message translates to:
  /// **'温度'**
  String get temp;

  /// No description provided for @wind.
  ///
  /// In zh, this message translates to:
  /// **'风力'**
  String get wind;

  /// No description provided for @humidity.
  ///
  /// In zh, this message translates to:
  /// **'湿度'**
  String get humidity;

  /// No description provided for @air_quality.
  ///
  /// In zh, this message translates to:
  /// **'空气质量'**
  String get air_quality;

  /// No description provided for @forecast_24h.
  ///
  /// In zh, this message translates to:
  /// **'24小时预报'**
  String get forecast_24h;

  /// No description provided for @forecast_7d.
  ///
  /// In zh, this message translates to:
  /// **'7天预报'**
  String get forecast_7d;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @no_data.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get no_data;

  /// No description provided for @cache_tag.
  ///
  /// In zh, this message translates to:
  /// **'(来自本地缓存)'**
  String get cache_tag;

  /// No description provided for @battery_optimization_title.
  ///
  /// In zh, this message translates to:
  /// **'改善后台稳定性'**
  String get battery_optimization_title;

  /// No description provided for @battery_optimization_content.
  ///
  /// In zh, this message translates to:
  /// **'Android 系统可能会为了省电而延迟后台通知。\n\n建议将应用设为\"不限制\"电池使用，以确保天气播报准时送达。'**
  String get battery_optimization_content;

  /// No description provided for @go_to_settings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get go_to_settings;

  /// No description provided for @later.
  ///
  /// In zh, this message translates to:
  /// **'以后再说'**
  String get later;

  /// No description provided for @unknown_location.
  ///
  /// In zh, this message translates to:
  /// **'未知位置'**
  String get unknown_location;

  /// No description provided for @max_temp.
  ///
  /// In zh, this message translates to:
  /// **'最高'**
  String get max_temp;

  /// No description provided for @min_temp.
  ///
  /// In zh, this message translates to:
  /// **'最低'**
  String get min_temp;

  /// No description provided for @feels_like.
  ///
  /// In zh, this message translates to:
  /// **'体感'**
  String get feels_like;

  /// No description provided for @load_weather_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载天气失败'**
  String get load_weather_failed;

  /// No description provided for @add_city_first.
  ///
  /// In zh, this message translates to:
  /// **'请先添加城市'**
  String get add_city_first;

  /// No description provided for @add_city_desc.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角“位置”图标添加城市'**
  String get add_city_desc;

  /// No description provided for @rain_prediction.
  ///
  /// In zh, this message translates to:
  /// **'降雨预测'**
  String get rain_prediction;

  /// No description provided for @detailed_info.
  ///
  /// In zh, this message translates to:
  /// **'详细信息'**
  String get detailed_info;

  /// No description provided for @wind_speed.
  ///
  /// In zh, this message translates to:
  /// **'风速'**
  String get wind_speed;

  /// No description provided for @locate_failed.
  ///
  /// In zh, this message translates to:
  /// **'定位失败，请检查权限'**
  String get locate_failed;

  /// No description provided for @sunrise.
  ///
  /// In zh, this message translates to:
  /// **'日出'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In zh, this message translates to:
  /// **'日落'**
  String get sunset;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @personalization.
  ///
  /// In zh, this message translates to:
  /// **'个性化'**
  String get personalization;

  /// No description provided for @theme_mode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get theme_mode;

  /// No description provided for @theme_color.
  ///
  /// In zh, this message translates to:
  /// **'主题颜色'**
  String get theme_color;

  /// No description provided for @dynamic_color.
  ///
  /// In zh, this message translates to:
  /// **'动态取色'**
  String get dynamic_color;

  /// No description provided for @dynamic_color_desc.
  ///
  /// In zh, this message translates to:
  /// **'根据壁纸自动生成主题色'**
  String get dynamic_color_desc;

  /// No description provided for @light_mode.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get light_mode;

  /// No description provided for @dark_mode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get dark_mode;

  /// No description provided for @custom_color.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色'**
  String get custom_color;

  /// No description provided for @wallpaper_color.
  ///
  /// In zh, this message translates to:
  /// **'跟随壁纸'**
  String get wallpaper_color;

  /// No description provided for @notification.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notification;

  /// No description provided for @weather_alert.
  ///
  /// In zh, this message translates to:
  /// **'天气预警通知'**
  String get weather_alert;

  /// No description provided for @weather_alert_desc.
  ///
  /// In zh, this message translates to:
  /// **'接收极端天气预警推送'**
  String get weather_alert_desc;

  /// No description provided for @scheduled_broadcast.
  ///
  /// In zh, this message translates to:
  /// **'定时播报'**
  String get scheduled_broadcast;

  /// No description provided for @scheduled_broadcast_desc.
  ///
  /// In zh, this message translates to:
  /// **'设置每日定时推送天气信息'**
  String get scheduled_broadcast_desc;

  /// No description provided for @display.
  ///
  /// In zh, this message translates to:
  /// **'显示'**
  String get display;

  /// No description provided for @show_ai_assistant.
  ///
  /// In zh, this message translates to:
  /// **'显示天气助手'**
  String get show_ai_assistant;

  /// No description provided for @show_ai_assistant_desc.
  ///
  /// In zh, this message translates to:
  /// **'在底部导航栏显示天气助手页面'**
  String get show_ai_assistant_desc;

  /// No description provided for @temperature_unit.
  ///
  /// In zh, this message translates to:
  /// **'温度单位'**
  String get temperature_unit;

  /// No description provided for @location_accuracy.
  ///
  /// In zh, this message translates to:
  /// **'位置显示精度'**
  String get location_accuracy;

  /// No description provided for @location_accuracy_street.
  ///
  /// In zh, this message translates to:
  /// **'街道级别'**
  String get location_accuracy_street;

  /// No description provided for @location_accuracy_district.
  ///
  /// In zh, this message translates to:
  /// **'区县级别'**
  String get location_accuracy_district;

  /// No description provided for @card_order.
  ///
  /// In zh, this message translates to:
  /// **'天气卡片排序'**
  String get card_order;

  /// No description provided for @card_order_desc.
  ///
  /// In zh, this message translates to:
  /// **'自定义天气详情页卡片显示顺序'**
  String get card_order_desc;

  /// No description provided for @wind_speed_unit.
  ///
  /// In zh, this message translates to:
  /// **'风速单位'**
  String get wind_speed_unit;

  /// No description provided for @wind_unit_ms.
  ///
  /// In zh, this message translates to:
  /// **'米/秒 (m/s)'**
  String get wind_unit_ms;

  /// No description provided for @wind_unit_kmph.
  ///
  /// In zh, this message translates to:
  /// **'公里/小时 (km/h)'**
  String get wind_unit_kmph;

  /// No description provided for @wind_unit_mph.
  ///
  /// In zh, this message translates to:
  /// **'英里/小时 (mph)'**
  String get wind_unit_mph;

  /// No description provided for @data.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get data;

  /// No description provided for @auto_refresh.
  ///
  /// In zh, this message translates to:
  /// **'自动刷新'**
  String get auto_refresh;

  /// No description provided for @auto_refresh_desc.
  ///
  /// In zh, this message translates to:
  /// **'每 {interval} 分钟自动更新'**
  String auto_refresh_desc(Object interval);

  /// No description provided for @refresh_interval.
  ///
  /// In zh, this message translates to:
  /// **'刷新间隔'**
  String get refresh_interval;

  /// No description provided for @minutes.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get minutes;

  /// No description provided for @advanced.
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get advanced;

  /// No description provided for @predictive_back.
  ///
  /// In zh, this message translates to:
  /// **'预测式返回手势'**
  String get predictive_back;

  /// No description provided for @predictive_back_desc.
  ///
  /// In zh, this message translates to:
  /// **'返回时显示预览动画 (Android 14+)'**
  String get predictive_back_desc;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @about_app.
  ///
  /// In zh, this message translates to:
  /// **'关于轻氧天气'**
  String get about_app;

  /// No description provided for @privacy_policy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacy_policy;

  /// No description provided for @user_agreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get user_agreement;

  /// No description provided for @pressure.
  ///
  /// In zh, this message translates to:
  /// **'气压'**
  String get pressure;

  /// No description provided for @visibility.
  ///
  /// In zh, this message translates to:
  /// **'能见度'**
  String get visibility;

  /// No description provided for @cloudiness.
  ///
  /// In zh, this message translates to:
  /// **'云量'**
  String get cloudiness;

  /// No description provided for @uv_index.
  ///
  /// In zh, this message translates to:
  /// **'紫外线指数'**
  String get uv_index;

  /// No description provided for @dew_point.
  ///
  /// In zh, this message translates to:
  /// **'露点温度'**
  String get dew_point;

  /// No description provided for @aqi_excellent.
  ///
  /// In zh, this message translates to:
  /// **'优'**
  String get aqi_excellent;

  /// No description provided for @aqi_good.
  ///
  /// In zh, this message translates to:
  /// **'良'**
  String get aqi_good;

  /// No description provided for @aqi_lightly_polluted.
  ///
  /// In zh, this message translates to:
  /// **'轻度污染'**
  String get aqi_lightly_polluted;

  /// No description provided for @aqi_moderately_polluted.
  ///
  /// In zh, this message translates to:
  /// **'中度污染'**
  String get aqi_moderately_polluted;

  /// No description provided for @aqi_heavily_polluted.
  ///
  /// In zh, this message translates to:
  /// **'重度污染'**
  String get aqi_heavily_polluted;

  /// No description provided for @aqi_severely_polluted.
  ///
  /// In zh, this message translates to:
  /// **'严重污染'**
  String get aqi_severely_polluted;

  /// No description provided for @condition_sunny.
  ///
  /// In zh, this message translates to:
  /// **'晴'**
  String get condition_sunny;

  /// No description provided for @condition_cloudy.
  ///
  /// In zh, this message translates to:
  /// **'多云'**
  String get condition_cloudy;

  /// No description provided for @condition_few_clouds.
  ///
  /// In zh, this message translates to:
  /// **'少云'**
  String get condition_few_clouds;

  /// No description provided for @condition_partly_cloudy.
  ///
  /// In zh, this message translates to:
  /// **'晴间多云'**
  String get condition_partly_cloudy;

  /// No description provided for @condition_overcast.
  ///
  /// In zh, this message translates to:
  /// **'阴'**
  String get condition_overcast;

  /// No description provided for @condition_shower.
  ///
  /// In zh, this message translates to:
  /// **'阵雨'**
  String get condition_shower;

  /// No description provided for @condition_heavy_shower.
  ///
  /// In zh, this message translates to:
  /// **'强阵雨'**
  String get condition_heavy_shower;

  /// No description provided for @condition_thundershower.
  ///
  /// In zh, this message translates to:
  /// **'雷阵雨'**
  String get condition_thundershower;

  /// No description provided for @condition_heavy_thundershower.
  ///
  /// In zh, this message translates to:
  /// **'强雷阵雨'**
  String get condition_heavy_thundershower;

  /// No description provided for @condition_hail.
  ///
  /// In zh, this message translates to:
  /// **'雷阵雨伴有冰雹'**
  String get condition_hail;

  /// No description provided for @condition_light_rain.
  ///
  /// In zh, this message translates to:
  /// **'小雨'**
  String get condition_light_rain;

  /// No description provided for @condition_moderate_rain.
  ///
  /// In zh, this message translates to:
  /// **'中雨'**
  String get condition_moderate_rain;

  /// No description provided for @condition_heavy_rain.
  ///
  /// In zh, this message translates to:
  /// **'大雨'**
  String get condition_heavy_rain;

  /// No description provided for @condition_extreme_rain.
  ///
  /// In zh, this message translates to:
  /// **'极端降雨'**
  String get condition_extreme_rain;

  /// No description provided for @condition_drizzle.
  ///
  /// In zh, this message translates to:
  /// **'毛毛雨'**
  String get condition_drizzle;

  /// No description provided for @condition_storm.
  ///
  /// In zh, this message translates to:
  /// **'暴雨'**
  String get condition_storm;

  /// No description provided for @condition_heavy_storm.
  ///
  /// In zh, this message translates to:
  /// **'大暴雨'**
  String get condition_heavy_storm;

  /// No description provided for @condition_extreme_storm.
  ///
  /// In zh, this message translates to:
  /// **'特大暴雨'**
  String get condition_extreme_storm;

  /// No description provided for @condition_freezing_rain.
  ///
  /// In zh, this message translates to:
  /// **'冻雨'**
  String get condition_freezing_rain;

  /// No description provided for @condition_light_snow.
  ///
  /// In zh, this message translates to:
  /// **'小雪'**
  String get condition_light_snow;

  /// No description provided for @condition_moderate_snow.
  ///
  /// In zh, this message translates to:
  /// **'中雪'**
  String get condition_moderate_snow;

  /// No description provided for @condition_heavy_snow.
  ///
  /// In zh, this message translates to:
  /// **'大雪'**
  String get condition_heavy_snow;

  /// No description provided for @condition_blizzard.
  ///
  /// In zh, this message translates to:
  /// **'暴雪'**
  String get condition_blizzard;

  /// No description provided for @condition_sleet.
  ///
  /// In zh, this message translates to:
  /// **'雨夹雪'**
  String get condition_sleet;

  /// No description provided for @condition_mist.
  ///
  /// In zh, this message translates to:
  /// **'薄雾'**
  String get condition_mist;

  /// No description provided for @condition_fog.
  ///
  /// In zh, this message translates to:
  /// **'雾'**
  String get condition_fog;

  /// No description provided for @condition_haze.
  ///
  /// In zh, this message translates to:
  /// **'霾'**
  String get condition_haze;

  /// No description provided for @condition_dust.
  ///
  /// In zh, this message translates to:
  /// **'扬沙'**
  String get condition_dust;

  /// No description provided for @condition_sand.
  ///
  /// In zh, this message translates to:
  /// **'浮尘'**
  String get condition_sand;

  /// No description provided for @condition_sandstorm.
  ///
  /// In zh, this message translates to:
  /// **'沙尘暴'**
  String get condition_sandstorm;

  /// No description provided for @condition_heavy_sandstorm.
  ///
  /// In zh, this message translates to:
  /// **'强沙尘暴'**
  String get condition_heavy_sandstorm;

  /// No description provided for @condition_dense_fog.
  ///
  /// In zh, this message translates to:
  /// **'浓雾'**
  String get condition_dense_fog;

  /// No description provided for @condition_heat.
  ///
  /// In zh, this message translates to:
  /// **'热'**
  String get condition_heat;

  /// No description provided for @condition_cold.
  ///
  /// In zh, this message translates to:
  /// **'冷'**
  String get condition_cold;

  /// No description provided for @condition_unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get condition_unknown;

  /// No description provided for @wind_dir_n.
  ///
  /// In zh, this message translates to:
  /// **'北'**
  String get wind_dir_n;

  /// No description provided for @wind_dir_ne.
  ///
  /// In zh, this message translates to:
  /// **'东北'**
  String get wind_dir_ne;

  /// No description provided for @wind_dir_e.
  ///
  /// In zh, this message translates to:
  /// **'东'**
  String get wind_dir_e;

  /// No description provided for @wind_dir_se.
  ///
  /// In zh, this message translates to:
  /// **'东南'**
  String get wind_dir_se;

  /// No description provided for @wind_dir_s.
  ///
  /// In zh, this message translates to:
  /// **'南'**
  String get wind_dir_s;

  /// No description provided for @wind_dir_sw.
  ///
  /// In zh, this message translates to:
  /// **'西南'**
  String get wind_dir_sw;

  /// No description provided for @wind_dir_w.
  ///
  /// In zh, this message translates to:
  /// **'西'**
  String get wind_dir_w;

  /// No description provided for @wind_dir_nw.
  ///
  /// In zh, this message translates to:
  /// **'西北'**
  String get wind_dir_nw;

  /// No description provided for @wind_dir_calm.
  ///
  /// In zh, this message translates to:
  /// **'静风'**
  String get wind_dir_calm;

  /// No description provided for @wind_dir_variable.
  ///
  /// In zh, this message translates to:
  /// **'风向不定'**
  String get wind_dir_variable;

  /// No description provided for @wind_scale.
  ///
  /// In zh, this message translates to:
  /// **'{scale}级'**
  String wind_scale(Object scale);

  /// No description provided for @main_pollutant.
  ///
  /// In zh, this message translates to:
  /// **'主要污染物'**
  String get main_pollutant;

  /// No description provided for @ai_assistant_title.
  ///
  /// In zh, this message translates to:
  /// **'天气助手'**
  String get ai_assistant_title;

  /// No description provided for @ai_assistant_greeting.
  ///
  /// In zh, this message translates to:
  /// **'你好，我是轻氧天气助手'**
  String get ai_assistant_greeting;

  /// No description provided for @ai_assistant_description.
  ///
  /// In zh, this message translates to:
  /// **'我可以帮你解答天气相关问题，提供穿衣建议、出行提醒等'**
  String get ai_assistant_description;

  /// No description provided for @ai_quick_action_1.
  ///
  /// In zh, this message translates to:
  /// **'今天适合户外运动吗？'**
  String get ai_quick_action_1;

  /// No description provided for @ai_quick_action_2.
  ///
  /// In zh, this message translates to:
  /// **'明天需要带伞吗？'**
  String get ai_quick_action_2;

  /// No description provided for @ai_quick_action_3.
  ///
  /// In zh, this message translates to:
  /// **'今天穿什么合适？'**
  String get ai_quick_action_3;

  /// No description provided for @ai_thinking.
  ///
  /// In zh, this message translates to:
  /// **'正在思考...'**
  String get ai_thinking;

  /// No description provided for @ai_input_hint.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get ai_input_hint;

  /// No description provided for @ai_error_message.
  ///
  /// In zh, this message translates to:
  /// **'抱歉，发生了错误。请稍后再试。'**
  String get ai_error_message;

  /// No description provided for @clear_chat.
  ///
  /// In zh, this message translates to:
  /// **'清空对话'**
  String get clear_chat;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
