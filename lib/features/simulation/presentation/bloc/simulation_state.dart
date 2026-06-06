import 'package:equatable/equatable.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_status.dart';

abstract class SimulationState extends Equatable {
  const SimulationState();

  @override
  List<Object?> get props => [];
}

class SimulationInitial extends SimulationState {}

class SimulationRunning extends SimulationState {
  final SimulationStatus status;

  const SimulationRunning(this.status);

  @override
  List<Object?> get props => [status];
}

class SimulationPaused extends SimulationState {
  final SimulationStatus status;

  const SimulationPaused(this.status);

  @override
  List<Object?> get props => [status];
}

class SimulationStopped extends SimulationState {}

class SimulationError extends SimulationState {
  final String message;

  const SimulationError(this.message);

  @override
  List<Object?> get props => [message];
}
