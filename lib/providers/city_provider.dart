import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';
import '../services/location_service.dart';
import '../providers/settings_provider.dart';

class CityManager extends StateNotifier<List<Location>> {
  static const String _keyCities = 'saved_cities';
  static const String _keyDefaultCityId = 'default_city_id';

  bool _isLoaded = false;

  CityManager() : super([]) {
    _loadCities();
  }

  bool get isLoaded => _isLoaded;

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getString(_keyCities);

    if (citiesJson != null) {
      final List<dynamic> decoded = jsonDecode(citiesJson);
      state = decoded.map((e) => Location.fromJson(e)).toList();
    }
    _isLoaded = true;
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_keyCities, citiesJson);
  }

  Future<void> addCity(Location location) async {
    if (state.any((city) => city.id == location.id)) {
      return;
    }

    final newCity = location.copyWith(
      sortOrder: state.length,
      isDefault: state.isEmpty,
    );

    state = [...state, newCity];
    await _saveCities();
  }

  Future<void> addCityAndSetDefault(Location location) async {
    if (state.any((city) => city.id == location.id)) {
      await setDefaultCity(location.id);
      return;
    }

    state = state.map((city) => city.copyWith(isDefault: false)).toList();

    final newCity = location.copyWith(sortOrder: state.length, isDefault: true);

    state = [...state, newCity];
    await _saveCities();
  }

  Future<void> removeCity(String cityId) async {
    final cityToRemove = state.firstWhere((c) => c.id == cityId);
    final wasDefault = cityToRemove.isDefault;

    state = state.where((city) => city.id != cityId).toList();

    if (wasDefault && state.isNotEmpty) {
      state = [state.first.copyWith(isDefault: true), ...state.skip(1)];
    }

    await _saveCities();
  }

  Future<void> setDefaultCity(String cityId) async {
    state = state.map((city) {
      return city.copyWith(isDefault: city.id == cityId);
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultCityId, cityId);
    await _saveCities();
  }

  Future<void> updateDefaultCity(Location newLocation) async {
    state = state.map((city) {
      if (city.isDefault) {
        return newLocation.copyWith(isDefault: true, sortOrder: city.sortOrder);
      }
      return city;
    }).toList();

    await _saveCities();
  }

  Future<void> reorderCities(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final newCities = List<Location>.from(state);
    final city = newCities.removeAt(oldIndex);
    newCities.insert(newIndex, city);

    state = newCities.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    await _saveCities();
  }

  Location? get defaultCity {
    try {
      return state.firstWhere((city) => city.isDefault);
    } catch (_) {
      return state.isNotEmpty ? state.first : null;
    }
  }

  bool get hasCities => state.isNotEmpty;

  int get cityCount => state.length;
}

final cityManagerProvider = StateNotifierProvider<CityManager, List<Location>>((
  ref,
) {
  return CityManager();
});

final defaultCityProvider = Provider<Location?>((ref) {
  final cities = ref.watch(cityManagerProvider);

  if (cities.isEmpty) {
    return null;
  }

  try {
    return cities.firstWhere((city) => city.isDefault);
  } catch (_) {
    return cities.isNotEmpty ? cities.first : null;
  }
});

class LocationInitState {
  final bool isInitialized;
  final Location? currentLocation;
  final String? error;

  const LocationInitState({
    this.isInitialized = false,
    this.currentLocation,
    this.error,
  });

  LocationInitState copyWith({
    bool? isInitialized,
    Location? currentLocation,
    String? error,
  }) {
    return LocationInitState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error,
    );
  }
}

class LocationInitNotifier extends StateNotifier<LocationInitState> {
  final Ref _ref;

  LocationInitNotifier(this._ref) : super(const LocationInitState());

  Future<void> initLocation() async {
    if (state.isInitialized) return;

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final locationService = _ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      final appSettings = _ref.read(settingsProvider);
      final cityManagerNotifier = _ref.read(cityManagerProvider.notifier);
      final currentDefaultCity = _ref.read(defaultCityProvider);

      if (position != null) {
        final location = await locationService.getLocationFromCoords(
          position.latitude,
          position.longitude,
          accuracyLevel: appSettings.locationAccuracyLevel,
        );

        bool shouldSwitch = false;

        if (currentDefaultCity == null) {
          shouldSwitch = true;
        } else {
          final latDiff = (location.lat - currentDefaultCity.lat).abs();
          final lonDiff = (location.lon - currentDefaultCity.lon).abs();
          shouldSwitch = latDiff > 0.01 || lonDiff > 0.01;
        }

        if (shouldSwitch) {
          await cityManagerNotifier.addCityAndSetDefault(location);
        }

        state = LocationInitState(
          isInitialized: true,
          currentLocation: location,
        );
      } else {
        state = LocationInitState(isInitialized: true, error: '无法获取位置');
      }
    } catch (e) {
      state = LocationInitState(isInitialized: true, error: e.toString());
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final locationService = _ref.read(locationServiceProvider);
      final hasPermission = await locationService.checkAndRequestPermission();
      return hasPermission;
    } catch (e) {
      return false;
    }
  }
}

final locationServiceProvider = Provider((ref) {
  return LocationService();
});

final locationInitProvider =
    StateNotifierProvider<LocationInitNotifier, LocationInitState>((ref) {
      return LocationInitNotifier(ref);
    });
