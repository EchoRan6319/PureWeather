// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'PureWeather';

  @override
  String get morning_broadcast => 'Morning Broadcast';

  @override
  String get evening_broadcast => 'Evening Broadcast';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get follow_system => 'Follow System';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English (US)';

  @override
  String get weather_details => 'Weather Details';

  @override
  String get temp => 'Temperature';

  @override
  String get wind => 'Wind';

  @override
  String get humidity => 'Humidity';

  @override
  String get air_quality => 'Air Quality';

  @override
  String get forecast_24h => '24h Forecast';

  @override
  String get forecast_7d => '7-Day Forecast';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get no_data => 'No Data';

  @override
  String get cache_tag => '(From Local Cache)';

  @override
  String get battery_optimization_title => 'Improve Stability';

  @override
  String get battery_optimization_content =>
      'Android may delay background notifications to save power.\n\nRecommended to set battery usage to \'Unrestricted\' for reliable broadcasts.';

  @override
  String get go_to_settings => 'Settings';

  @override
  String get later => 'Later';

  @override
  String get unknown_location => 'Unknown Location';

  @override
  String get max_temp => 'Max';

  @override
  String get min_temp => 'Min';

  @override
  String get feels_like => 'Feels';

  @override
  String get load_weather_failed => 'Failed to load weather';

  @override
  String get add_city_first => 'Please add a city';

  @override
  String get add_city_desc => 'Tap the navigation icon to add a city';

  @override
  String get rain_prediction => 'Rain Prediction';

  @override
  String get detailed_info => 'Details';

  @override
  String get wind_speed => 'Wind Speed';

  @override
  String get locate_failed => 'Localization failed, please check permissions';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get today => 'Today';

  @override
  String get personalization => 'Personalization';

  @override
  String get theme_mode => 'Theme Mode';

  @override
  String get theme_color => 'Theme Color';

  @override
  String get dynamic_color => 'Dynamic Color';

  @override
  String get dynamic_color_desc =>
      'Generate theme from wallpaper';

  @override
  String get light_mode => 'Light Mode';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get custom_color => 'Custom Color';

  @override
  String get wallpaper_color => 'Wallpaper Color';

  @override
  String get notification => 'Notification';

  @override
  String get weather_alert => 'Weather Alerts';

  @override
  String get weather_alert_desc => 'Receive extreme weather alerts';

  @override
  String get scheduled_broadcast => 'Daily Broadcast';

  @override
  String get scheduled_broadcast_desc => 'Get daily weather push notifications';

  @override
  String get display => 'Display';

  @override
  String get show_ai_assistant => 'Show AI Assistant';

  @override
  String get show_ai_assistant_desc => 'Show AI Assistant in navigation bar';

  @override
  String get temperature_unit => 'Temperature Unit';

  @override
  String get location_accuracy => 'Location Accuracy';

  @override
  String get location_accuracy_street => 'Street Level';

  @override
  String get location_accuracy_district => 'District Level';

  @override
  String get card_order => 'Card Order';

  @override
  String get card_order_desc => 'Custom weather card display order';

  @override
  String get wind_speed_unit => 'Wind Speed Unit';

  @override
  String get wind_unit_ms => 'm/s';

  @override
  String get wind_unit_kmph => 'km/h';

  @override
  String get wind_unit_mph => 'mph';

  @override
  String get data => 'Data';

  @override
  String get auto_refresh => 'Auto Refresh';

  @override
  String auto_refresh_desc(Object interval) {
    return 'Auto update every $interval mins';
  }

  @override
  String get refresh_interval => 'Refresh Interval';

  @override
  String get minutes => 'mins';

  @override
  String get advanced => 'Advanced';

  @override
  String get predictive_back => 'Predictive Back';

  @override
  String get predictive_back_desc =>
      'Preview animation on back gesture (Android 14+)';

  @override
  String get about => 'About';

  @override
  String get about_app => 'About PureWeather';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get user_agreement => 'User Agreement';

  @override
  String get pressure => 'Pressure';

  @override
  String get visibility => 'Visibility';

  @override
  String get cloudiness => 'Cloudiness';

  @override
  String get uv_index => 'UV Index';

  @override
  String get dew_point => 'Dew Point';

  @override
  String get aqi_excellent => 'Excellent';

  @override
  String get aqi_good => 'Good';

  @override
  String get aqi_lightly_polluted => 'Lightly Polluted';

  @override
  String get aqi_moderately_polluted => 'Moderately Polluted';

  @override
  String get aqi_heavily_polluted => 'Heavily Polluted';

  @override
  String get aqi_severely_polluted => 'Severely Polluted';

  @override
  String get condition_sunny => 'Sunny';

  @override
  String get condition_cloudy => 'Cloudy';

  @override
  String get condition_few_clouds => 'Few Clouds';

  @override
  String get condition_partly_cloudy => 'Partly Cloudy';

  @override
  String get condition_overcast => 'Overcast';

  @override
  String get condition_shower => 'Shower';

  @override
  String get condition_heavy_shower => 'Heavy Shower';

  @override
  String get condition_thundershower => 'Thundershower';

  @override
  String get condition_heavy_thundershower => 'Heavy Thundershower';

  @override
  String get condition_hail => 'Thundershower with Hail';

  @override
  String get condition_light_rain => 'Light Rain';

  @override
  String get condition_moderate_rain => 'Moderate Rain';

  @override
  String get condition_heavy_rain => 'Heavy Rain';

  @override
  String get condition_extreme_rain => 'Extreme Rain';

  @override
  String get condition_drizzle => 'Drizzle';

  @override
  String get condition_storm => 'Storm';

  @override
  String get condition_heavy_storm => 'Heavy Storm';

  @override
  String get condition_extreme_storm => 'Extreme Storm';

  @override
  String get condition_freezing_rain => 'Freezing Rain';

  @override
  String get condition_light_snow => 'Light Snow';

  @override
  String get condition_moderate_snow => 'Moderate Snow';

  @override
  String get condition_heavy_snow => 'Heavy Snow';

  @override
  String get condition_blizzard => 'Blizzard';

  @override
  String get condition_sleet => 'Sleet';

  @override
  String get condition_mist => 'Mist';

  @override
  String get condition_fog => 'Fog';

  @override
  String get condition_haze => 'Haze';

  @override
  String get condition_dust => 'Dust';

  @override
  String get condition_sand => 'Sand';

  @override
  String get condition_sandstorm => 'Sandstorm';

  @override
  String get condition_heavy_sandstorm => 'Heavy Sandstorm';

  @override
  String get condition_dense_fog => 'Dense Fog';

  @override
  String get condition_heat => 'Heat';

  @override
  String get condition_cold => 'Cold';

  @override
  String get condition_unknown => 'Unknown';

  @override
  String get wind_dir_n => 'North';

  @override
  String get wind_dir_ne => 'Northeast';

  @override
  String get wind_dir_e => 'East';

  @override
  String get wind_dir_se => 'Southeast';

  @override
  String get wind_dir_s => 'South';

  @override
  String get wind_dir_sw => 'Southwest';

  @override
  String get wind_dir_w => 'West';

  @override
  String get wind_dir_nw => 'Northwest';

  @override
  String get wind_dir_calm => 'Calm';

  @override
  String get wind_dir_variable => 'Variable';

  @override
  String wind_scale(Object scale) {
    return 'Force $scale';
  }

  @override
  String get main_pollutant => 'Main Pollutant';

  @override
  String get ai_assistant_title => 'Weather Assistant';

  @override
  String get ai_assistant_greeting => 'Hello, I\'m PureWeather Assistant';

  @override
  String get ai_assistant_description =>
      'I can help you with weather-related questions, provide clothing advice, travel reminders, and more';

  @override
  String get ai_quick_action_1 => 'Is today suitable for outdoor sports?';

  @override
  String get ai_quick_action_2 => 'Do I need an umbrella tomorrow?';

  @override
  String get ai_quick_action_3 => 'What should I wear today?';

  @override
  String get ai_thinking => 'Thinking...';

  @override
  String get ai_input_hint => 'Type a message...';

  @override
  String get ai_error_message =>
      'Sorry, an error occurred. Please try again later.';

  @override
  String get clear_chat => 'Clear Chat';
}
