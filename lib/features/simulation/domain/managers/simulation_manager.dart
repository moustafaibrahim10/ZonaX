import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:zona_x_16_4/features/simulation/data/datasources/signalr_simulation_hub.dart';
import 'package:zona_x_16_4/features/simulation/data/datasources/simulation_service.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_config.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_status.dart';

class SimulationManager {
  final SimulationService _simulationService;
  final SignalRSimulationHub _hub;

  // Singleton pattern
  static SimulationManager? _instance;

  factory SimulationManager(
    SimulationService simulationService,
    SignalRSimulationHub hub,
  ) {
    _instance ??= SimulationManager._internal(simulationService, hub);
    return _instance!;
  }

  SimulationManager._internal(this._simulationService, this._hub);

  Stream<SimulationStatus> get currentStatus => _hub.statusStream;

  Future<void> runSimulation(SimulationConfig config) async {
    try {
      // 1. Connect to Hub (Handshake handled inside)
      await _hub.connect();

      // 2. Start the simulation API
      debugPrint('SIMULATION REQUEST: ${jsonEncode(config.toJson())}');
      await _simulationService.startSimulation(config);
      
    } catch (e) {
      debugPrint('Error starting simulation: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _simulationService.pauseSimulation();
    } catch (e) {
      debugPrint('Error pausing simulation: $e');
      rethrow;
    }
  }

  Future<void> resume() async {
    try {
      await _simulationService.resumeSimulation();
    } catch (e) {
      debugPrint('Error resuming simulation: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _simulationService.stopSimulation();
      await _hub.disconnect();
    } catch (e) {
      debugPrint('Error stopping simulation: $e');
      rethrow;
    }
  }

  Future<void> updateSpeed(double speedFactor) async {
    try {
      await _simulationService.updateSpeed({'speedFactor': speedFactor});
    } catch (e) {
      debugPrint('Error updating simulation speed: $e');
      rethrow;
    }
  }

  void dispose() {
    _hub.dispose();
  }
}
