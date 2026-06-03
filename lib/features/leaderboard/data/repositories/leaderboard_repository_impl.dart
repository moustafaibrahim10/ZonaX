import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';
import 'package:zona_x_16_4/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zona_x_16_4/features/leaderboard/data/datasources/leaderboard_mock_data_source.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  @override
  Future<List<DriverEntity>> getLeaderboard() async {
    // Currently using mock data
    // TODO: Replace with actual API call when backend is ready
    return await LeaderboardMockDataSource.getLeaderboard();
  }
}

