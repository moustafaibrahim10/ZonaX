import 'package:dio/dio.dart';
import 'package:zona_x_16_4/core/error/exceptions.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import '../models/earnings_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getDriverEarnings(String driverId, String period);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  @override
  Future<EarningsModel> getDriverEarnings(String driverId, String period) async {
    try {
      final dio = DioFactory.getDio();
      final response = await dio.get('/drivers/earnings', queryParameters: {
        'driverId': driverId,
        'period': period.toLowerCase(),
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return EarningsModel.fromJson(data);
      } else {
        throw ServerException('Failed to fetch earnings');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
