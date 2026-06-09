import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/zone_repository.dart';
import 'recommended_zones_event.dart';
import 'recommended_zones_state.dart';

class RecommendedZonesBloc extends Bloc<RecommendedZonesEvent, RecommendedZonesState> {
  final ZoneRepository repository;

  RecommendedZonesBloc({required this.repository}) : super(RecommendedZonesInitial()) {
    on<FetchRecommendedZones>(_onFetchRecommendedZones);
  }

  Future<void> _onFetchRecommendedZones(FetchRecommendedZones event, Emitter<RecommendedZonesState> emit) async {
    emit(RecommendedZonesLoading());
    final result = await repository.getRecommendedZones();
    result.fold(
      (failure) => emit(RecommendedZonesError(failure.message)),
      (zones) => emit(RecommendedZonesLoaded(zones)),
    );
  }
}
