import 'package:dartz/dartz.dart';
import 'package:zona_x_16_4/core/error/exceptions.dart';
import 'package:zona_x_16_4/core/error/failures.dart';
import '../../domain/entities/earnings_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_data_source.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EarningsEntity>> getEarnings(String driverId, String period) async {
    try {
      final remoteData = await remoteDataSource.getDriverEarnings(driverId, period);
      return Right(remoteData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
