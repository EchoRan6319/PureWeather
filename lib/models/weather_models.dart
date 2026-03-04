import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_models.freezed.dart';
part 'weather_models.g.dart';

/// 位置信息模型
/// 包含城市的基本信息
@freezed
class Location with _$Location {
  const factory Location({
    /// 城市ID
    required String id,
    /// 城市名称
    required String name,
    /// 省份名称
    required String adm1,
    /// 城市名称（行政级别）
    required String adm2,
    /// 国家名称
    required String country,
    /// 纬度
    required double lat,
    /// 经度
    required double lon,
    /// 时区
    required String tz,
    /// UTC 偏移
    required String utcOffset,
    /// 是否为默认城市
    required bool isDefault,
    /// 排序顺序
    required int sortOrder,
    /// 是否为定位城市
    @Default(false) bool isLocated,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

/// 当前天气模型
/// 包含实时天气数据
@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    /// 观测时间
    required String obsTime,
    /// 温度
    required String temp,
    /// 体感温度
    required String feelsLike,
    /// 天气图标
    required String icon,
    /// 天气描述
    required String text,
    /// 风向角度
    required String wind360,
    /// 风向
    required String windDir,
    /// 风力等级
    required String windScale,
    /// 风速
    required String windSpeed,
    /// 湿度
    required String humidity,
    /// 降水量
    required String precip,
    /// 气压
    required String pressure,
    /// 能见度
    required String vis,
    /// 云量
    required String cloud,
    /// 露点温度
    required String dew,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);
}

/// 逐小时天气预报模型
@freezed
class HourlyWeather with _$HourlyWeather {
  const factory HourlyWeather({
    /// 预报时间
    required String fxTime,
    /// 温度
    required String temp,
    /// 天气图标
    required String icon,
    /// 天气描述
    required String text,
    /// 风向角度
    required String wind360,
    /// 风向
    required String windDir,
    /// 风力等级
    required String windScale,
    /// 风速
    required String windSpeed,
    /// 湿度
    required String humidity,
    /// 降水概率
    required String pop,
    /// 降水量
    required String precip,
    /// 气压
    required String pressure,
    /// 云量
    required String cloud,
    /// 露点温度
    required String dew,
  }) = _HourlyWeather;

  factory HourlyWeather.fromJson(Map<String, dynamic> json) => _$HourlyWeatherFromJson(json);
}

/// 逐日天气预报模型
@freezed
class DailyWeather with _$DailyWeather {
  const factory DailyWeather({
    /// 预报日期
    required String fxDate,
    /// 日出时间
    required String sunrise,
    /// 日落时间
    required String sunset,
    /// 月出时间
    required String moonrise,
    /// 月落时间
    required String moonset,
    /// 月相
    required String moonPhase,
    /// 月相图标
    required String moonPhaseIcon,
    /// 最高温度
    required String tempMax,
    /// 最低温度
    required String tempMin,
    /// 白天天气图标
    required String iconDay,
    /// 白天天气描述
    required String textDay,
    /// 夜间天气图标
    required String iconNight,
    /// 夜间天气描述
    required String textNight,
    /// 白天风向角度
    required String wind360Day,
    /// 白天风向
    required String windDirDay,
    /// 白天风力等级
    required String windScaleDay,
    /// 白天风速
    required String windSpeedDay,
    /// 夜间风向角度
    required String wind360Night,
    /// 夜间风向
    required String windDirNight,
    /// 夜间风力等级
    required String windScaleNight,
    /// 夜间风速
    required String windSpeedNight,
    /// 湿度
    required String humidity,
    /// 降水量
    required String precip,
    /// 气压
    required String pressure,
    /// 能见度
    required String vis,
    /// 云量
    required String cloud,
    /// 紫外线指数
    required String uvIndex,
  }) = _DailyWeather;

  factory DailyWeather.fromJson(Map<String, dynamic> json) => _$DailyWeatherFromJson(json);
}

/// 天气预警模型
@freezed
class WeatherAlert with _$WeatherAlert {
  const factory WeatherAlert({
    /// 预警ID
    required String id,
    /// 发布机构
    required String sender,
    /// 发布时间
    required String pubTime,
    /// 预警标题
    required String title,
    /// 预警状态
    required String status,
    /// 预警等级
    required String level,
    /// 预警类型
    required String type,
    /// 预警类型名称
    required String typeName,
    /// 预警内容
    required String text,
  }) = _WeatherAlert;

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => _$WeatherAlertFromJson(json);
}

/// 天气数据模型
/// 包含完整的天气信息
@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    /// 位置信息
    required Location location,
    /// 当前天气
    required CurrentWeather current,
    /// 逐小时预报
    required List<HourlyWeather> hourly,
    /// 逐日预报
    required List<DailyWeather> daily,
    /// 天气预警
    required List<WeatherAlert> alerts,
    /// 最后更新时间
    required DateTime lastUpdated,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
}

/// 空气质量模型
@freezed
class AirQuality with _$AirQuality {
  const factory AirQuality({
    /// 空气质量指数
    required String aqi,
    /// 空气质量等级
    required String level,
    /// 空气质量类别
    required String category,
    /// PM10
    required String pm10,
    /// PM2.5
    required String pm2p5,
    /// 二氧化氮
    required String no2,
    /// 二氧化硫
    required String so2,
    /// 一氧化碳
    required String co,
    /// 臭氧
    required String o3,
  }) = _AirQuality;

  factory AirQuality.fromJson(Map<String, dynamic> json) => _$AirQualityFromJson(json);
}

/// 生活指数模型
@freezed
class WeatherIndices with _$WeatherIndices {
  const factory WeatherIndices({
    /// 指数类型
    required String type,
    /// 指数名称
    required String name,
    /// 指数等级
    required String level,
    /// 指数类别
    required String category,
    /// 指数描述
    required String text,
  }) = _WeatherIndices;

  factory WeatherIndices.fromJson(Map<String, dynamic> json) => _$WeatherIndicesFromJson(json);
}

/// WeatherData 扩展方法
/// 提供便捷的访问和判断方法
extension WeatherDataExtension on WeatherData {
  /// 数据是否过期（超过30分钟）
  bool get isStale {
    return DateTime.now().difference(lastUpdated).inMinutes > 30;
  }
  
  /// 当前温度（整数）
  int get currentTempInt {
    return int.tryParse(current.temp) ?? 0;
  }
  
  /// 体感温度（整数）
  int get feelsLikeInt {
    return int.tryParse(current.feelsLike) ?? 0;
  }
  
  /// 湿度（整数）
  int get humidityInt {
    return int.tryParse(current.humidity) ?? 0;
  }
  
  /// 是否有天气预警
  bool get hasAlerts => alerts.isNotEmpty;
  
  /// 是否有极端天气预警
  bool get hasExtremeWeather {
    return alerts.any((alert) => 
      alert.level == '红色' || alert.level == '橙色'
    );
  }
}
