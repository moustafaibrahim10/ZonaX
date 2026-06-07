import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/usecases/get_earnings_usecase.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final GetEarningsUseCase getEarningsUseCase;
  final String _fallbackDriverId = '1c3d90db-5541-463c-812c-ceaa835379a2';

  EarningsBloc({required this.getEarningsUseCase}) : super(EarningsInitial()) {
    on<FetchEarnings>((event, emit) async {
      emit(EarningsLoading());
      
      final box = Hive.box('app_box');
      final profile = box.get('HIVE_KEY_PROFILE') as Map<dynamic, dynamic>?;
      final driverId = profile?['id'] as String? ?? _fallbackDriverId;

      final result = await getEarningsUseCase(driverId, event.period);
      result.fold(
        (failure) => emit(EarningsError(failure.message)),
        (earnings) => emit(EarningsLoaded(earnings)),
      );
    });
  }
}
