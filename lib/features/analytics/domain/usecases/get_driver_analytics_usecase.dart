import 'package:dartz/dartz.dart';
import 'package:zona_x_16_4/core/error/failures.dart';
import '../entities/analytics_entity.dart';
import '../repositories/analytics_repository.dart';

class GetDriverAnalyticsUseCase {
  final AnalyticsRepository repository;

  GetDriverAnalyticsUseCase(this.repository);

  Future<Either<Failure, AnalyticsEntity>> call(String driverId) async {
    return await repository.getDriverAnalytics(driverId);
  }
}
