import 'package:dartz/dartz.dart';
import 'package:zona_x_16_4/core/error/failures.dart';
import '../entities/earnings_entity.dart';
import '../repositories/earnings_repository.dart';

class GetEarningsUseCase {
  final EarningsRepository repository;

  GetEarningsUseCase(this.repository);

  Future<Either<Failure, EarningsEntity>> call(String driverId, String period) async {
    return await repository.getEarnings(driverId, period);
  }
}
