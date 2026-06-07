import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/usecases/get_driver_analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetDriverAnalyticsUseCase getDriverAnalyticsUseCase;
  // Hardcoded fallback driver id as per instructions
  final String _fallbackDriverId = '1c3d90db-5541-463c-812c-ceaa835379a2';

  AnalyticsBloc({required this.getDriverAnalyticsUseCase}) : super(AnalyticsInitial()) {
    on<FetchAnalytics>((event, emit) async {
      emit(AnalyticsLoading());
      
      final box = Hive.box('app_box');
      final profile = box.get('HIVE_KEY_PROFILE') as Map<dynamic, dynamic>?;
      final driverId = profile?['id'] as String? ?? _fallbackDriverId;

      final result = await getDriverAnalyticsUseCase(driverId);
      result.fold(
        (failure) => emit(AnalyticsError(failure.message)),
        (analytics) => emit(AnalyticsLoaded(analytics)),
      );
    });
  }
}
