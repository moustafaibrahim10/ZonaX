import 'package:equatable/equatable.dart';
import '../../data/models/trip_model.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripCreated extends TripState {
  final String tripId;

  const TripCreated(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripStarted extends TripState {
  final String tripId;

  const TripStarted(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripCompleted extends TripState {
  final String tripId;

  const TripCompleted(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripHistoryLoaded extends TripState {
  final PaginatedTripHistory history;

  const TripHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class TripSuccess extends TripState {
  final String message;

  const TripSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}

