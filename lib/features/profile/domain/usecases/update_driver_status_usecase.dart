import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/driver_profile_repository.dart';

class UpdateDriverStatusUseCase {
  final DriverProfileRepository repository;

  UpdateDriverStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(String status, double lat, double lng) async {
    return await repository.updateDriverStatus(status, lat, lng);
  }
}
