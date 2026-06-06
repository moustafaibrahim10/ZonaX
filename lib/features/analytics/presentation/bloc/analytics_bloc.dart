import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_driver_analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetDriverAnalyticsUseCase getDriverAnalyticsUseCase;
  // Hardcoded fallback driver id as per instructions
  final String _fallbackDriverId = '49a07bbc-b80a-4d36-b171-3a9c29bd6ff3';

  AnalyticsBloc({required this.getDriverAnalyticsUseCase}) : super(AnalyticsInitial()) {
    on<FetchAnalytics>((event, emit) async {
      emit(AnalyticsLoading());
      final result = await getDriverAnalyticsUseCase(_fallbackDriverId);
      result.fold(
        (failure) => emit(AnalyticsError(failure.message)),
        (analytics) => emit(AnalyticsLoaded(analytics)),
      );
    });
  }
}
