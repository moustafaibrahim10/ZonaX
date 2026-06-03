import 'package:dio/dio.dart';
import 'package:zona_x_16_4/core/error/exceptions.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsModel> getDriverAnalytics(String driverId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  @override
  Future<AnalyticsModel> getDriverAnalytics(String driverId) async {
    try {
      final dio = DioFactory.getDio();
      final response = await dio.get('/drivers/analytics', queryParameters: {
        'driverId': driverId,
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return AnalyticsModel.fromJson(data);
      } else {
        throw ServerException('Failed to fetch analytics');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
