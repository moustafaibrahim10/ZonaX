import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/driver_profile_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<DriverProfileModel> getDriverProfile();
  Future<bool> updateDriverStatus(String status, double lat, double lng);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl() : _dio = DioFactory.getDio();

  Future<String> _getDriverId() async {
    try {
      final box = Hive.box('app_box');
      final profileData = box.get('HIVE_KEY_PROFILE');
      if (profileData != null && profileData['id'] != null) {
        return profileData['id'] as String;
      }
    } catch (e) {
      // Ignored, fallback to default
    }
    // Fallback if not logged in properly or no ID is available
    return '1c3d90db-5541-463c-812c-ceaa835379a2';
  }

  @override
  Future<DriverProfileModel> getDriverProfile() async {
    try {
      final driverId = await _getDriverId();
      final response = await _dio.get('/drivers/$driverId');
      
      if (response.statusCode == 200 && response.data['isSuccess'] == true) {
        final dynamic responseData = response.data['data'] ?? response.data;
        return DriverProfileModel.fromJson(responseData);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      if (e is DioException) {
        throw ServerException(e.response?.data['message'] ?? e.message ?? 'Failed to load profile');
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateDriverStatus(String status, double lat, double lng) async {
    try {
      final driverId = await _getDriverId();
      final response = await _dio.put(
        '/drivers/$driverId/status',
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
        throw ServerException(e.response?.data['message'] ?? e.message ?? 'Failed to update driver status');
      }
      throw ServerException(e.toString());
    }
  }
}
