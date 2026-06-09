import 'package:dartz/dartz.dart';
import 'package:zona_x_16_4/core/error/failures.dart';
import '../entities/earnings_entity.dart';

abstract class EarningsRepository {
  Future<Either<Failure, EarningsEntity>> getEarnings(String driverId, String period);
}
