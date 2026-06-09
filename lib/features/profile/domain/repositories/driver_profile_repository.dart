import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_profile_entity.dart';

abstract class DriverProfileRepository {
  Future<Either<Failure, DriverProfileEntity>> getDriverProfile();
  Future<Either<Failure, bool>> updateDriverStatus(String status, double lat, double lng);
}
