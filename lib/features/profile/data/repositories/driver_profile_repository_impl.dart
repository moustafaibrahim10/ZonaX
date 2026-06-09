import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  DriverProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DriverProfileEntity>> getDriverProfile() async {
    try {
      final profile = await remoteDataSource.getDriverProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateDriverStatus(String status, double lat, double lng) async {
    try {
      final result = await remoteDataSource.updateDriverStatus(status, lat, lng);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
