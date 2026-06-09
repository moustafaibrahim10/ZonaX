import 'package:dartz/dartz.dart';
import '../models/trip_receipt_model.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';
import '../models/trip_create_dto.dart';
import '../models/trip_update_dto.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> createTrip(TripCreateDto dto) async {
    try {
      final tripId = await remoteDataSource.createTrip(dto);
      return Right(tripId);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTrip(String tripId, TripUpdateDto dto) async {
    try {
      await remoteDataSource.updateTrip(tripId, dto);
      return const Right(null);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    try {
      await remoteDataSource.deleteTrip(tripId);
      return const Right(null);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> startTrip(String tripId, int pickupLocationId, int dropoffLocationId) async {
    try {
      await remoteDataSource.startTrip(tripId, pickupLocationId, dropoffLocationId);
      return const Right(null);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripReceiptModel>> endTrip(String tripId, double farePerMinute, double baseFare, double surgeMultiplier) async {
    try {
      final receipt = await remoteDataSource.endTrip(tripId, farePerMinute, baseFare, surgeMultiplier);
      return Right(receipt);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedTripHistory>> getTripHistory(int pageNumber, int pageSize) async {
    try {
      final history = await remoteDataSource.getTripHistory(pageNumber, pageSize);
      return Right(history);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> testAuditTrip(String tripId) async {
    try {
      await remoteDataSource.testAuditTrip(tripId);
      return const Right(null);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripReceiptModel>> getTripById(String tripId) async {
    try {
      final receipt = await remoteDataSource.getTripById(tripId);
      return Right(receipt);
    } on TripException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
