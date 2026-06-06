import 'package:equatable/equatable.dart';
import '../../data/models/trip_create_dto.dart';
import '../../data/models/trip_update_dto.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class CreateTripRequested extends TripEvent {
  final TripCreateDto dto;

  const CreateTripRequested(this.dto);

  @override
  List<Object?> get props => [dto];
}

class UpdateTripRequested extends TripEvent {
  final String tripId;
  final TripUpdateDto dto;

  const UpdateTripRequested(this.tripId, this.dto);

  @override
  List<Object?> get props => [tripId, dto];
}

class DeleteTripRequested extends TripEvent {
  final String tripId;

  const DeleteTripRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class StartTripRequested extends TripEvent {
  final String tripId;

  const StartTripRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class EndTripRequested extends TripEvent {
  final String tripId;

  const EndTripRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class GetTripHistoryRequested extends TripEvent {
  final int pageNumber;
  final int pageSize;

  const GetTripHistoryRequested({this.pageNumber = 1, this.pageSize = 10});

  @override
  List<Object?> get props => [pageNumber, pageSize];
}

class TestAuditTripRequested extends TripEvent {
  final String tripId;

  const TestAuditTripRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

