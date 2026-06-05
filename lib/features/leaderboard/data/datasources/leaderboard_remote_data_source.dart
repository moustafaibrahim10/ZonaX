import 'package:dio/dio.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<DriverEntity>> getLeaderboard();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  @override
  Future<List<DriverEntity>> getLeaderboard() async {
    try {
      final dio = DioFactory.getDio();
      final response = await dio.get('/trips/statistics/drivers');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data['data'] ?? response.data;
        return dataList.map((json) => DriverEntity.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch leaderboard');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }
}
