import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/trip_create_dto.dart';
import '../models/trip_update_dto.dart';

class TripException implements Exception {
  final String message;
  final int? statusCode;

  TripException(this.message, [this.statusCode]);

  @override
  String toString() => 'TripException: $message (Status: $statusCode)';
}

class TripService {
  final Dio _dio;

  TripService({Dio? dio}) : _dio = dio ?? DioFactory.getDio();

  Future<void> createTrip(TripCreateDto dto) async {
    try {
      final response = await _dio.post(
        ApiConstants.tripsEndpoint,
        data: dto.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw TripException('Failed to create trip', response.statusCode);
      }
    } on DioException catch (e) {
      throw TripException(e.message ?? 'Network error occurred', e.response?.statusCode);
    }
  }

  Future<void> updateTrip(int id, TripUpdateDto dto) async {
    try {
      final response = await _dio.put(
        '\${ApiConstants.tripsEndpoint}/$id',
        data: dto.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw TripException('Failed to update trip', response.statusCode);
      }
    } on DioException catch (e) {
      throw TripException(e.message ?? 'Network error occurred', e.response?.statusCode);
    }
  }

  Future<void> deleteTrip(int id) async {
    try {
      final response = await _dio.delete(
        '\${ApiConstants.tripsEndpoint}/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw TripException('Failed to delete trip', response.statusCode);
      }
    } on DioException catch (e) {
      throw TripException(e.message ?? 'Network error occurred', e.response?.statusCode);
    }
  }
}
