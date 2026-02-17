// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get adm1 => throw _privateConstructorUsedError;
  String get adm2 => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lon => throw _privateConstructorUsedError;
  String get tz => throw _privateConstructorUsedError;
  String get utcOffset => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isLocated => throw _privateConstructorUsedError;

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call({
    String id,
    String name,
    String adm1,
    String adm2,
    String country,
    double lat,
    double lon,
    String tz,
    String utcOffset,
    bool isDefault,
    int sortOrder,
    bool isLocated,
  });
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? adm1 = null,
    Object? adm2 = null,
    Object? country = null,
    Object? lat = null,
    Object? lon = null,
    Object? tz = null,
    Object? utcOffset = null,
    Object? isDefault = null,
    Object? sortOrder = null,
    Object? isLocated = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            adm1: null == adm1
                ? _value.adm1
                : adm1 // ignore: cast_nullable_to_non_nullable
                      as String,
            adm2: null == adm2
                ? _value.adm2
                : adm2 // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lon: null == lon
                ? _value.lon
                : lon // ignore: cast_nullable_to_non_nullable
                      as double,
            tz: null == tz
                ? _value.tz
                : tz // ignore: cast_nullable_to_non_nullable
                      as String,
            utcOffset: null == utcOffset
                ? _value.utcOffset
                : utcOffset // ignore: cast_nullable_to_non_nullable
                      as String,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isLocated: null == isLocated
                ? _value.isLocated
                : isLocated // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
    _$LocationImpl value,
    $Res Function(_$LocationImpl) then,
  ) = __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String adm1,
    String adm2,
    String country,
    double lat,
    double lon,
    String tz,
    String utcOffset,
    bool isDefault,
    int sortOrder,
    bool isLocated,
  });
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
    _$LocationImpl _value,
    $Res Function(_$LocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? adm1 = null,
    Object? adm2 = null,
    Object? country = null,
    Object? lat = null,
    Object? lon = null,
    Object? tz = null,
    Object? utcOffset = null,
    Object? isDefault = null,
    Object? sortOrder = null,
    Object? isLocated = null,
  }) {
    return _then(
      _$LocationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        adm1: null == adm1
            ? _value.adm1
            : adm1 // ignore: cast_nullable_to_non_nullable
                  as String,
        adm2: null == adm2
            ? _value.adm2
            : adm2 // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lon: null == lon
            ? _value.lon
            : lon // ignore: cast_nullable_to_non_nullable
                  as double,
        tz: null == tz
            ? _value.tz
            : tz // ignore: cast_nullable_to_non_nullable
                  as String,
        utcOffset: null == utcOffset
            ? _value.utcOffset
            : utcOffset // ignore: cast_nullable_to_non_nullable
                  as String,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isLocated: null == isLocated
            ? _value.isLocated
            : isLocated // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  const _$LocationImpl({
    required this.id,
    required this.name,
    required this.adm1,
    required this.adm2,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tz,
    required this.utcOffset,
    required this.isDefault,
    required this.sortOrder,
    this.isLocated = false,
  });

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String adm1;
  @override
  final String adm2;
  @override
  final String country;
  @override
  final double lat;
  @override
  final double lon;
  @override
  final String tz;
  @override
  final String utcOffset;
  @override
  final bool isDefault;
  @override
  final int sortOrder;
  @override
  @JsonKey()
  final bool isLocated;

  @override
  String toString() {
    return 'Location(id: $id, name: $name, adm1: $adm1, adm2: $adm2, country: $country, lat: $lat, lon: $lon, tz: $tz, utcOffset: $utcOffset, isDefault: $isDefault, sortOrder: $sortOrder, isLocated: $isLocated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.adm1, adm1) || other.adm1 == adm1) &&
            (identical(other.adm2, adm2) || other.adm2 == adm2) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.tz, tz) || other.tz == tz) &&
            (identical(other.utcOffset, utcOffset) ||
                other.utcOffset == utcOffset) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isLocated, isLocated) ||
                other.isLocated == isLocated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    adm1,
    adm2,
    country,
    lat,
    lon,
    tz,
    utcOffset,
    isDefault,
    sortOrder,
    isLocated,
  );

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(this);
  }
}

abstract class _Location implements Location {
  const factory _Location({
    required final String id,
    required final String name,
    required final String adm1,
    required final String adm2,
    required final String country,
    required final double lat,
    required final double lon,
    required final String tz,
    required final String utcOffset,
    required final bool isDefault,
    required final int sortOrder,
    final bool isLocated,
  }) = _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get adm1;
  @override
  String get adm2;
  @override
  String get country;
  @override
  double get lat;
  @override
  double get lon;
  @override
  String get tz;
  @override
  String get utcOffset;
  @override
  bool get isDefault;
  @override
  int get sortOrder;
  @override
  bool get isLocated;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CurrentWeather _$CurrentWeatherFromJson(Map<String, dynamic> json) {
  return _CurrentWeather.fromJson(json);
}

/// @nodoc
mixin _$CurrentWeather {
  String get obsTime => throw _privateConstructorUsedError;
  String get temp => throw _privateConstructorUsedError;
  String get feelsLike => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get wind360 => throw _privateConstructorUsedError;
  String get windDir => throw _privateConstructorUsedError;
  String get windScale => throw _privateConstructorUsedError;
  String get windSpeed => throw _privateConstructorUsedError;
  String get humidity => throw _privateConstructorUsedError;
  String get precip => throw _privateConstructorUsedError;
  String get pressure => throw _privateConstructorUsedError;
  String get vis => throw _privateConstructorUsedError;
  String get cloud => throw _privateConstructorUsedError;
  String get dew => throw _privateConstructorUsedError;

  /// Serializes this CurrentWeather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentWeatherCopyWith<CurrentWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentWeatherCopyWith<$Res> {
  factory $CurrentWeatherCopyWith(
    CurrentWeather value,
    $Res Function(CurrentWeather) then,
  ) = _$CurrentWeatherCopyWithImpl<$Res, CurrentWeather>;
  @useResult
  $Res call({
    String obsTime,
    String temp,
    String feelsLike,
    String icon,
    String text,
    String wind360,
    String windDir,
    String windScale,
    String windSpeed,
    String humidity,
    String precip,
    String pressure,
    String vis,
    String cloud,
    String dew,
  });
}

/// @nodoc
class _$CurrentWeatherCopyWithImpl<$Res, $Val extends CurrentWeather>
    implements $CurrentWeatherCopyWith<$Res> {
  _$CurrentWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? obsTime = null,
    Object? temp = null,
    Object? feelsLike = null,
    Object? icon = null,
    Object? text = null,
    Object? wind360 = null,
    Object? windDir = null,
    Object? windScale = null,
    Object? windSpeed = null,
    Object? humidity = null,
    Object? precip = null,
    Object? pressure = null,
    Object? vis = null,
    Object? cloud = null,
    Object? dew = null,
  }) {
    return _then(
      _value.copyWith(
            obsTime: null == obsTime
                ? _value.obsTime
                : obsTime // ignore: cast_nullable_to_non_nullable
                      as String,
            temp: null == temp
                ? _value.temp
                : temp // ignore: cast_nullable_to_non_nullable
                      as String,
            feelsLike: null == feelsLike
                ? _value.feelsLike
                : feelsLike // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            wind360: null == wind360
                ? _value.wind360
                : wind360 // ignore: cast_nullable_to_non_nullable
                      as String,
            windDir: null == windDir
                ? _value.windDir
                : windDir // ignore: cast_nullable_to_non_nullable
                      as String,
            windScale: null == windScale
                ? _value.windScale
                : windScale // ignore: cast_nullable_to_non_nullable
                      as String,
            windSpeed: null == windSpeed
                ? _value.windSpeed
                : windSpeed // ignore: cast_nullable_to_non_nullable
                      as String,
            humidity: null == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as String,
            precip: null == precip
                ? _value.precip
                : precip // ignore: cast_nullable_to_non_nullable
                      as String,
            pressure: null == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as String,
            vis: null == vis
                ? _value.vis
                : vis // ignore: cast_nullable_to_non_nullable
                      as String,
            cloud: null == cloud
                ? _value.cloud
                : cloud // ignore: cast_nullable_to_non_nullable
                      as String,
            dew: null == dew
                ? _value.dew
                : dew // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CurrentWeatherImplCopyWith<$Res>
    implements $CurrentWeatherCopyWith<$Res> {
  factory _$$CurrentWeatherImplCopyWith(
    _$CurrentWeatherImpl value,
    $Res Function(_$CurrentWeatherImpl) then,
  ) = __$$CurrentWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String obsTime,
    String temp,
    String feelsLike,
    String icon,
    String text,
    String wind360,
    String windDir,
    String windScale,
    String windSpeed,
    String humidity,
    String precip,
    String pressure,
    String vis,
    String cloud,
    String dew,
  });
}

/// @nodoc
class __$$CurrentWeatherImplCopyWithImpl<$Res>
    extends _$CurrentWeatherCopyWithImpl<$Res, _$CurrentWeatherImpl>
    implements _$$CurrentWeatherImplCopyWith<$Res> {
  __$$CurrentWeatherImplCopyWithImpl(
    _$CurrentWeatherImpl _value,
    $Res Function(_$CurrentWeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? obsTime = null,
    Object? temp = null,
    Object? feelsLike = null,
    Object? icon = null,
    Object? text = null,
    Object? wind360 = null,
    Object? windDir = null,
    Object? windScale = null,
    Object? windSpeed = null,
    Object? humidity = null,
    Object? precip = null,
    Object? pressure = null,
    Object? vis = null,
    Object? cloud = null,
    Object? dew = null,
  }) {
    return _then(
      _$CurrentWeatherImpl(
        obsTime: null == obsTime
            ? _value.obsTime
            : obsTime // ignore: cast_nullable_to_non_nullable
                  as String,
        temp: null == temp
            ? _value.temp
            : temp // ignore: cast_nullable_to_non_nullable
                  as String,
        feelsLike: null == feelsLike
            ? _value.feelsLike
            : feelsLike // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        wind360: null == wind360
            ? _value.wind360
            : wind360 // ignore: cast_nullable_to_non_nullable
                  as String,
        windDir: null == windDir
            ? _value.windDir
            : windDir // ignore: cast_nullable_to_non_nullable
                  as String,
        windScale: null == windScale
            ? _value.windScale
            : windScale // ignore: cast_nullable_to_non_nullable
                  as String,
        windSpeed: null == windSpeed
            ? _value.windSpeed
            : windSpeed // ignore: cast_nullable_to_non_nullable
                  as String,
        humidity: null == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as String,
        precip: null == precip
            ? _value.precip
            : precip // ignore: cast_nullable_to_non_nullable
                  as String,
        pressure: null == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as String,
        vis: null == vis
            ? _value.vis
            : vis // ignore: cast_nullable_to_non_nullable
                  as String,
        cloud: null == cloud
            ? _value.cloud
            : cloud // ignore: cast_nullable_to_non_nullable
                  as String,
        dew: null == dew
            ? _value.dew
            : dew // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrentWeatherImpl implements _CurrentWeather {
  const _$CurrentWeatherImpl({
    required this.obsTime,
    required this.temp,
    required this.feelsLike,
    required this.icon,
    required this.text,
    required this.wind360,
    required this.windDir,
    required this.windScale,
    required this.windSpeed,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.vis,
    required this.cloud,
    required this.dew,
  });

  factory _$CurrentWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrentWeatherImplFromJson(json);

  @override
  final String obsTime;
  @override
  final String temp;
  @override
  final String feelsLike;
  @override
  final String icon;
  @override
  final String text;
  @override
  final String wind360;
  @override
  final String windDir;
  @override
  final String windScale;
  @override
  final String windSpeed;
  @override
  final String humidity;
  @override
  final String precip;
  @override
  final String pressure;
  @override
  final String vis;
  @override
  final String cloud;
  @override
  final String dew;

  @override
  String toString() {
    return 'CurrentWeather(obsTime: $obsTime, temp: $temp, feelsLike: $feelsLike, icon: $icon, text: $text, wind360: $wind360, windDir: $windDir, windScale: $windScale, windSpeed: $windSpeed, humidity: $humidity, precip: $precip, pressure: $pressure, vis: $vis, cloud: $cloud, dew: $dew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentWeatherImpl &&
            (identical(other.obsTime, obsTime) || other.obsTime == obsTime) &&
            (identical(other.temp, temp) || other.temp == temp) &&
            (identical(other.feelsLike, feelsLike) ||
                other.feelsLike == feelsLike) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.wind360, wind360) || other.wind360 == wind360) &&
            (identical(other.windDir, windDir) || other.windDir == windDir) &&
            (identical(other.windScale, windScale) ||
                other.windScale == windScale) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.precip, precip) || other.precip == precip) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.vis, vis) || other.vis == vis) &&
            (identical(other.cloud, cloud) || other.cloud == cloud) &&
            (identical(other.dew, dew) || other.dew == dew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    obsTime,
    temp,
    feelsLike,
    icon,
    text,
    wind360,
    windDir,
    windScale,
    windSpeed,
    humidity,
    precip,
    pressure,
    vis,
    cloud,
    dew,
  );

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentWeatherImplCopyWith<_$CurrentWeatherImpl> get copyWith =>
      __$$CurrentWeatherImplCopyWithImpl<_$CurrentWeatherImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrentWeatherImplToJson(this);
  }
}

abstract class _CurrentWeather implements CurrentWeather {
  const factory _CurrentWeather({
    required final String obsTime,
    required final String temp,
    required final String feelsLike,
    required final String icon,
    required final String text,
    required final String wind360,
    required final String windDir,
    required final String windScale,
    required final String windSpeed,
    required final String humidity,
    required final String precip,
    required final String pressure,
    required final String vis,
    required final String cloud,
    required final String dew,
  }) = _$CurrentWeatherImpl;

  factory _CurrentWeather.fromJson(Map<String, dynamic> json) =
      _$CurrentWeatherImpl.fromJson;

  @override
  String get obsTime;
  @override
  String get temp;
  @override
  String get feelsLike;
  @override
  String get icon;
  @override
  String get text;
  @override
  String get wind360;
  @override
  String get windDir;
  @override
  String get windScale;
  @override
  String get windSpeed;
  @override
  String get humidity;
  @override
  String get precip;
  @override
  String get pressure;
  @override
  String get vis;
  @override
  String get cloud;
  @override
  String get dew;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentWeatherImplCopyWith<_$CurrentWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HourlyWeather _$HourlyWeatherFromJson(Map<String, dynamic> json) {
  return _HourlyWeather.fromJson(json);
}

/// @nodoc
mixin _$HourlyWeather {
  String get fxTime => throw _privateConstructorUsedError;
  String get temp => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get wind360 => throw _privateConstructorUsedError;
  String get windDir => throw _privateConstructorUsedError;
  String get windScale => throw _privateConstructorUsedError;
  String get windSpeed => throw _privateConstructorUsedError;
  String get humidity => throw _privateConstructorUsedError;
  String get pop => throw _privateConstructorUsedError;
  String get precip => throw _privateConstructorUsedError;
  String get pressure => throw _privateConstructorUsedError;
  String get cloud => throw _privateConstructorUsedError;
  String get dew => throw _privateConstructorUsedError;

  /// Serializes this HourlyWeather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyWeatherCopyWith<HourlyWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyWeatherCopyWith<$Res> {
  factory $HourlyWeatherCopyWith(
    HourlyWeather value,
    $Res Function(HourlyWeather) then,
  ) = _$HourlyWeatherCopyWithImpl<$Res, HourlyWeather>;
  @useResult
  $Res call({
    String fxTime,
    String temp,
    String icon,
    String text,
    String wind360,
    String windDir,
    String windScale,
    String windSpeed,
    String humidity,
    String pop,
    String precip,
    String pressure,
    String cloud,
    String dew,
  });
}

/// @nodoc
class _$HourlyWeatherCopyWithImpl<$Res, $Val extends HourlyWeather>
    implements $HourlyWeatherCopyWith<$Res> {
  _$HourlyWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fxTime = null,
    Object? temp = null,
    Object? icon = null,
    Object? text = null,
    Object? wind360 = null,
    Object? windDir = null,
    Object? windScale = null,
    Object? windSpeed = null,
    Object? humidity = null,
    Object? pop = null,
    Object? precip = null,
    Object? pressure = null,
    Object? cloud = null,
    Object? dew = null,
  }) {
    return _then(
      _value.copyWith(
            fxTime: null == fxTime
                ? _value.fxTime
                : fxTime // ignore: cast_nullable_to_non_nullable
                      as String,
            temp: null == temp
                ? _value.temp
                : temp // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            wind360: null == wind360
                ? _value.wind360
                : wind360 // ignore: cast_nullable_to_non_nullable
                      as String,
            windDir: null == windDir
                ? _value.windDir
                : windDir // ignore: cast_nullable_to_non_nullable
                      as String,
            windScale: null == windScale
                ? _value.windScale
                : windScale // ignore: cast_nullable_to_non_nullable
                      as String,
            windSpeed: null == windSpeed
                ? _value.windSpeed
                : windSpeed // ignore: cast_nullable_to_non_nullable
                      as String,
            humidity: null == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as String,
            pop: null == pop
                ? _value.pop
                : pop // ignore: cast_nullable_to_non_nullable
                      as String,
            precip: null == precip
                ? _value.precip
                : precip // ignore: cast_nullable_to_non_nullable
                      as String,
            pressure: null == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as String,
            cloud: null == cloud
                ? _value.cloud
                : cloud // ignore: cast_nullable_to_non_nullable
                      as String,
            dew: null == dew
                ? _value.dew
                : dew // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HourlyWeatherImplCopyWith<$Res>
    implements $HourlyWeatherCopyWith<$Res> {
  factory _$$HourlyWeatherImplCopyWith(
    _$HourlyWeatherImpl value,
    $Res Function(_$HourlyWeatherImpl) then,
  ) = __$$HourlyWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fxTime,
    String temp,
    String icon,
    String text,
    String wind360,
    String windDir,
    String windScale,
    String windSpeed,
    String humidity,
    String pop,
    String precip,
    String pressure,
    String cloud,
    String dew,
  });
}

/// @nodoc
class __$$HourlyWeatherImplCopyWithImpl<$Res>
    extends _$HourlyWeatherCopyWithImpl<$Res, _$HourlyWeatherImpl>
    implements _$$HourlyWeatherImplCopyWith<$Res> {
  __$$HourlyWeatherImplCopyWithImpl(
    _$HourlyWeatherImpl _value,
    $Res Function(_$HourlyWeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fxTime = null,
    Object? temp = null,
    Object? icon = null,
    Object? text = null,
    Object? wind360 = null,
    Object? windDir = null,
    Object? windScale = null,
    Object? windSpeed = null,
    Object? humidity = null,
    Object? pop = null,
    Object? precip = null,
    Object? pressure = null,
    Object? cloud = null,
    Object? dew = null,
  }) {
    return _then(
      _$HourlyWeatherImpl(
        fxTime: null == fxTime
            ? _value.fxTime
            : fxTime // ignore: cast_nullable_to_non_nullable
                  as String,
        temp: null == temp
            ? _value.temp
            : temp // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        wind360: null == wind360
            ? _value.wind360
            : wind360 // ignore: cast_nullable_to_non_nullable
                  as String,
        windDir: null == windDir
            ? _value.windDir
            : windDir // ignore: cast_nullable_to_non_nullable
                  as String,
        windScale: null == windScale
            ? _value.windScale
            : windScale // ignore: cast_nullable_to_non_nullable
                  as String,
        windSpeed: null == windSpeed
            ? _value.windSpeed
            : windSpeed // ignore: cast_nullable_to_non_nullable
                  as String,
        humidity: null == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as String,
        pop: null == pop
            ? _value.pop
            : pop // ignore: cast_nullable_to_non_nullable
                  as String,
        precip: null == precip
            ? _value.precip
            : precip // ignore: cast_nullable_to_non_nullable
                  as String,
        pressure: null == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as String,
        cloud: null == cloud
            ? _value.cloud
            : cloud // ignore: cast_nullable_to_non_nullable
                  as String,
        dew: null == dew
            ? _value.dew
            : dew // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HourlyWeatherImpl implements _HourlyWeather {
  const _$HourlyWeatherImpl({
    required this.fxTime,
    required this.temp,
    required this.icon,
    required this.text,
    required this.wind360,
    required this.windDir,
    required this.windScale,
    required this.windSpeed,
    required this.humidity,
    required this.pop,
    required this.precip,
    required this.pressure,
    required this.cloud,
    required this.dew,
  });

  factory _$HourlyWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$HourlyWeatherImplFromJson(json);

  @override
  final String fxTime;
  @override
  final String temp;
  @override
  final String icon;
  @override
  final String text;
  @override
  final String wind360;
  @override
  final String windDir;
  @override
  final String windScale;
  @override
  final String windSpeed;
  @override
  final String humidity;
  @override
  final String pop;
  @override
  final String precip;
  @override
  final String pressure;
  @override
  final String cloud;
  @override
  final String dew;

  @override
  String toString() {
    return 'HourlyWeather(fxTime: $fxTime, temp: $temp, icon: $icon, text: $text, wind360: $wind360, windDir: $windDir, windScale: $windScale, windSpeed: $windSpeed, humidity: $humidity, pop: $pop, precip: $precip, pressure: $pressure, cloud: $cloud, dew: $dew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyWeatherImpl &&
            (identical(other.fxTime, fxTime) || other.fxTime == fxTime) &&
            (identical(other.temp, temp) || other.temp == temp) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.wind360, wind360) || other.wind360 == wind360) &&
            (identical(other.windDir, windDir) || other.windDir == windDir) &&
            (identical(other.windScale, windScale) ||
                other.windScale == windScale) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.pop, pop) || other.pop == pop) &&
            (identical(other.precip, precip) || other.precip == precip) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.cloud, cloud) || other.cloud == cloud) &&
            (identical(other.dew, dew) || other.dew == dew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fxTime,
    temp,
    icon,
    text,
    wind360,
    windDir,
    windScale,
    windSpeed,
    humidity,
    pop,
    precip,
    pressure,
    cloud,
    dew,
  );

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyWeatherImplCopyWith<_$HourlyWeatherImpl> get copyWith =>
      __$$HourlyWeatherImplCopyWithImpl<_$HourlyWeatherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HourlyWeatherImplToJson(this);
  }
}

abstract class _HourlyWeather implements HourlyWeather {
  const factory _HourlyWeather({
    required final String fxTime,
    required final String temp,
    required final String icon,
    required final String text,
    required final String wind360,
    required final String windDir,
    required final String windScale,
    required final String windSpeed,
    required final String humidity,
    required final String pop,
    required final String precip,
    required final String pressure,
    required final String cloud,
    required final String dew,
  }) = _$HourlyWeatherImpl;

  factory _HourlyWeather.fromJson(Map<String, dynamic> json) =
      _$HourlyWeatherImpl.fromJson;

  @override
  String get fxTime;
  @override
  String get temp;
  @override
  String get icon;
  @override
  String get text;
  @override
  String get wind360;
  @override
  String get windDir;
  @override
  String get windScale;
  @override
  String get windSpeed;
  @override
  String get humidity;
  @override
  String get pop;
  @override
  String get precip;
  @override
  String get pressure;
  @override
  String get cloud;
  @override
  String get dew;

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyWeatherImplCopyWith<_$HourlyWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyWeather _$DailyWeatherFromJson(Map<String, dynamic> json) {
  return _DailyWeather.fromJson(json);
}

/// @nodoc
mixin _$DailyWeather {
  String get fxDate => throw _privateConstructorUsedError;
  String get sunrise => throw _privateConstructorUsedError;
  String get sunset => throw _privateConstructorUsedError;
  String get moonrise => throw _privateConstructorUsedError;
  String get moonset => throw _privateConstructorUsedError;
  String get moonPhase => throw _privateConstructorUsedError;
  String get moonPhaseIcon => throw _privateConstructorUsedError;
  String get tempMax => throw _privateConstructorUsedError;
  String get tempMin => throw _privateConstructorUsedError;
  String get iconDay => throw _privateConstructorUsedError;
  String get textDay => throw _privateConstructorUsedError;
  String get iconNight => throw _privateConstructorUsedError;
  String get textNight => throw _privateConstructorUsedError;
  String get wind360Day => throw _privateConstructorUsedError;
  String get windDirDay => throw _privateConstructorUsedError;
  String get windScaleDay => throw _privateConstructorUsedError;
  String get windSpeedDay => throw _privateConstructorUsedError;
  String get wind360Night => throw _privateConstructorUsedError;
  String get windDirNight => throw _privateConstructorUsedError;
  String get windScaleNight => throw _privateConstructorUsedError;
  String get windSpeedNight => throw _privateConstructorUsedError;
  String get humidity => throw _privateConstructorUsedError;
  String get precip => throw _privateConstructorUsedError;
  String get pressure => throw _privateConstructorUsedError;
  String get vis => throw _privateConstructorUsedError;
  String get cloud => throw _privateConstructorUsedError;
  String get uvIndex => throw _privateConstructorUsedError;

  /// Serializes this DailyWeather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyWeatherCopyWith<DailyWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyWeatherCopyWith<$Res> {
  factory $DailyWeatherCopyWith(
    DailyWeather value,
    $Res Function(DailyWeather) then,
  ) = _$DailyWeatherCopyWithImpl<$Res, DailyWeather>;
  @useResult
  $Res call({
    String fxDate,
    String sunrise,
    String sunset,
    String moonrise,
    String moonset,
    String moonPhase,
    String moonPhaseIcon,
    String tempMax,
    String tempMin,
    String iconDay,
    String textDay,
    String iconNight,
    String textNight,
    String wind360Day,
    String windDirDay,
    String windScaleDay,
    String windSpeedDay,
    String wind360Night,
    String windDirNight,
    String windScaleNight,
    String windSpeedNight,
    String humidity,
    String precip,
    String pressure,
    String vis,
    String cloud,
    String uvIndex,
  });
}

/// @nodoc
class _$DailyWeatherCopyWithImpl<$Res, $Val extends DailyWeather>
    implements $DailyWeatherCopyWith<$Res> {
  _$DailyWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fxDate = null,
    Object? sunrise = null,
    Object? sunset = null,
    Object? moonrise = null,
    Object? moonset = null,
    Object? moonPhase = null,
    Object? moonPhaseIcon = null,
    Object? tempMax = null,
    Object? tempMin = null,
    Object? iconDay = null,
    Object? textDay = null,
    Object? iconNight = null,
    Object? textNight = null,
    Object? wind360Day = null,
    Object? windDirDay = null,
    Object? windScaleDay = null,
    Object? windSpeedDay = null,
    Object? wind360Night = null,
    Object? windDirNight = null,
    Object? windScaleNight = null,
    Object? windSpeedNight = null,
    Object? humidity = null,
    Object? precip = null,
    Object? pressure = null,
    Object? vis = null,
    Object? cloud = null,
    Object? uvIndex = null,
  }) {
    return _then(
      _value.copyWith(
            fxDate: null == fxDate
                ? _value.fxDate
                : fxDate // ignore: cast_nullable_to_non_nullable
                      as String,
            sunrise: null == sunrise
                ? _value.sunrise
                : sunrise // ignore: cast_nullable_to_non_nullable
                      as String,
            sunset: null == sunset
                ? _value.sunset
                : sunset // ignore: cast_nullable_to_non_nullable
                      as String,
            moonrise: null == moonrise
                ? _value.moonrise
                : moonrise // ignore: cast_nullable_to_non_nullable
                      as String,
            moonset: null == moonset
                ? _value.moonset
                : moonset // ignore: cast_nullable_to_non_nullable
                      as String,
            moonPhase: null == moonPhase
                ? _value.moonPhase
                : moonPhase // ignore: cast_nullable_to_non_nullable
                      as String,
            moonPhaseIcon: null == moonPhaseIcon
                ? _value.moonPhaseIcon
                : moonPhaseIcon // ignore: cast_nullable_to_non_nullable
                      as String,
            tempMax: null == tempMax
                ? _value.tempMax
                : tempMax // ignore: cast_nullable_to_non_nullable
                      as String,
            tempMin: null == tempMin
                ? _value.tempMin
                : tempMin // ignore: cast_nullable_to_non_nullable
                      as String,
            iconDay: null == iconDay
                ? _value.iconDay
                : iconDay // ignore: cast_nullable_to_non_nullable
                      as String,
            textDay: null == textDay
                ? _value.textDay
                : textDay // ignore: cast_nullable_to_non_nullable
                      as String,
            iconNight: null == iconNight
                ? _value.iconNight
                : iconNight // ignore: cast_nullable_to_non_nullable
                      as String,
            textNight: null == textNight
                ? _value.textNight
                : textNight // ignore: cast_nullable_to_non_nullable
                      as String,
            wind360Day: null == wind360Day
                ? _value.wind360Day
                : wind360Day // ignore: cast_nullable_to_non_nullable
                      as String,
            windDirDay: null == windDirDay
                ? _value.windDirDay
                : windDirDay // ignore: cast_nullable_to_non_nullable
                      as String,
            windScaleDay: null == windScaleDay
                ? _value.windScaleDay
                : windScaleDay // ignore: cast_nullable_to_non_nullable
                      as String,
            windSpeedDay: null == windSpeedDay
                ? _value.windSpeedDay
                : windSpeedDay // ignore: cast_nullable_to_non_nullable
                      as String,
            wind360Night: null == wind360Night
                ? _value.wind360Night
                : wind360Night // ignore: cast_nullable_to_non_nullable
                      as String,
            windDirNight: null == windDirNight
                ? _value.windDirNight
                : windDirNight // ignore: cast_nullable_to_non_nullable
                      as String,
            windScaleNight: null == windScaleNight
                ? _value.windScaleNight
                : windScaleNight // ignore: cast_nullable_to_non_nullable
                      as String,
            windSpeedNight: null == windSpeedNight
                ? _value.windSpeedNight
                : windSpeedNight // ignore: cast_nullable_to_non_nullable
                      as String,
            humidity: null == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as String,
            precip: null == precip
                ? _value.precip
                : precip // ignore: cast_nullable_to_non_nullable
                      as String,
            pressure: null == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as String,
            vis: null == vis
                ? _value.vis
                : vis // ignore: cast_nullable_to_non_nullable
                      as String,
            cloud: null == cloud
                ? _value.cloud
                : cloud // ignore: cast_nullable_to_non_nullable
                      as String,
            uvIndex: null == uvIndex
                ? _value.uvIndex
                : uvIndex // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyWeatherImplCopyWith<$Res>
    implements $DailyWeatherCopyWith<$Res> {
  factory _$$DailyWeatherImplCopyWith(
    _$DailyWeatherImpl value,
    $Res Function(_$DailyWeatherImpl) then,
  ) = __$$DailyWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fxDate,
    String sunrise,
    String sunset,
    String moonrise,
    String moonset,
    String moonPhase,
    String moonPhaseIcon,
    String tempMax,
    String tempMin,
    String iconDay,
    String textDay,
    String iconNight,
    String textNight,
    String wind360Day,
    String windDirDay,
    String windScaleDay,
    String windSpeedDay,
    String wind360Night,
    String windDirNight,
    String windScaleNight,
    String windSpeedNight,
    String humidity,
    String precip,
    String pressure,
    String vis,
    String cloud,
    String uvIndex,
  });
}

/// @nodoc
class __$$DailyWeatherImplCopyWithImpl<$Res>
    extends _$DailyWeatherCopyWithImpl<$Res, _$DailyWeatherImpl>
    implements _$$DailyWeatherImplCopyWith<$Res> {
  __$$DailyWeatherImplCopyWithImpl(
    _$DailyWeatherImpl _value,
    $Res Function(_$DailyWeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fxDate = null,
    Object? sunrise = null,
    Object? sunset = null,
    Object? moonrise = null,
    Object? moonset = null,
    Object? moonPhase = null,
    Object? moonPhaseIcon = null,
    Object? tempMax = null,
    Object? tempMin = null,
    Object? iconDay = null,
    Object? textDay = null,
    Object? iconNight = null,
    Object? textNight = null,
    Object? wind360Day = null,
    Object? windDirDay = null,
    Object? windScaleDay = null,
    Object? windSpeedDay = null,
    Object? wind360Night = null,
    Object? windDirNight = null,
    Object? windScaleNight = null,
    Object? windSpeedNight = null,
    Object? humidity = null,
    Object? precip = null,
    Object? pressure = null,
    Object? vis = null,
    Object? cloud = null,
    Object? uvIndex = null,
  }) {
    return _then(
      _$DailyWeatherImpl(
        fxDate: null == fxDate
            ? _value.fxDate
            : fxDate // ignore: cast_nullable_to_non_nullable
                  as String,
        sunrise: null == sunrise
            ? _value.sunrise
            : sunrise // ignore: cast_nullable_to_non_nullable
                  as String,
        sunset: null == sunset
            ? _value.sunset
            : sunset // ignore: cast_nullable_to_non_nullable
                  as String,
        moonrise: null == moonrise
            ? _value.moonrise
            : moonrise // ignore: cast_nullable_to_non_nullable
                  as String,
        moonset: null == moonset
            ? _value.moonset
            : moonset // ignore: cast_nullable_to_non_nullable
                  as String,
        moonPhase: null == moonPhase
            ? _value.moonPhase
            : moonPhase // ignore: cast_nullable_to_non_nullable
                  as String,
        moonPhaseIcon: null == moonPhaseIcon
            ? _value.moonPhaseIcon
            : moonPhaseIcon // ignore: cast_nullable_to_non_nullable
                  as String,
        tempMax: null == tempMax
            ? _value.tempMax
            : tempMax // ignore: cast_nullable_to_non_nullable
                  as String,
        tempMin: null == tempMin
            ? _value.tempMin
            : tempMin // ignore: cast_nullable_to_non_nullable
                  as String,
        iconDay: null == iconDay
            ? _value.iconDay
            : iconDay // ignore: cast_nullable_to_non_nullable
                  as String,
        textDay: null == textDay
            ? _value.textDay
            : textDay // ignore: cast_nullable_to_non_nullable
                  as String,
        iconNight: null == iconNight
            ? _value.iconNight
            : iconNight // ignore: cast_nullable_to_non_nullable
                  as String,
        textNight: null == textNight
            ? _value.textNight
            : textNight // ignore: cast_nullable_to_non_nullable
                  as String,
        wind360Day: null == wind360Day
            ? _value.wind360Day
            : wind360Day // ignore: cast_nullable_to_non_nullable
                  as String,
        windDirDay: null == windDirDay
            ? _value.windDirDay
            : windDirDay // ignore: cast_nullable_to_non_nullable
                  as String,
        windScaleDay: null == windScaleDay
            ? _value.windScaleDay
            : windScaleDay // ignore: cast_nullable_to_non_nullable
                  as String,
        windSpeedDay: null == windSpeedDay
            ? _value.windSpeedDay
            : windSpeedDay // ignore: cast_nullable_to_non_nullable
                  as String,
        wind360Night: null == wind360Night
            ? _value.wind360Night
            : wind360Night // ignore: cast_nullable_to_non_nullable
                  as String,
        windDirNight: null == windDirNight
            ? _value.windDirNight
            : windDirNight // ignore: cast_nullable_to_non_nullable
                  as String,
        windScaleNight: null == windScaleNight
            ? _value.windScaleNight
            : windScaleNight // ignore: cast_nullable_to_non_nullable
                  as String,
        windSpeedNight: null == windSpeedNight
            ? _value.windSpeedNight
            : windSpeedNight // ignore: cast_nullable_to_non_nullable
                  as String,
        humidity: null == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as String,
        precip: null == precip
            ? _value.precip
            : precip // ignore: cast_nullable_to_non_nullable
                  as String,
        pressure: null == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as String,
        vis: null == vis
            ? _value.vis
            : vis // ignore: cast_nullable_to_non_nullable
                  as String,
        cloud: null == cloud
            ? _value.cloud
            : cloud // ignore: cast_nullable_to_non_nullable
                  as String,
        uvIndex: null == uvIndex
            ? _value.uvIndex
            : uvIndex // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyWeatherImpl implements _DailyWeather {
  const _$DailyWeatherImpl({
    required this.fxDate,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonPhaseIcon,
    required this.tempMax,
    required this.tempMin,
    required this.iconDay,
    required this.textDay,
    required this.iconNight,
    required this.textNight,
    required this.wind360Day,
    required this.windDirDay,
    required this.windScaleDay,
    required this.windSpeedDay,
    required this.wind360Night,
    required this.windDirNight,
    required this.windScaleNight,
    required this.windSpeedNight,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.vis,
    required this.cloud,
    required this.uvIndex,
  });

  factory _$DailyWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyWeatherImplFromJson(json);

  @override
  final String fxDate;
  @override
  final String sunrise;
  @override
  final String sunset;
  @override
  final String moonrise;
  @override
  final String moonset;
  @override
  final String moonPhase;
  @override
  final String moonPhaseIcon;
  @override
  final String tempMax;
  @override
  final String tempMin;
  @override
  final String iconDay;
  @override
  final String textDay;
  @override
  final String iconNight;
  @override
  final String textNight;
  @override
  final String wind360Day;
  @override
  final String windDirDay;
  @override
  final String windScaleDay;
  @override
  final String windSpeedDay;
  @override
  final String wind360Night;
  @override
  final String windDirNight;
  @override
  final String windScaleNight;
  @override
  final String windSpeedNight;
  @override
  final String humidity;
  @override
  final String precip;
  @override
  final String pressure;
  @override
  final String vis;
  @override
  final String cloud;
  @override
  final String uvIndex;

  @override
  String toString() {
    return 'DailyWeather(fxDate: $fxDate, sunrise: $sunrise, sunset: $sunset, moonrise: $moonrise, moonset: $moonset, moonPhase: $moonPhase, moonPhaseIcon: $moonPhaseIcon, tempMax: $tempMax, tempMin: $tempMin, iconDay: $iconDay, textDay: $textDay, iconNight: $iconNight, textNight: $textNight, wind360Day: $wind360Day, windDirDay: $windDirDay, windScaleDay: $windScaleDay, windSpeedDay: $windSpeedDay, wind360Night: $wind360Night, windDirNight: $windDirNight, windScaleNight: $windScaleNight, windSpeedNight: $windSpeedNight, humidity: $humidity, precip: $precip, pressure: $pressure, vis: $vis, cloud: $cloud, uvIndex: $uvIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyWeatherImpl &&
            (identical(other.fxDate, fxDate) || other.fxDate == fxDate) &&
            (identical(other.sunrise, sunrise) || other.sunrise == sunrise) &&
            (identical(other.sunset, sunset) || other.sunset == sunset) &&
            (identical(other.moonrise, moonrise) ||
                other.moonrise == moonrise) &&
            (identical(other.moonset, moonset) || other.moonset == moonset) &&
            (identical(other.moonPhase, moonPhase) ||
                other.moonPhase == moonPhase) &&
            (identical(other.moonPhaseIcon, moonPhaseIcon) ||
                other.moonPhaseIcon == moonPhaseIcon) &&
            (identical(other.tempMax, tempMax) || other.tempMax == tempMax) &&
            (identical(other.tempMin, tempMin) || other.tempMin == tempMin) &&
            (identical(other.iconDay, iconDay) || other.iconDay == iconDay) &&
            (identical(other.textDay, textDay) || other.textDay == textDay) &&
            (identical(other.iconNight, iconNight) ||
                other.iconNight == iconNight) &&
            (identical(other.textNight, textNight) ||
                other.textNight == textNight) &&
            (identical(other.wind360Day, wind360Day) ||
                other.wind360Day == wind360Day) &&
            (identical(other.windDirDay, windDirDay) ||
                other.windDirDay == windDirDay) &&
            (identical(other.windScaleDay, windScaleDay) ||
                other.windScaleDay == windScaleDay) &&
            (identical(other.windSpeedDay, windSpeedDay) ||
                other.windSpeedDay == windSpeedDay) &&
            (identical(other.wind360Night, wind360Night) ||
                other.wind360Night == wind360Night) &&
            (identical(other.windDirNight, windDirNight) ||
                other.windDirNight == windDirNight) &&
            (identical(other.windScaleNight, windScaleNight) ||
                other.windScaleNight == windScaleNight) &&
            (identical(other.windSpeedNight, windSpeedNight) ||
                other.windSpeedNight == windSpeedNight) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.precip, precip) || other.precip == precip) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.vis, vis) || other.vis == vis) &&
            (identical(other.cloud, cloud) || other.cloud == cloud) &&
            (identical(other.uvIndex, uvIndex) || other.uvIndex == uvIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    fxDate,
    sunrise,
    sunset,
    moonrise,
    moonset,
    moonPhase,
    moonPhaseIcon,
    tempMax,
    tempMin,
    iconDay,
    textDay,
    iconNight,
    textNight,
    wind360Day,
    windDirDay,
    windScaleDay,
    windSpeedDay,
    wind360Night,
    windDirNight,
    windScaleNight,
    windSpeedNight,
    humidity,
    precip,
    pressure,
    vis,
    cloud,
    uvIndex,
  ]);

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyWeatherImplCopyWith<_$DailyWeatherImpl> get copyWith =>
      __$$DailyWeatherImplCopyWithImpl<_$DailyWeatherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyWeatherImplToJson(this);
  }
}

abstract class _DailyWeather implements DailyWeather {
  const factory _DailyWeather({
    required final String fxDate,
    required final String sunrise,
    required final String sunset,
    required final String moonrise,
    required final String moonset,
    required final String moonPhase,
    required final String moonPhaseIcon,
    required final String tempMax,
    required final String tempMin,
    required final String iconDay,
    required final String textDay,
    required final String iconNight,
    required final String textNight,
    required final String wind360Day,
    required final String windDirDay,
    required final String windScaleDay,
    required final String windSpeedDay,
    required final String wind360Night,
    required final String windDirNight,
    required final String windScaleNight,
    required final String windSpeedNight,
    required final String humidity,
    required final String precip,
    required final String pressure,
    required final String vis,
    required final String cloud,
    required final String uvIndex,
  }) = _$DailyWeatherImpl;

  factory _DailyWeather.fromJson(Map<String, dynamic> json) =
      _$DailyWeatherImpl.fromJson;

  @override
  String get fxDate;
  @override
  String get sunrise;
  @override
  String get sunset;
  @override
  String get moonrise;
  @override
  String get moonset;
  @override
  String get moonPhase;
  @override
  String get moonPhaseIcon;
  @override
  String get tempMax;
  @override
  String get tempMin;
  @override
  String get iconDay;
  @override
  String get textDay;
  @override
  String get iconNight;
  @override
  String get textNight;
  @override
  String get wind360Day;
  @override
  String get windDirDay;
  @override
  String get windScaleDay;
  @override
  String get windSpeedDay;
  @override
  String get wind360Night;
  @override
  String get windDirNight;
  @override
  String get windScaleNight;
  @override
  String get windSpeedNight;
  @override
  String get humidity;
  @override
  String get precip;
  @override
  String get pressure;
  @override
  String get vis;
  @override
  String get cloud;
  @override
  String get uvIndex;

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyWeatherImplCopyWith<_$DailyWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherAlert _$WeatherAlertFromJson(Map<String, dynamic> json) {
  return _WeatherAlert.fromJson(json);
}

/// @nodoc
mixin _$WeatherAlert {
  String get id => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError;
  String get pubTime => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get typeName => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this WeatherAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherAlertCopyWith<WeatherAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherAlertCopyWith<$Res> {
  factory $WeatherAlertCopyWith(
    WeatherAlert value,
    $Res Function(WeatherAlert) then,
  ) = _$WeatherAlertCopyWithImpl<$Res, WeatherAlert>;
  @useResult
  $Res call({
    String id,
    String sender,
    String pubTime,
    String title,
    String status,
    String level,
    String type,
    String typeName,
    String text,
  });
}

/// @nodoc
class _$WeatherAlertCopyWithImpl<$Res, $Val extends WeatherAlert>
    implements $WeatherAlertCopyWith<$Res> {
  _$WeatherAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? pubTime = null,
    Object? title = null,
    Object? status = null,
    Object? level = null,
    Object? type = null,
    Object? typeName = null,
    Object? text = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sender: null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as String,
            pubTime: null == pubTime
                ? _value.pubTime
                : pubTime // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            typeName: null == typeName
                ? _value.typeName
                : typeName // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherAlertImplCopyWith<$Res>
    implements $WeatherAlertCopyWith<$Res> {
  factory _$$WeatherAlertImplCopyWith(
    _$WeatherAlertImpl value,
    $Res Function(_$WeatherAlertImpl) then,
  ) = __$$WeatherAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sender,
    String pubTime,
    String title,
    String status,
    String level,
    String type,
    String typeName,
    String text,
  });
}

/// @nodoc
class __$$WeatherAlertImplCopyWithImpl<$Res>
    extends _$WeatherAlertCopyWithImpl<$Res, _$WeatherAlertImpl>
    implements _$$WeatherAlertImplCopyWith<$Res> {
  __$$WeatherAlertImplCopyWithImpl(
    _$WeatherAlertImpl _value,
    $Res Function(_$WeatherAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? pubTime = null,
    Object? title = null,
    Object? status = null,
    Object? level = null,
    Object? type = null,
    Object? typeName = null,
    Object? text = null,
  }) {
    return _then(
      _$WeatherAlertImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sender: null == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as String,
        pubTime: null == pubTime
            ? _value.pubTime
            : pubTime // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        typeName: null == typeName
            ? _value.typeName
            : typeName // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherAlertImpl implements _WeatherAlert {
  const _$WeatherAlertImpl({
    required this.id,
    required this.sender,
    required this.pubTime,
    required this.title,
    required this.status,
    required this.level,
    required this.type,
    required this.typeName,
    required this.text,
  });

  factory _$WeatherAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherAlertImplFromJson(json);

  @override
  final String id;
  @override
  final String sender;
  @override
  final String pubTime;
  @override
  final String title;
  @override
  final String status;
  @override
  final String level;
  @override
  final String type;
  @override
  final String typeName;
  @override
  final String text;

  @override
  String toString() {
    return 'WeatherAlert(id: $id, sender: $sender, pubTime: $pubTime, title: $title, status: $status, level: $level, type: $type, typeName: $typeName, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.pubTime, pubTime) || other.pubTime == pubTime) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.typeName, typeName) ||
                other.typeName == typeName) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sender,
    pubTime,
    title,
    status,
    level,
    type,
    typeName,
    text,
  );

  /// Create a copy of WeatherAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherAlertImplCopyWith<_$WeatherAlertImpl> get copyWith =>
      __$$WeatherAlertImplCopyWithImpl<_$WeatherAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherAlertImplToJson(this);
  }
}

abstract class _WeatherAlert implements WeatherAlert {
  const factory _WeatherAlert({
    required final String id,
    required final String sender,
    required final String pubTime,
    required final String title,
    required final String status,
    required final String level,
    required final String type,
    required final String typeName,
    required final String text,
  }) = _$WeatherAlertImpl;

  factory _WeatherAlert.fromJson(Map<String, dynamic> json) =
      _$WeatherAlertImpl.fromJson;

  @override
  String get id;
  @override
  String get sender;
  @override
  String get pubTime;
  @override
  String get title;
  @override
  String get status;
  @override
  String get level;
  @override
  String get type;
  @override
  String get typeName;
  @override
  String get text;

  /// Create a copy of WeatherAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherAlertImplCopyWith<_$WeatherAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) {
  return _WeatherData.fromJson(json);
}

/// @nodoc
mixin _$WeatherData {
  Location get location => throw _privateConstructorUsedError;
  CurrentWeather get current => throw _privateConstructorUsedError;
  List<HourlyWeather> get hourly => throw _privateConstructorUsedError;
  List<DailyWeather> get daily => throw _privateConstructorUsedError;
  List<WeatherAlert> get alerts => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this WeatherData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherDataCopyWith<WeatherData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherDataCopyWith<$Res> {
  factory $WeatherDataCopyWith(
    WeatherData value,
    $Res Function(WeatherData) then,
  ) = _$WeatherDataCopyWithImpl<$Res, WeatherData>;
  @useResult
  $Res call({
    Location location,
    CurrentWeather current,
    List<HourlyWeather> hourly,
    List<DailyWeather> daily,
    List<WeatherAlert> alerts,
    DateTime lastUpdated,
  });

  $LocationCopyWith<$Res> get location;
  $CurrentWeatherCopyWith<$Res> get current;
}

/// @nodoc
class _$WeatherDataCopyWithImpl<$Res, $Val extends WeatherData>
    implements $WeatherDataCopyWith<$Res> {
  _$WeatherDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? current = null,
    Object? hourly = null,
    Object? daily = null,
    Object? alerts = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as Location,
            current: null == current
                ? _value.current
                : current // ignore: cast_nullable_to_non_nullable
                      as CurrentWeather,
            hourly: null == hourly
                ? _value.hourly
                : hourly // ignore: cast_nullable_to_non_nullable
                      as List<HourlyWeather>,
            daily: null == daily
                ? _value.daily
                : daily // ignore: cast_nullable_to_non_nullable
                      as List<DailyWeather>,
            alerts: null == alerts
                ? _value.alerts
                : alerts // ignore: cast_nullable_to_non_nullable
                      as List<WeatherAlert>,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res> get location {
    return $LocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CurrentWeatherCopyWith<$Res> get current {
    return $CurrentWeatherCopyWith<$Res>(_value.current, (value) {
      return _then(_value.copyWith(current: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeatherDataImplCopyWith<$Res>
    implements $WeatherDataCopyWith<$Res> {
  factory _$$WeatherDataImplCopyWith(
    _$WeatherDataImpl value,
    $Res Function(_$WeatherDataImpl) then,
  ) = __$$WeatherDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Location location,
    CurrentWeather current,
    List<HourlyWeather> hourly,
    List<DailyWeather> daily,
    List<WeatherAlert> alerts,
    DateTime lastUpdated,
  });

  @override
  $LocationCopyWith<$Res> get location;
  @override
  $CurrentWeatherCopyWith<$Res> get current;
}

/// @nodoc
class __$$WeatherDataImplCopyWithImpl<$Res>
    extends _$WeatherDataCopyWithImpl<$Res, _$WeatherDataImpl>
    implements _$$WeatherDataImplCopyWith<$Res> {
  __$$WeatherDataImplCopyWithImpl(
    _$WeatherDataImpl _value,
    $Res Function(_$WeatherDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = null,
    Object? current = null,
    Object? hourly = null,
    Object? daily = null,
    Object? alerts = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _$WeatherDataImpl(
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as Location,
        current: null == current
            ? _value.current
            : current // ignore: cast_nullable_to_non_nullable
                  as CurrentWeather,
        hourly: null == hourly
            ? _value._hourly
            : hourly // ignore: cast_nullable_to_non_nullable
                  as List<HourlyWeather>,
        daily: null == daily
            ? _value._daily
            : daily // ignore: cast_nullable_to_non_nullable
                  as List<DailyWeather>,
        alerts: null == alerts
            ? _value._alerts
            : alerts // ignore: cast_nullable_to_non_nullable
                  as List<WeatherAlert>,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherDataImpl implements _WeatherData {
  const _$WeatherDataImpl({
    required this.location,
    required this.current,
    required final List<HourlyWeather> hourly,
    required final List<DailyWeather> daily,
    required final List<WeatherAlert> alerts,
    required this.lastUpdated,
  }) : _hourly = hourly,
       _daily = daily,
       _alerts = alerts;

  factory _$WeatherDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherDataImplFromJson(json);

  @override
  final Location location;
  @override
  final CurrentWeather current;
  final List<HourlyWeather> _hourly;
  @override
  List<HourlyWeather> get hourly {
    if (_hourly is EqualUnmodifiableListView) return _hourly;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hourly);
  }

  final List<DailyWeather> _daily;
  @override
  List<DailyWeather> get daily {
    if (_daily is EqualUnmodifiableListView) return _daily;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daily);
  }

  final List<WeatherAlert> _alerts;
  @override
  List<WeatherAlert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'WeatherData(location: $location, current: $current, hourly: $hourly, daily: $daily, alerts: $alerts, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherDataImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.current, current) || other.current == current) &&
            const DeepCollectionEquality().equals(other._hourly, _hourly) &&
            const DeepCollectionEquality().equals(other._daily, _daily) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    location,
    current,
    const DeepCollectionEquality().hash(_hourly),
    const DeepCollectionEquality().hash(_daily),
    const DeepCollectionEquality().hash(_alerts),
    lastUpdated,
  );

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      __$$WeatherDataImplCopyWithImpl<_$WeatherDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherDataImplToJson(this);
  }
}

abstract class _WeatherData implements WeatherData {
  const factory _WeatherData({
    required final Location location,
    required final CurrentWeather current,
    required final List<HourlyWeather> hourly,
    required final List<DailyWeather> daily,
    required final List<WeatherAlert> alerts,
    required final DateTime lastUpdated,
  }) = _$WeatherDataImpl;

  factory _WeatherData.fromJson(Map<String, dynamic> json) =
      _$WeatherDataImpl.fromJson;

  @override
  Location get location;
  @override
  CurrentWeather get current;
  @override
  List<HourlyWeather> get hourly;
  @override
  List<DailyWeather> get daily;
  @override
  List<WeatherAlert> get alerts;
  @override
  DateTime get lastUpdated;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AirQuality _$AirQualityFromJson(Map<String, dynamic> json) {
  return _AirQuality.fromJson(json);
}

/// @nodoc
mixin _$AirQuality {
  String get aqi => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get pm10 => throw _privateConstructorUsedError;
  String get pm2p5 => throw _privateConstructorUsedError;
  String get no2 => throw _privateConstructorUsedError;
  String get so2 => throw _privateConstructorUsedError;
  String get co => throw _privateConstructorUsedError;
  String get o3 => throw _privateConstructorUsedError;

  /// Serializes this AirQuality to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AirQuality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AirQualityCopyWith<AirQuality> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AirQualityCopyWith<$Res> {
  factory $AirQualityCopyWith(
    AirQuality value,
    $Res Function(AirQuality) then,
  ) = _$AirQualityCopyWithImpl<$Res, AirQuality>;
  @useResult
  $Res call({
    String aqi,
    String level,
    String category,
    String pm10,
    String pm2p5,
    String no2,
    String so2,
    String co,
    String o3,
  });
}

/// @nodoc
class _$AirQualityCopyWithImpl<$Res, $Val extends AirQuality>
    implements $AirQualityCopyWith<$Res> {
  _$AirQualityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AirQuality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? level = null,
    Object? category = null,
    Object? pm10 = null,
    Object? pm2p5 = null,
    Object? no2 = null,
    Object? so2 = null,
    Object? co = null,
    Object? o3 = null,
  }) {
    return _then(
      _value.copyWith(
            aqi: null == aqi
                ? _value.aqi
                : aqi // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            pm10: null == pm10
                ? _value.pm10
                : pm10 // ignore: cast_nullable_to_non_nullable
                      as String,
            pm2p5: null == pm2p5
                ? _value.pm2p5
                : pm2p5 // ignore: cast_nullable_to_non_nullable
                      as String,
            no2: null == no2
                ? _value.no2
                : no2 // ignore: cast_nullable_to_non_nullable
                      as String,
            so2: null == so2
                ? _value.so2
                : so2 // ignore: cast_nullable_to_non_nullable
                      as String,
            co: null == co
                ? _value.co
                : co // ignore: cast_nullable_to_non_nullable
                      as String,
            o3: null == o3
                ? _value.o3
                : o3 // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AirQualityImplCopyWith<$Res>
    implements $AirQualityCopyWith<$Res> {
  factory _$$AirQualityImplCopyWith(
    _$AirQualityImpl value,
    $Res Function(_$AirQualityImpl) then,
  ) = __$$AirQualityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String aqi,
    String level,
    String category,
    String pm10,
    String pm2p5,
    String no2,
    String so2,
    String co,
    String o3,
  });
}

/// @nodoc
class __$$AirQualityImplCopyWithImpl<$Res>
    extends _$AirQualityCopyWithImpl<$Res, _$AirQualityImpl>
    implements _$$AirQualityImplCopyWith<$Res> {
  __$$AirQualityImplCopyWithImpl(
    _$AirQualityImpl _value,
    $Res Function(_$AirQualityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AirQuality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aqi = null,
    Object? level = null,
    Object? category = null,
    Object? pm10 = null,
    Object? pm2p5 = null,
    Object? no2 = null,
    Object? so2 = null,
    Object? co = null,
    Object? o3 = null,
  }) {
    return _then(
      _$AirQualityImpl(
        aqi: null == aqi
            ? _value.aqi
            : aqi // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        pm10: null == pm10
            ? _value.pm10
            : pm10 // ignore: cast_nullable_to_non_nullable
                  as String,
        pm2p5: null == pm2p5
            ? _value.pm2p5
            : pm2p5 // ignore: cast_nullable_to_non_nullable
                  as String,
        no2: null == no2
            ? _value.no2
            : no2 // ignore: cast_nullable_to_non_nullable
                  as String,
        so2: null == so2
            ? _value.so2
            : so2 // ignore: cast_nullable_to_non_nullable
                  as String,
        co: null == co
            ? _value.co
            : co // ignore: cast_nullable_to_non_nullable
                  as String,
        o3: null == o3
            ? _value.o3
            : o3 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AirQualityImpl implements _AirQuality {
  const _$AirQualityImpl({
    required this.aqi,
    required this.level,
    required this.category,
    required this.pm10,
    required this.pm2p5,
    required this.no2,
    required this.so2,
    required this.co,
    required this.o3,
  });

  factory _$AirQualityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AirQualityImplFromJson(json);

  @override
  final String aqi;
  @override
  final String level;
  @override
  final String category;
  @override
  final String pm10;
  @override
  final String pm2p5;
  @override
  final String no2;
  @override
  final String so2;
  @override
  final String co;
  @override
  final String o3;

  @override
  String toString() {
    return 'AirQuality(aqi: $aqi, level: $level, category: $category, pm10: $pm10, pm2p5: $pm2p5, no2: $no2, so2: $so2, co: $co, o3: $o3)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AirQualityImpl &&
            (identical(other.aqi, aqi) || other.aqi == aqi) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.pm10, pm10) || other.pm10 == pm10) &&
            (identical(other.pm2p5, pm2p5) || other.pm2p5 == pm2p5) &&
            (identical(other.no2, no2) || other.no2 == no2) &&
            (identical(other.so2, so2) || other.so2 == so2) &&
            (identical(other.co, co) || other.co == co) &&
            (identical(other.o3, o3) || other.o3 == o3));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    aqi,
    level,
    category,
    pm10,
    pm2p5,
    no2,
    so2,
    co,
    o3,
  );

  /// Create a copy of AirQuality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AirQualityImplCopyWith<_$AirQualityImpl> get copyWith =>
      __$$AirQualityImplCopyWithImpl<_$AirQualityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AirQualityImplToJson(this);
  }
}

abstract class _AirQuality implements AirQuality {
  const factory _AirQuality({
    required final String aqi,
    required final String level,
    required final String category,
    required final String pm10,
    required final String pm2p5,
    required final String no2,
    required final String so2,
    required final String co,
    required final String o3,
  }) = _$AirQualityImpl;

  factory _AirQuality.fromJson(Map<String, dynamic> json) =
      _$AirQualityImpl.fromJson;

  @override
  String get aqi;
  @override
  String get level;
  @override
  String get category;
  @override
  String get pm10;
  @override
  String get pm2p5;
  @override
  String get no2;
  @override
  String get so2;
  @override
  String get co;
  @override
  String get o3;

  /// Create a copy of AirQuality
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AirQualityImplCopyWith<_$AirQualityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherIndices _$WeatherIndicesFromJson(Map<String, dynamic> json) {
  return _WeatherIndices.fromJson(json);
}

/// @nodoc
mixin _$WeatherIndices {
  String get type => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this WeatherIndices to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherIndices
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherIndicesCopyWith<WeatherIndices> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherIndicesCopyWith<$Res> {
  factory $WeatherIndicesCopyWith(
    WeatherIndices value,
    $Res Function(WeatherIndices) then,
  ) = _$WeatherIndicesCopyWithImpl<$Res, WeatherIndices>;
  @useResult
  $Res call({
    String type,
    String name,
    String level,
    String category,
    String text,
  });
}

/// @nodoc
class _$WeatherIndicesCopyWithImpl<$Res, $Val extends WeatherIndices>
    implements $WeatherIndicesCopyWith<$Res> {
  _$WeatherIndicesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherIndices
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = null,
    Object? level = null,
    Object? category = null,
    Object? text = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherIndicesImplCopyWith<$Res>
    implements $WeatherIndicesCopyWith<$Res> {
  factory _$$WeatherIndicesImplCopyWith(
    _$WeatherIndicesImpl value,
    $Res Function(_$WeatherIndicesImpl) then,
  ) = __$$WeatherIndicesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String name,
    String level,
    String category,
    String text,
  });
}

/// @nodoc
class __$$WeatherIndicesImplCopyWithImpl<$Res>
    extends _$WeatherIndicesCopyWithImpl<$Res, _$WeatherIndicesImpl>
    implements _$$WeatherIndicesImplCopyWith<$Res> {
  __$$WeatherIndicesImplCopyWithImpl(
    _$WeatherIndicesImpl _value,
    $Res Function(_$WeatherIndicesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherIndices
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = null,
    Object? level = null,
    Object? category = null,
    Object? text = null,
  }) {
    return _then(
      _$WeatherIndicesImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherIndicesImpl implements _WeatherIndices {
  const _$WeatherIndicesImpl({
    required this.type,
    required this.name,
    required this.level,
    required this.category,
    required this.text,
  });

  factory _$WeatherIndicesImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherIndicesImplFromJson(json);

  @override
  final String type;
  @override
  final String name;
  @override
  final String level;
  @override
  final String category;
  @override
  final String text;

  @override
  String toString() {
    return 'WeatherIndices(type: $type, name: $name, level: $level, category: $category, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherIndicesImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, name, level, category, text);

  /// Create a copy of WeatherIndices
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherIndicesImplCopyWith<_$WeatherIndicesImpl> get copyWith =>
      __$$WeatherIndicesImplCopyWithImpl<_$WeatherIndicesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherIndicesImplToJson(this);
  }
}

abstract class _WeatherIndices implements WeatherIndices {
  const factory _WeatherIndices({
    required final String type,
    required final String name,
    required final String level,
    required final String category,
    required final String text,
  }) = _$WeatherIndicesImpl;

  factory _WeatherIndices.fromJson(Map<String, dynamic> json) =
      _$WeatherIndicesImpl.fromJson;

  @override
  String get type;
  @override
  String get name;
  @override
  String get level;
  @override
  String get category;
  @override
  String get text;

  /// Create a copy of WeatherIndices
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherIndicesImplCopyWith<_$WeatherIndicesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
