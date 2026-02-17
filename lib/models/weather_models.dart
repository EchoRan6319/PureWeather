import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_models.freezed.dart';
part 'weather_models.g.dart';

@freezed
class Location with _$Location {
  const factory Location({
    required String id,
    required String name,
    required String adm1,
    required String adm2,
    required String country,
    required double lat,
    required double lon,
    required String tz,
    required String utcOffset,
    required bool isDefault,
    required int sortOrder,
    @Default(false) bool isLocated,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    required String obsTime,
    required String temp,
    required String feelsLike,
    required String icon,
    required String text,
    required String wind360,
    required String windDir,
    required String windScale,
    required String windSpeed,
    required String humidity,
    required String precip,
    required String pressure,
    required String vis,
    required String cloud,
    required String dew,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);
}

@freezed
class HourlyWeather with _$HourlyWeather {
  const factory HourlyWeather({
    required String fxTime,
    required String temp,
    required String icon,
    required String text,
    required String wind360,
    required String windDir,
    required String windScale,
    required String windSpeed,
    required String humidity,
    required String pop,
    required String precip,
    required String pressure,
    required String cloud,
    required String dew,
  }) = _HourlyWeather;

  factory HourlyWeather.fromJson(Map<String, dynamic> json) => _$HourlyWeatherFromJson(json);
}

@freezed
class DailyWeather with _$DailyWeather {
  const factory DailyWeather({
    required String fxDate,
    required String sunrise,
    required String sunset,
    required String moonrise,
    required String moonset,
    required String moonPhase,
    required String moonPhaseIcon,
    required String tempMax,
    required String tempMin,
    required String iconDay,
    required String textDay,
    required String iconNight,
    required String textNight,
    required String wind360Day,
    required String windDirDay,
    required String windScaleDay,
    required String windSpeedDay,
    required String wind360Night,
    required String windDirNight,
    required String windScaleNight,
    required String windSpeedNight,
    required String humidity,
    required String precip,
    required String pressure,
    required String vis,
    required String cloud,
    required String uvIndex,
  }) = _DailyWeather;

  factory DailyWeather.fromJson(Map<String, dynamic> json) => _$DailyWeatherFromJson(json);
}

@freezed
class WeatherAlert with _$WeatherAlert {
  const factory WeatherAlert({
    required String id,
    required String sender,
    required String pubTime,
    required String title,
    required String status,
    required String level,
    required String type,
    required String typeName,
    required String text,
  }) = _WeatherAlert;

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => _$WeatherAlertFromJson(json);
}

@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    required Location location,
    required CurrentWeather current,
    required List<HourlyWeather> hourly,
    required List<DailyWeather> daily,
    required List<WeatherAlert> alerts,
    required DateTime lastUpdated,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
}

@freezed
class AirQuality with _$AirQuality {
  const factory AirQuality({
    required String aqi,
    required String level,
    required String category,
    required String pm10,
    required String pm2p5,
    required String no2,
    required String so2,
    required String co,
    required String o3,
  }) = _AirQuality;

  factory AirQuality.fromJson(Map<String, dynamic> json) => _$AirQualityFromJson(json);
}

@freezed
class WeatherIndices with _$WeatherIndices {
  const factory WeatherIndices({
    required String type,
    required String name,
    required String level,
    required String category,
    required String text,
  }) = _WeatherIndices;

  factory WeatherIndices.fromJson(Map<String, dynamic> json) => _$WeatherIndicesFromJson(json);
}

extension WeatherDataExtension on WeatherData {
  bool get isStale {
    return DateTime.now().difference(lastUpdated).inMinutes > 30;
  }
  
  int get currentTempInt {
    return int.tryParse(current.temp) ?? 0;
  }
  
  int get feelsLikeInt {
    return int.tryParse(current.feelsLike) ?? 0;
  }
  
  int get humidityInt {
    return int.tryParse(current.humidity) ?? 0;
  }
  
  bool get hasAlerts => alerts.isNotEmpty;
  
  bool get hasExtremeWeather {
    return alerts.any((alert) => 
      alert.level == '红色' || alert.level == '橙色'
    );
  }
}
