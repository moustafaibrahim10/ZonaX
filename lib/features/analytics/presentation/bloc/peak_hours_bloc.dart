import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/peak_hour_model.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';

// --- Events ---
abstract class PeakHoursEvent extends Equatable {
  const PeakHoursEvent();

  @override
  List<Object?> get props => [];
}

class FetchPeakHours extends PeakHoursEvent {}

// --- States ---
abstract class PeakHoursState extends Equatable {
  const PeakHoursState();

  @override
  List<Object?> get props => [];
}

class PeakHoursInitial extends PeakHoursState {}

class PeakHoursLoading extends PeakHoursState {}

class PeakHoursLoaded extends PeakHoursState {
  final List<PeakHourModel> peakHours;

  const PeakHoursLoaded(this.peakHours);

  @override
  List<Object?> get props => [peakHours];
}

class PeakHoursError extends PeakHoursState {
  final String message;

  const PeakHoursError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class PeakHoursBloc extends Bloc<PeakHoursEvent, PeakHoursState> {
  final ZoneRepository repository;

  PeakHoursBloc({required this.repository}) : super(PeakHoursInitial()) {
    on<FetchPeakHours>(_onFetchPeakHours);
  }

  Future<void> _onFetchPeakHours(FetchPeakHours event, Emitter<PeakHoursState> emit) async {
    emit(PeakHoursLoading());
    final result = await repository.getPeakHours();
    result.fold(
      (failure) => emit(PeakHoursError(failure.message)),
      (peakHours) {
        // Filter out past hours or empty hours if needed, but for now we'll just show them all.
        // Wait, the UI shows a list. 24 hours is too long. Let's just return the top hours,
        // or filter by predictedTripCount > 0, and sort by hour.
        final validHours = peakHours.where((h) => h.predictedTripCount > 0).toList();
        validHours.sort((a, b) => a.hour.compareTo(b.hour));
        
        // Show up to 5 peak hours to keep UI clean
        final topHours = validHours.take(5).toList();
        
        emit(PeakHoursLoaded(topHours.isEmpty ? peakHours.take(5).toList() : topHours));
      },
    );
  }
}
