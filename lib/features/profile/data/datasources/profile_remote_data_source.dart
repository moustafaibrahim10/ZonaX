import 'package:dio/dio.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/network/api_constants.dart';
import '../models/driver_profile_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<DriverProfileModel> getDriverProfile();
  Future<bool> updateDriverStatus(String status, double lat, double lng);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl() : _dio = DioFactory.getDio();

  @override
  Future<DriverProfileModel> getDriverProfile() async {
    // Temporary fallback solution as per requirements
    const fallbackDriverId = '559a7baf-4163-4353-852b-bf5091e20ffc';
    
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/drivers/$fallbackDriverId');
      
      if (response.statusCode == 200) {
        // Handle case where API response wraps data inside a "data" field or directly returns it
        final dynamic responseData = response.data['data'] ?? response.data;
        return DriverProfileModel.fromJson(responseData);
      } else {
        throw ServerException('Failed to load profile');
      }
    } catch (e) {
      if (e is DioException) {
        throw ServerException(e.message ?? 'Failed to load profile');
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateDriverStatus(String status, double lat, double lng) async {
    const fallbackDriverId = '559a7baf-4163-4353-852b-bf5091e20ffc';
    try {
      final response = await _dio.put(
        '${ApiConstants.baseUrl}/drivers/$fallbackDriverId/status',
        data: {
          'status': status,
          'currentLat': lat,
          'currentLng': lng,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw ServerException('Failed to update driver status');
      }
    } catch (e) {
      if (e is DioException) {
        throw ServerException(e.message ?? 'Failed to update driver status');
      }
      throw ServerException(e.toString());
    }
  }
}
