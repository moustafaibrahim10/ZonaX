import 'package:dartz/dartz.dart';
import '../../data/models/trip_receipt_model.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/trip_create_dto.dart';
import '../../data/models/trip_update_dto.dart';
import '../../data/models/trip_model.dart';

abstract class TripRepository {
  Future<Either<Failure, String>> createTrip(TripCreateDto dto);
  Future<Either<Failure, void>> updateTrip(String tripId, TripUpdateDto dto);
  Future<Either<Failure, void>> deleteTrip(String tripId);
  Future<Either<Failure, void>> startTrip(String tripId, int pickupLocationId, int dropoffLocationId);
  Future<Either<Failure, TripReceiptModel>> endTrip(String tripId, double farePerMinute, double baseFare, double surgeMultiplier);
  Future<Either<Failure, PaginatedTripHistory>> getTripHistory(int pageNumber, int pageSize);
  Future<Either<Failure, void>> testAuditTrip(String tripId);
  Future<Either<Failure, TripReceiptModel>> getTripById(String tripId);
}
