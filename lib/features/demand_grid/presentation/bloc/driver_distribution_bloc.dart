import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/driver_distribution_model.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'dart:convert';

// --- Events ---
abstract class DriverDistributionEvent extends Equatable {
  const DriverDistributionEvent();

  @override
  List<Object?> get props => [];
}

class StartPollingDriverDistribution extends DriverDistributionEvent {}

class StopPollingDriverDistribution extends DriverDistributionEvent {}

class _FetchDriverDistribution extends DriverDistributionEvent {}

// --- States ---
abstract class DriverDistributionState extends Equatable {
  const DriverDistributionState();

  @override
  List<Object?> get props => [];
}

class DriverDistributionInitial extends DriverDistributionState {}

class DriverDistributionLoading extends DriverDistributionState {}

class DriverDistributionLoaded extends DriverDistributionState {
  final List<DriverDistributionModel> distributions;
  final String geoJson;

  const DriverDistributionLoaded({required this.distributions, required this.geoJson});

  @override
  List<Object?> get props => [distributions, geoJson];
}

class DriverDistributionError extends DriverDistributionState {
  final String message;

  const DriverDistributionError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class DriverDistributionBloc extends Bloc<DriverDistributionEvent, DriverDistributionState> {
  final ZoneRepository repository;
  Timer? _pollingTimer;

  DriverDistributionBloc({required this.repository}) : super(DriverDistributionInitial()) {
    on<StartPollingDriverDistribution>(_onStartPolling);
    on<StopPollingDriverDistribution>(_onStopPolling);
    on<_FetchDriverDistribution>(_onFetch);
  }

  void _onStartPolling(StartPollingDriverDistribution event, Emitter<DriverDistributionState> emit) {
    add(_FetchDriverDistribution());
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(_FetchDriverDistribution());
    });
  }

  void _onStopPolling(StopPollingDriverDistribution event, Emitter<DriverDistributionState> emit) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _onFetch(_FetchDriverDistribution event, Emitter<DriverDistributionState> emit) async {
    if (state is DriverDistributionInitial || state is DriverDistributionError) {
      emit(DriverDistributionLoading());
    }

    final result = await repository.getDriverDistribution();
    result.fold(
      (failure) {
        emit(DriverDistributionError(failure.message));
      },
      (distributions) {
        // Generate GeoJSON
        final features = distributions.map((dist) {
          final saturationScore = dist.activeDriversCount / (dist.areaSizeProxy > 0 ? dist.areaSizeProxy : 1.0);
          
          String color = '#808080'; // Grey for Zero Active
          if (dist.availableDriversCount > 0) {
            color = '#00FF00'; // Green for Available > 0
          } else if (dist.onTripDriversCount > 0) {
            color = '#FFBF00'; // Amber for Only On-Trip
          }

          return {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [dist.centerLongitude, dist.centerLatitude]
            },
            "properties": {
              "zoneId": dist.zoneId,
              "activeDriversCount": dist.activeDriversCount,
              "availableDriversCount": dist.availableDriversCount,
              "onTripDriversCount": dist.onTripDriversCount,
              "saturationScore": saturationScore,
              "color": color,
            }
          };
        }).toList();

        final geoJsonObj = {
          "type": "FeatureCollection",
          "features": features,
        };

        final geoJsonString = jsonEncode(geoJsonObj);

        emit(DriverDistributionLoaded(
          distributions: distributions,
          geoJson: geoJsonString,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
