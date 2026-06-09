import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';
import 'package:zona_x_16_4/features/leaderboard/domain/repositories/leaderboard_repository.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final LeaderboardRepository repository;

  LeaderboardCubit(this.repository) : super(LeaderboardInitial());

  Future<void> getLeaderboard() async {
    try {
      emit(LeaderboardLoading());
      final drivers = await repository.getLeaderboard();
      emit(LeaderboardLoaded(drivers));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}

