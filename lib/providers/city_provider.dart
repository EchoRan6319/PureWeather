import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weather_models.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import 'city_repository.dart';

@immutable
class CityState {
  final List<Location> cities;
  final bool isLoaded;
  final String? errorMessage;

  const CityState({
    required this.cities,
    required this.isLoaded,
    required this.errorMessage,
  });

  Location? get defaultCity {
    if (cities.isEmpty) {
      return null;
    }
    try {
      return cities.firstWhere((city) => city.isDefault);
    } catch (_) {
      return cities.first;
    }
  }
}

class CityController extends StateNotifier<List<Location>> {
  final CityRepository _repository;
  late final Future<void> _ready;

  bool _isLoaded = false;
  String? _errorMessage;

  CityController(this._repository) : super(const <Location>[]) {
    _ready = _load();
  }

  bool get isLoaded => _isLoaded;
  bool get hasCities => state.isNotEmpty;
  int get cityCount => state.length;
  String? get errorMessage => _errorMessage;

  CityState get snapshot => CityState(
        cities: state,
        isLoaded: _isLoaded,
        errorMessage: _errorMessage,
      );

  Location? get defaultCity {
    if (state.isEmpty) {
      return null;
    }
    try {
      return state.firstWhere((city) => city.isDefault);
    } catch (_) {
      return state.first;
    }
  }

  Future<void> _load() async {
    try {
      final store = await _repository.loadStore();
      state = store.cities;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      state = const <Location>[];
    } finally {
      _isLoaded = true;
    }
  }

  Future<void> _ensureReady() async {
    await _ready;
  }

  bool _isSameCity(Location a, Location b) {
    return a.id == b.id || (a.name == b.name && a.adm2 == b.adm2);
  }

  Future<void> _commit(List<Location> nextCities, {String? defaultCityId}) async {
    final normalized = _repository.normalize(
      CityStoreSnapshot(cities: nextCities, defaultCityId: defaultCityId),
    );
    await _repository.saveStore(normalized);
    state = normalized.cities;
    _errorMessage = null;
  }

  Future<void> addCity(Location location) async {
    await _ensureReady();
    final exists = state.any((city) => _isSameCity(city, location));
    if (exists) {
      return;
    }

    final next = [
      ...state,
      location.copyWith(
        isDefault: state.isEmpty,
        sortOrder: state.length,
        isLocated: false,
      ),
    ];
    await _commit(next, defaultCityId: defaultCity?.id ?? location.id);
  }

  Future<void> addCityAndSetDefault(Location location, {bool isLocated = false}) async {
    await _ensureReady();

    final existingIndex = state.indexWhere((city) => _isSameCity(city, location));
    final next = <Location>[...state];

    if (existingIndex >= 0) {
      final existing = next[existingIndex];
      next[existingIndex] = location.copyWith(
        sortOrder: existing.sortOrder,
        isDefault: true,
        isLocated: isLocated || existing.isLocated,
      );
    } else {
      next.add(
        location.copyWith(
          isDefault: true,
          isLocated: isLocated,
          sortOrder: next.length,
        ),
      );
    }

    if (isLocated) {
      for (var i = 0; i < next.length; i++) {
        if (next[i].id != location.id) {
          next[i] = next[i].copyWith(isLocated: false);
        }
      }
    }

    await _commit(next, defaultCityId: location.id);
  }

  Future<void> removeCity(String cityId) async {
    await _ensureReady();
    final existingIndex = state.indexWhere((city) => city.id == cityId);
    if (existingIndex < 0) {
      return;
    }

    final removed = state[existingIndex];
    final next = state.where((city) => city.id != cityId).toList();

    if (next.isEmpty) {
      await _commit(const <Location>[], defaultCityId: null);
      return;
    }

    String? nextDefaultId = defaultCity?.id;
    if (removed.isDefault || nextDefaultId == cityId) {
      final located = next.where((city) => city.isLocated).toList();
      nextDefaultId = located.isNotEmpty ? located.first.id : next.first.id;
    }

    await _commit(next, defaultCityId: nextDefaultId);
  }

  Future<void> setDefaultCity(String cityId) async {
    await _ensureReady();
    if (!state.any((city) => city.id == cityId)) {
      return;
    }
    await _commit(state, defaultCityId: cityId);
  }

  Future<void> updateDefaultCity(Location newLocation) async {
    await _ensureReady();
    final currentDefault = defaultCity;
    if (currentDefault == null) {
      await addCityAndSetDefault(newLocation, isLocated: newLocation.isLocated);
      return;
    }

    final next = <Location>[...state];
    final defaultIndex = next.indexWhere((city) => city.id == currentDefault.id);
    if (defaultIndex < 0) {
      await addCityAndSetDefault(newLocation, isLocated: newLocation.isLocated);
      return;
    }

    next[defaultIndex] = newLocation.copyWith(
      isDefault: true,
      sortOrder: next[defaultIndex].sortOrder,
      isLocated: next[defaultIndex].isLocated || newLocation.isLocated,
    );

    if (next[defaultIndex].isLocated) {
      for (var i = 0; i < next.length; i++) {
        if (i != defaultIndex) {
          next[i] = next[i].copyWith(isLocated: false);
        }
      }
    }

    await _commit(next, defaultCityId: next[defaultIndex].id);
  }

  Future<void> reorderCities(int oldIndex, int newIndex) async {
    await _ensureReady();
    if (state.isEmpty) {
      return;
    }
    if (oldIndex < 0 ||
        oldIndex >= state.length ||
        newIndex < 0 ||
        newIndex >= state.length) {
      return;
    }

    final next = [...state];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);

    await _commit(next, defaultCityId: defaultCity?.id);
  }
}

final cityRepositoryProvider = Provider<CityRepository>((ref) => CityRepository());

final cityManagerProvider = StateNotifierProvider<CityController, List<Location>>((ref) {
  final repository = ref.watch(cityRepositoryProvider);
  return CityController(repository);
});

final cityStateProvider = Provider<CityState>((ref) {
  ref.watch(cityManagerProvider);
  return ref.watch(cityManagerProvider.notifier).snapshot;
});

final defaultCityProvider = Provider<Location?>((ref) {
  final cities = ref.watch(cityManagerProvider);
  if (cities.isEmpty) {
    return null;
  }
  try {
    return cities.firstWhere((city) => city.isDefault);
  } catch (_) {
    return cities.first;
  }
});

@immutable
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

  Future<void> initLocation({bool force = false}) async {
    if (state.isInitialized && !force) {
      return;
    }

    if (force) {
      state = state.copyWith(isInitialized: false);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final locationService = _ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      final appSettings = _ref.read(settingsProvider);
      final cityController = _ref.read(cityManagerProvider.notifier);
      final currentDefaultCity = _ref.read(defaultCityProvider);

      if (position != null) {
        final location = await locationService.getLocationFromCoords(
          position.latitude,
          position.longitude,
          accuracyLevel: appSettings.locationAccuracyLevel,
        );

        var shouldSwitch = false;
        if (currentDefaultCity == null) {
          shouldSwitch = true;
        } else {
          final latDiff = (location.lat - currentDefaultCity.lat).abs();
          final lonDiff = (location.lon - currentDefaultCity.lon).abs();
          shouldSwitch = latDiff > 0.01 || lonDiff > 0.01;
        }

        if (shouldSwitch) {
          await cityController.addCityAndSetDefault(location, isLocated: true);
        }

        state = LocationInitState(
          isInitialized: true,
          currentLocation: location,
        );
      } else {
        state = const LocationInitState(
          isInitialized: true,
          error: 'Unable to get location',
        );
      }
    } catch (e) {
      state = LocationInitState(
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final locationService = _ref.read(locationServiceProvider);
      return await locationService.checkAndRequestPermission();
    } catch (_) {
      return false;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

final locationInitProvider = StateNotifierProvider<LocationInitNotifier, LocationInitState>(
  (ref) => LocationInitNotifier(ref),
);
