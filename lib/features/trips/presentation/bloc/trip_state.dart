import 'package:equatable/equatable.dart';
import '../../data/models/trip_receipt_model.dart';
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
  final double fareAmount;

  const TripCreated(this.tripId, this.fareAmount);

  @override
  List<Object?> get props => [tripId, fareAmount];
}

class TripStarted extends TripState {
  final String tripId;
  final double fareAmount;

  const TripStarted(this.tripId, this.fareAmount);

  @override
  List<Object?> get props => [tripId, fareAmount];
}

class TripCompleted extends TripState {
  final String tripId;
  final TripReceiptModel receipt;

  const TripCompleted(this.tripId, this.receipt);

  @override
  List<Object?> get props => [tripId, receipt];
}

class TripHistoryLoaded extends TripState {
  final PaginatedTripHistory history;

  const TripHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class TripDetailsLoaded extends TripState {
  final TripReceiptModel receipt;

  const TripDetailsLoaded(this.receipt);

  @override
  List<Object?> get props => [receipt];
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

