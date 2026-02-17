// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      adm1: json['adm1'] as String,
      adm2: json['adm2'] as String,
      country: json['country'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      tz: json['tz'] as String,
      utcOffset: json['utcOffset'] as String,
      isDefault: json['isDefault'] as bool,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isLocated: json['isLocated'] as bool? ?? false,
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'adm1': instance.adm1,
      'adm2': instance.adm2,
      'country': instance.country,
      'lat': instance.lat,
      'lon': instance.lon,
      'tz': instance.tz,
      'utcOffset': instance.utcOffset,
      'isDefault': instance.isDefault,
      'sortOrder': instance.sortOrder,
      'isLocated': instance.isLocated,
    };

_$CurrentWeatherImpl _$$CurrentWeatherImplFromJson(Map<String, dynamic> json) =>
    _$CurrentWeatherImpl(
      obsTime: json['obsTime'] as String,
      temp: json['temp'] as String,
      feelsLike: json['feelsLike'] as String,
      icon: json['icon'] as String,
      text: json['text'] as String,
      wind360: json['wind360'] as String,
      windDir: json['windDir'] as String,
      windScale: json['windScale'] as String,
      windSpeed: json['windSpeed'] as String,
      humidity: json['humidity'] as String,
      precip: json['precip'] as String,
      pressure: json['pressure'] as String,
      vis: json['vis'] as String,
      cloud: json['cloud'] as String,
      dew: json['dew'] as String,
    );

Map<String, dynamic> _$$CurrentWeatherImplToJson(
  _$CurrentWeatherImpl instance,
) => <String, dynamic>{
  'obsTime': instance.obsTime,
  'temp': instance.temp,
  'feelsLike': instance.feelsLike,
  'icon': instance.icon,
  'text': instance.text,
  'wind360': instance.wind360,
  'windDir': instance.windDir,
  'windScale': instance.windScale,
  'windSpeed': instance.windSpeed,
  'humidity': instance.humidity,
  'precip': instance.precip,
  'pressure': instance.pressure,
  'vis': instance.vis,
  'cloud': instance.cloud,
  'dew': instance.dew,
};

_$HourlyWeatherImpl _$$HourlyWeatherImplFromJson(Map<String, dynamic> json) =>
    _$HourlyWeatherImpl(
      fxTime: json['fxTime'] as String,
      temp: json['temp'] as String,
      icon: json['icon'] as String,
      text: json['text'] as String,
      wind360: json['wind360'] as String,
      windDir: json['windDir'] as String,
      windScale: json['windScale'] as String,
      windSpeed: json['windSpeed'] as String,
      humidity: json['humidity'] as String,
      pop: json['pop'] as String,
      precip: json['precip'] as String,
      pressure: json['pressure'] as String,
      cloud: json['cloud'] as String,
      dew: json['dew'] as String,
    );

Map<String, dynamic> _$$HourlyWeatherImplToJson(_$HourlyWeatherImpl instance) =>
    <String, dynamic>{
      'fxTime': instance.fxTime,
      'temp': instance.temp,
      'icon': instance.icon,
      'text': instance.text,
      'wind360': instance.wind360,
      'windDir': instance.windDir,
      'windScale': instance.windScale,
      'windSpeed': instance.windSpeed,
      'humidity': instance.humidity,
      'pop': instance.pop,
      'precip': instance.precip,
      'pressure': instance.pressure,
      'cloud': instance.cloud,
      'dew': instance.dew,
    };

_$DailyWeatherImpl _$$DailyWeatherImplFromJson(Map<String, dynamic> json) =>
    _$DailyWeatherImpl(
      fxDate: json['fxDate'] as String,
      sunrise: json['sunrise'] as String,
      sunset: json['sunset'] as String,
      moonrise: json['moonrise'] as String,
      moonset: json['moonset'] as String,
      moonPhase: json['moonPhase'] as String,
      moonPhaseIcon: json['moonPhaseIcon'] as String,
      tempMax: json['tempMax'] as String,
      tempMin: json['tempMin'] as String,
      iconDay: json['iconDay'] as String,
      textDay: json['textDay'] as String,
      iconNight: json['iconNight'] as String,
      textNight: json['textNight'] as String,
      wind360Day: json['wind360Day'] as String,
      windDirDay: json['windDirDay'] as String,
      windScaleDay: json['windScaleDay'] as String,
      windSpeedDay: json['windSpeedDay'] as String,
      wind360Night: json['wind360Night'] as String,
      windDirNight: json['windDirNight'] as String,
      windScaleNight: json['windScaleNight'] as String,
      windSpeedNight: json['windSpeedNight'] as String,
      humidity: json['humidity'] as String,
      precip: json['precip'] as String,
      pressure: json['pressure'] as String,
      vis: json['vis'] as String,
      cloud: json['cloud'] as String,
      uvIndex: json['uvIndex'] as String,
    );

Map<String, dynamic> _$$DailyWeatherImplToJson(_$DailyWeatherImpl instance) =>
    <String, dynamic>{
      'fxDate': instance.fxDate,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
      'moonrise': instance.moonrise,
      'moonset': instance.moonset,
      'moonPhase': instance.moonPhase,
      'moonPhaseIcon': instance.moonPhaseIcon,
      'tempMax': instance.tempMax,
      'tempMin': instance.tempMin,
      'iconDay': instance.iconDay,
      'textDay': instance.textDay,
      'iconNight': instance.iconNight,
      'textNight': instance.textNight,
      'wind360Day': instance.wind360Day,
      'windDirDay': instance.windDirDay,
      'windScaleDay': instance.windScaleDay,
      'windSpeedDay': instance.windSpeedDay,
      'wind360Night': instance.wind360Night,
      'windDirNight': instance.windDirNight,
      'windScaleNight': instance.windScaleNight,
      'windSpeedNight': instance.windSpeedNight,
      'humidity': instance.humidity,
      'precip': instance.precip,
      'pressure': instance.pressure,
      'vis': instance.vis,
      'cloud': instance.cloud,
      'uvIndex': instance.uvIndex,
    };

_$WeatherAlertImpl _$$WeatherAlertImplFromJson(Map<String, dynamic> json) =>
    _$WeatherAlertImpl(
      id: json['id'] as String,
      sender: json['sender'] as String,
      pubTime: json['pubTime'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      level: json['level'] as String,
      type: json['type'] as String,
      typeName: json['typeName'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$WeatherAlertImplToJson(_$WeatherAlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'pubTime': instance.pubTime,
      'title': instance.title,
      'status': instance.status,
      'level': instance.level,
      'type': instance.type,
      'typeName': instance.typeName,
      'text': instance.text,
    };

_$WeatherDataImpl _$$WeatherDataImplFromJson(Map<String, dynamic> json) =>
    _$WeatherDataImpl(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      hourly: (json['hourly'] as List<dynamic>)
          .map((e) => HourlyWeather.fromJson(e as Map<String, dynamic>))
          .toList(),
      daily: (json['daily'] as List<dynamic>)
          .map((e) => DailyWeather.fromJson(e as Map<String, dynamic>))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$WeatherDataImplToJson(_$WeatherDataImpl instance) =>
    <String, dynamic>{
      'location': instance.location,
      'current': instance.current,
      'hourly': instance.hourly,
      'daily': instance.daily,
      'alerts': instance.alerts,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

_$AirQualityImpl _$$AirQualityImplFromJson(Map<String, dynamic> json) =>
    _$AirQualityImpl(
      aqi: json['aqi'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      pm10: json['pm10'] as String,
      pm2p5: json['pm2p5'] as String,
      no2: json['no2'] as String,
      so2: json['so2'] as String,
      co: json['co'] as String,
      o3: json['o3'] as String,
    );

Map<String, dynamic> _$$AirQualityImplToJson(_$AirQualityImpl instance) =>
    <String, dynamic>{
      'aqi': instance.aqi,
      'level': instance.level,
      'category': instance.category,
      'pm10': instance.pm10,
      'pm2p5': instance.pm2p5,
      'no2': instance.no2,
      'so2': instance.so2,
      'co': instance.co,
      'o3': instance.o3,
    };

_$WeatherIndicesImpl _$$WeatherIndicesImplFromJson(Map<String, dynamic> json) =>
    _$WeatherIndicesImpl(
      type: json['type'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$WeatherIndicesImplToJson(
  _$WeatherIndicesImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'name': instance.name,
  'level': instance.level,
  'category': instance.category,
  'text': instance.text,
};
