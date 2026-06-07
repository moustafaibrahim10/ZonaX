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

  @override
  Future<DriverProfileModel> getDriverProfile() async {
    // Temporary fallback solution as per requirements
    final box = Hive.box('app_box');
    final profile = box.get('HIVE_KEY_PROFILE') as Map<dynamic, dynamic>?;
    final fallbackDriverId = profile?['id'] as String? ?? '1c3d90db-5541-463c-812c-ceaa835379a2';
    
    try {
      final response = await _dio.get('/drivers/$fallbackDriverId');
      
      if (response.statusCode == 200) {
        // Handle case where API response wraps data inside a "data" field or directly returns it
        final dynamic responseData = response.data['data'] ?? response.data;
        var model = DriverProfileModel.fromJson(responseData);
        
        // إذا كان السيرفر أرجع الاسم فارغ، نأخذه من بيانات اللوجين المحفوظة محلياً
        if (model.fullName.trim().isEmpty || model.fullName == 'Unknown Driver') {
           final savedName = profile?['fullName'] ?? profile?['name'];
           if (savedName != null && savedName.toString().trim().isNotEmpty) {
             model = DriverProfileModel(
               driverId: model.driverId,
               fullName: savedName.toString(),
               plateNumber: model.plateNumber,
               licenseNumber: model.licenseNumber,
               rating: model.rating,
               status: model.status,
               phoneNumber: model.phoneNumber,
               email: model.email,
               completedTrips: model.completedTrips,
               activeTrips: model.activeTrips,
               totalEarnings: model.totalEarnings,
               lastTripEndedAt: model.lastTripEndedAt,
             );
           }
        }
        return model;
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
    final box = Hive.box('app_box');
    final profile = box.get('HIVE_KEY_PROFILE') as Map<dynamic, dynamic>?;
    final fallbackDriverId = profile?['id'] as String? ?? '1c3d90db-5541-463c-812c-ceaa835379a2';
    try {
      final response = await _dio.put(
        '/drivers/$fallbackDriverId/status',
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
