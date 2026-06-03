import 'package:dartz/dartz.dart';
import 'package:zona_x_16_4/core/error/exceptions.dart';
import 'package:zona_x_16_4/core/error/failures.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AnalyticsEntity>> getDriverAnalytics(String driverId) async {
    try {
      final analytics = await remoteDataSource.getDriverAnalytics(driverId);
      return Right(analytics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
