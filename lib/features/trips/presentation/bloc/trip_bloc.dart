import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';
import '../../data/models/trip_update_dto.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;

  TripBloc({required TripRepository tripRepository}) 
      : _tripRepository = tripRepository,
        super(TripInitial()) {
    on<CreateTripRequested>(_onCreateTripRequested);
    on<UpdateTripRequested>(_onUpdateTripRequested);
    on<DeleteTripRequested>(_onDeleteTripRequested);
    on<StartTripRequested>(_onStartTripRequested);
    on<EndTripRequested>(_onEndTripRequested);
    on<GetTripHistoryRequested>(_onGetTripHistoryRequested);
    on<TestAuditTripRequested>(_onTestAuditTripRequested);
    on<GetTripDetailsRequested>(_onGetTripDetailsRequested);
  }

  Future<void> _onCreateTripRequested(CreateTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.createTrip(event.dto);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (tripId) => emit(TripCreated(tripId, event.dto.fareAmount)),
    );
  }

  Future<void> _onUpdateTripRequested(UpdateTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.updateTrip(event.tripId, event.dto);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (_) => emit(const TripSuccess('Trip updated successfully!')),
    );
  }

  Future<void> _onDeleteTripRequested(DeleteTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.deleteTrip(event.tripId);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (_) => emit(const TripSuccess('Trip deleted successfully!')),
    );
  }

  Future<void> _onStartTripRequested(StartTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.startTrip(event.tripId, event.pickupLocationId, event.dropoffLocationId);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (_) => emit(TripStarted(event.tripId, event.fareAmount)),
    );
  }

  Future<void> _onEndTripRequested(EndTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    // End trip to generate receipt
    final result = await _tripRepository.endTrip(
      event.tripId, 
      event.farePerMinute, 
      event.baseFare, 
      event.surgeMultiplier,
    );
    
    // Check if endTrip was successful, then explicitly update the processStatus in the database
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (receipt) {
        // Run updateTrip in background to actually persist the 'Completed' status
        _tripRepository.updateTrip(
          event.tripId, 
          TripUpdateDto(processStatus: 'Completed'),
        );
        emit(TripCompleted(event.tripId, receipt));
      },
    );
  }

  Future<void> _onGetTripHistoryRequested(GetTripHistoryRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.getTripHistory(event.pageNumber, event.pageSize);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (history) => emit(TripHistoryLoaded(history)),
    );
  }

  Future<void> _onTestAuditTripRequested(TestAuditTripRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.testAuditTrip(event.tripId);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (_) => emit(const TripSuccess('Trip test audit successful!')),
    );
  }

  Future<void> _onGetTripDetailsRequested(GetTripDetailsRequested event, Emitter<TripState> emit) async {
    emit(TripLoading());
    final result = await _tripRepository.getTripById(event.tripId);
    result.fold(
      (failure) => emit(TripError(failure.message)),
      (receipt) => emit(TripDetailsLoaded(receipt)),
    );
  }
}

