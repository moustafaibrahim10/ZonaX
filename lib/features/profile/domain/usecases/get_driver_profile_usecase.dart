import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_profile_entity.dart';
import '../repositories/driver_profile_repository.dart';

class GetDriverProfileUseCase {
  final DriverProfileRepository repository;

  GetDriverProfileUseCase(this.repository);

  Future<Either<Failure, DriverProfileEntity>> call() async {
    return await repository.getDriverProfile();
  }
}
