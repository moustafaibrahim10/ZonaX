import 'package:equatable/equatable.dart';
import '../../data/models/trip_create_dto.dart';
import '../../data/models/trip_update_dto.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object> get props => [];
}

class CreateTripRequested extends TripEvent {
  final TripCreateDto dto;

  const CreateTripRequested(this.dto);

  @override
  List<Object> get props => [dto];
}

class UpdateTripRequested extends TripEvent {
  final int tripId;
  final TripUpdateDto dto;

  const UpdateTripRequested(this.tripId, this.dto);

  @override
  List<Object> get props => [tripId, dto];
}

class DeleteTripRequested extends TripEvent {
  final int tripId;

  const DeleteTripRequested(this.tripId);

  @override
  List<Object> get props => [tripId];
}
