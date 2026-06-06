import 'package:equatable/equatable.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripSuccess extends TripState {
  final String message;

  const TripSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object> get props => [message];
}
