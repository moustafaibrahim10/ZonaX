import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/trip_service.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripService _tripService;

  TripBloc({TripService? tripService}) 
      : _tripService = tripService ?? TripService(),
        super(TripInitial()) {
    on<CreateTripRequested>(_onCreateTripRequested);
    on<UpdateTripRequested>(_onUpdateTripRequested);
    on<DeleteTripRequested>(_onDeleteTripRequested);
  }

  Future<void> _onCreateTripRequested(CreateTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      await _tripService.createTrip(event.dto);
      emit(const TripSuccess('Trip created successfully!'));
    } on TripException catch (e) {
      emit(TripError(e.message));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onUpdateTripRequested(UpdateTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      await _tripService.updateTrip(event.tripId, event.dto);
      emit(const TripSuccess('Trip updated successfully!'));
    } on TripException catch (e) {
      emit(TripError(e.message));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onDeleteTripRequested(DeleteTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      await _tripService.deleteTrip(event.tripId);
      emit(const TripSuccess('Trip deleted successfully!'));
    } on TripException catch (e) {
      emit(TripError(e.message));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}
