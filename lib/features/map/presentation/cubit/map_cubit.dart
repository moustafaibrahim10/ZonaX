import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool isConnected = true;

  MapCubit(this.repository, this.localDataSource) : super(MapInitial()) {
    _initLocalDataSource();
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
      emit(MapError("فشل في تحميل الزونات: ${e.toString()}"));
    }
  }

  // Simulate network connection toggle
  void toggleConnection() async {
    isConnected = !isConnected;
    if (isConnected) {
      // Connection Restored -> Sync data
      final unsynced = await localDataSource.getUnsyncedLogs();
      debugPrint("Syncing ${unsynced.length} offline logs to server...");
      await localDataSource.markLogsAsSynced();
    } else {
      debugPrint("Connection Lost! Entering Offline Edge Mode.");
    }
  }

  bool isSimulating = false;

  void toggleSimulation() {
    if (isSimulating) {
      stopCarSimulation();
    } else {
      startCarSimulation();
    }
  }

  void startCarSimulation() {
    isSimulating = true;
    // Real-world street trace in El Shorouk
    final route = [
      {'lat': 30.14488, 'lng': 31.63581},
      {'lat': 30.14498, 'lng': 31.63559},
      {'lat': 30.14506, 'lng': 31.63539},
      {'lat': 30.14515, 'lng': 31.63519},
      {'lat': 30.14524, 'lng': 31.63499},
      {'lat': 30.14532, 'lng': 31.63479},
      // Taking a curve along the road
      {'lat': 30.14538, 'lng': 31.63460},
      {'lat': 30.14540, 'lng': 31.63440},
      {'lat': 30.14540, 'lng': 31.63420},
      {'lat': 30.14538, 'lng': 31.63400},
      // Continuing on the new street
      {'lat': 30.14534, 'lng': 31.63380},
      {'lat': 30.14529, 'lng': 31.63360},
      {'lat': 30.14520, 'lng': 31.63340},
      {'lat': 30.14510, 'lng': 31.63320},
      {'lat': 30.14498, 'lng': 31.63300},
    ];

    int index = 0;
    _simulationTimer?.cancel();
    // Speed up: Update every 1 second
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (index < route.length) {
        final currentLat = route[index]['lat']!;
        final currentLng = route[index]['lng']!;
        
        final location = DriverLocationEntity(
          lat: currentLat,
          lng: currentLng,
          timestamp: DateTime.now(),
          isOffline: !isConnected,
        );

        if (!isConnected) {
          // Store locally via Hive
          await localDataSource.saveTripLog(TripLogModel(
            lat: location.lat,
            lng: location.lng,
            timestamp: location.timestamp,
          ));
        }

        emit(MapCarMoving(
          lat: location.lat,
          lng: location.lng,
          bearing: 45.0,
        ));
        
        index++;
      } else {
        stopCarSimulation();
      }
    });
  }

  void stopCarSimulation() {
    isSimulating = false;
    _simulationTimer?.cancel();
    // Emit state if you want to notify UI that it stopped
    // emit(MapSimulationStopped());
  }

  @override
  Future<void> close() {
    _simulationTimer?.cancel();
    return super.close();
  }
}
