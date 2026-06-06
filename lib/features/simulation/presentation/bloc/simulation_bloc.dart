import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/simulation/domain/managers/simulation_manager.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_event.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_state.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_status.dart';

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final SimulationManager _manager;
  StreamSubscription? _statusSubscription;

  SimulationBloc(this._manager) : super(SimulationInitial()) {
    on<StartSimulation>(_onStartSimulation);
    on<PauseSimulation>(_onPauseSimulation);
    on<ResumeSimulation>(_onResumeSimulation);
    on<StopSimulation>(_onStopSimulation);
    on<UpdateSimulationSpeed>(_onUpdateSimulationSpeed);
    on<SimulationStatusUpdated>(_onSimulationStatusUpdated);

    // Listen to status updates from the manager
    _statusSubscription = _manager.currentStatus.listen((status) {
      add(SimulationStatusUpdated(status));
    });
  }

  Future<void> _onStartSimulation(
    StartSimulation event,
    Emitter<SimulationState> emit,
  ) async {
    try {
      // Optimistically emit running state so the UI responds instantly
      emit(SimulationRunning(SimulationStatus(
        status: '1', // Running
        currentTime: DateTime.now().toIso8601String(),
        speedFactor: event.config.speedFactor.toDouble(),
      )));
      
      // The manager handles connecting the hub and calling the start API
      await _manager.runSimulation(event.config);
    } catch (e) {
      emit(SimulationError('Failed to start simulation: $e'));
    }
  }

  Future<void> _onPauseSimulation(
    PauseSimulation event,
    Emitter<SimulationState> emit,
  ) async {
    try {
      await _manager.pause();
    } catch (e) {
      emit(SimulationError('Failed to pause simulation: $e'));
    }
  }

  Future<void> _onResumeSimulation(
    ResumeSimulation event,
    Emitter<SimulationState> emit,
  ) async {
    try {
      await _manager.resume();
    } catch (e) {
      emit(SimulationError('Failed to resume simulation: $e'));
    }
  }

  Future<void> _onStopSimulation(
    StopSimulation event,
    Emitter<SimulationState> emit,
  ) async {
    try {
      await _manager.stop();
      emit(SimulationStopped());
    } catch (e) {
      emit(SimulationError('Failed to stop simulation: $e'));
    }
  }

  Future<void> _onUpdateSimulationSpeed(
    UpdateSimulationSpeed event,
    Emitter<SimulationState> emit,
  ) async {
    try {
      await _manager.updateSpeed(event.speedFactor);
    } catch (e) {
      emit(SimulationError('Failed to update speed: $e'));
    }
  }

  void _onSimulationStatusUpdated(
    SimulationStatusUpdated event,
    Emitter<SimulationState> emit,
  ) {
    final statusStr = event.status.status.toLowerCase();
    if (statusStr == 'paused' || statusStr == '2') {
      emit(SimulationPaused(event.status));
    } else if (statusStr == 'stopped' || statusStr == '0') {
      emit(SimulationStopped());
    } else {
      // Treats 'running' or '1' or anything else as running
      emit(SimulationRunning(event.status));
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
