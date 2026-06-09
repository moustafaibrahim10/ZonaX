import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:zona_x_16_4/features/map/domain/entities/zone_entity.dart';
import 'package:zona_x_16_4/features/map/domain/entities/driver_location_entity.dart';
import 'package:zona_x_16_4/features/map/domain/repositories/map_repository.dart';
import 'package:zona_x_16_4/features/map/data/datasources/hive_local_data_source.dart';
import 'package:zona_x_16_4/features/map/data/models/trip_log_model.dart';
part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final MapRepository repository;
  final LocalDataSource localDataSource;
  Timer? _simulationTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool isConnected = true;

  MapCubit(this.repository, this.localDataSource) : super(MapInitial()) {
    _initLocalDataSource();
    _initConnectivity();
  }

  Future<void> _initLocalDataSource() async {
    await localDataSource.init();
  }

  Future<void> getZones() async {
    emit(MapLoading());
    try {
      final zones = await repository.getActiveZones();
      emit(MapZonesLoaded(zones));
    } catch (e) {
      emit(MapError("Failed to load zones: ${e.toString()}"));
    }
  }

  void flyToZone(double lat, double lng) {
    emit(MapFlyToLocation(lat, lng));
  }

  void _initConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isNowConnected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      
      if (isConnected != isNowConnected) {
        isConnected = isNowConnected;
        emit(MapConnectivityChanged(isConnected));
        
        if (isConnected) {
          // Connection Restored -> Sync data
          localDataSource.getUnsyncedLogs().then((unsynced) {
            debugPrint("Syncing ${unsynced.length} offline logs to server...");
            localDataSource.markLogsAsSynced();
          });
        } else {
          debugPrint("Connection Lost! Entering Offline Edge Mode.");
        }
      }
    });
  }

  bool isSimulating = false;

  void toggleSimulation() {
    if (isSimulating) {
      stopCarSimulation();
    } else {
      startCarSimulation([]);
    }
  }

  double _tripSpeed = 1.0;
  double get tripSpeed => _tripSpeed;
  List<Map<String, double>> _currentRoute = [];
  int _currentIndex = 0;

  void setTripSpeed(double speed) {
    _tripSpeed = speed;
    if (isSimulating && _currentRoute.isNotEmpty) {
      // Restart timer with new speed
      _startSimulationTimer();
    }
  }

  void startCarSimulation(List<Map<String, double>> route) {
    if (route.isEmpty) return;

    _currentRoute = route;
    _currentIndex = 0;
    isSimulating = true;
    _startSimulationTimer();
  }

  void _startSimulationTimer() {
    _simulationTimer?.cancel();
    
    final interval = (600 / _tripSpeed).toInt();
    _simulationTimer = Timer.periodic(Duration(milliseconds: interval), (timer) async {
      if (_currentIndex < _currentRoute.length) {
        final currentLat = _currentRoute[_currentIndex]['lat']!;
        final currentLng = _currentRoute[_currentIndex]['lng']!;

        double currentBearing = 0.0;
        if (_currentIndex < _currentRoute.length - 1) {
          final nextLat = _currentRoute[_currentIndex + 1]['lat']!;
          final nextLng = _currentRoute[_currentIndex + 1]['lng']!;
          currentBearing = _calculateBearing(currentLat, currentLng, nextLat, nextLng);
        }

        final location = DriverLocationEntity(
          lat: currentLat,
          lng: currentLng,
          timestamp: DateTime.now(),
          isOffline: !isConnected,
        );

        if (!isConnected) {
          await localDataSource.saveTripLog(
            TripLogModel(
              lat: location.lat,
              lng: location.lng,
              timestamp: location.timestamp,
            ),
          );
        }

        emit(MapCarMoving(lat: location.lat, lng: location.lng, bearing: currentBearing));
        _currentIndex++;
      } else {
        stopCarSimulation();
        emit(MapSimulationCompleted());
      }
    });
  }

  double _calculateBearing(double startLat, double startLng, double endLat, double endLng) {
    // Basic bearing calculation
    final dLng = (endLng - startLng) * math.pi / 180.0;
    final startLatRad = startLat * math.pi / 180.0;
    final endLatRad = endLat * math.pi / 180.0;

    final y = math.sin(dLng) * math.cos(endLatRad);
    final x = math.cos(startLatRad) * math.sin(endLatRad) -
        math.sin(startLatRad) * math.cos(endLatRad) * math.cos(dLng);
    
    final brng = math.atan2(y, x);
    return (brng * 180.0 / math.pi + 360.0) % 360.0;
  }

  void stopCarSimulation({bool emitCompletion = false}) {
    isSimulating = false;
    _simulationTimer?.cancel();
    if (emitCompletion) {
      emit(MapSimulationCompleted());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _simulationTimer?.cancel();
    return super.close();
  }
}
