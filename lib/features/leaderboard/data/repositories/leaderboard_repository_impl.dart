import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';
import 'package:zona_x_16_4/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zona_x_16_4/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'package:zona_x_16_4/features/leaderboard/data/datasources/leaderboard_mock_data_source.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  @override
  Future<List<DriverEntity>> getLeaderboard() async {
    try {
      // Attempt to fetch real data from API
      final remoteDataSource = LeaderboardRemoteDataSourceImpl();
      return await remoteDataSource.getLeaderboard();
    } catch (e) {
      // Fallback to mock data if API call fails
      // ignore: avoid_print
      print('Remote leaderboard fetch failed: $e. Using mock data.');
      return await LeaderboardMockDataSource.getLeaderboard();
    }
  }
}

