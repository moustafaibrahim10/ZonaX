import 'dart:async';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/zone_repository.dart';
import '../datasources/zone_remote_data_source.dart';
import '../models/zone_model.dart';
import '../models/zone_heatmap_model.dart';
import '../models/zone_insights_model.dart';
import '../models/top_demand_zone_model.dart';
import '../models/recommended_zone_model.dart';
import '../models/peak_hour_model.dart';
import '../models/driver_distribution_model.dart';

import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneRemoteDataSource remoteDataSource;
  final Dio dio;

  ZoneRepositoryImpl({
    required this.remoteDataSource,
    required this.dio,
  });

  @override
  Future<Either<Failure, List<ZoneModel>>> getZones() async {
    try {
      final response = await remoteDataSource.getZones();
      return Right(response.data ?? []);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ZoneHeatmapModel>>> getZonesHeatmap() async {
    try {
      dio.options.receiveTimeout = const Duration(milliseconds: 300000);
      dio.options.connectTimeout = const Duration(milliseconds: 300000);
      
      final response = await remoteDataSource.getZonesHeatmap();
      return Right(response.data ?? []);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    } finally {
      dio.options.receiveTimeout = const Duration(milliseconds: ApiConstants.apiTimeOut);
      dio.options.connectTimeout = const Duration(milliseconds: ApiConstants.apiTimeOut);
    }
  }

  @override
  Future<Either<Failure, ZoneInsightsModel>> getZoneInsights(int zoneId) async {
    try {
      final response = await remoteDataSource.getZoneInsights(zoneId);
      if (response.data != null) {
        return Right(response.data!);
      } else {
        return const Left(ServerFailure('Insights data is null'));
      }
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    @override
    Future<Either<Failure, List<TopDemandZoneModel>>> getTopDemandZones() async {
      try {
        final response = await remoteDataSource.getTopDemandZones();
        return Right(response.data ?? []);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

  @override
  Future<Either<Failure, List<RecommendedZoneModel>>> getRecommendedZones() async {
    try {
      final response = await remoteDataSource.getRecommendedZones();
      if (response.data != null) {
        return Right(response.data!);
      } else {
        return const Left(ServerFailure('Recommended zones data is null'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PeakHourModel>>> getPeakHours() async {
    try {
      final response = await remoteDataSource.getPeakHours();
      if (response.data != null) {
        return Right(response.data!);
      } else {
        return const Left(ServerFailure('Peak hours data is null'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DriverDistributionModel>>> getDriverDistribution() async {
    try {
      final response = await remoteDataSource.getDriverDistribution();
      if (response.data != null) {
        return Right(response.data!);
      } else {
        return const Left(ServerFailure('Driver distribution data is null'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getLiveDemandUpdates() async* {
    // Disabled automated random ticker so the map remains perfectly static
    // final random = Random();
    // 
    // while (true) {
    //   await Future.delayed(const Duration(seconds: 3));
    //   
    //   // Generate some random updates for our 256 zones (IDs 0 to 255)
    //   final int numberOfUpdates = random.nextInt(10) + 5; // 5 to 15 updates
    //   final List<Map<String, dynamic>> updates = [];
    //   
    //   for (int i = 0; i < numberOfUpdates; i++) {
    //     updates.add({
    //       "zoneId": random.nextInt(256), // Random zone from 0 to 255
    //       "demandLevel": random.nextInt(100), // Demand level 0 to 99
    //     });
    //   }
    //   
    //   yield updates;
    // }
  }
}

