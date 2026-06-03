import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';

abstract class LeaderboardRepository {
  Future<List<DriverEntity>> getLeaderboard();
}

