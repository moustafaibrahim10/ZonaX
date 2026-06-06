import 'package:equatable/equatable.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_config.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_status.dart';

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();

  @override
  List<Object?> get props => [];
}

class StartSimulation extends SimulationEvent {
  final SimulationConfig config;

  const StartSimulation(this.config);

  @override
  List<Object?> get props => [config];
}

class PauseSimulation extends SimulationEvent {}

class ResumeSimulation extends SimulationEvent {}

class StopSimulation extends SimulationEvent {}

class UpdateSimulationSpeed extends SimulationEvent {
  final double speedFactor;

  const UpdateSimulationSpeed(this.speedFactor);

  @override
  List<Object?> get props => [speedFactor];
}

class SimulationStatusUpdated extends SimulationEvent {
  final SimulationStatus status;

  const SimulationStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}
