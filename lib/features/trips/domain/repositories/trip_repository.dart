import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/trip_create_dto.dart';
import '../../data/models/trip_update_dto.dart';
import '../../data/models/trip_model.dart';

abstract class TripRepository {
  Future<Either<Failure, String>> createTrip(TripCreateDto dto);
  Future<Either<Failure, void>> updateTrip(String tripId, TripUpdateDto dto);
  Future<Either<Failure, void>> deleteTrip(String tripId);
  Future<Either<Failure, void>> startTrip(String tripId);
  Future<Either<Failure, void>> endTrip(String tripId);
  Future<Either<Failure, PaginatedTripHistory>> getTripHistory(int pageNumber, int pageSize);
  Future<Either<Failure, void>> testAuditTrip(String tripId);
}
