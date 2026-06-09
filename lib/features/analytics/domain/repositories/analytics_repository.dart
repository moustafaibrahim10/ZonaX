import 'package:dartz/dartz.dart';
import 'package:zona_x_16_4/core/error/failures.dart';
import '../entities/analytics_entity.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsEntity>> getDriverAnalytics(String driverId);
}
