import 'package:equatable/equatable.dart';
import '../../data/models/recommended_zone_model.dart';

abstract class RecommendedZonesState extends Equatable {
  const RecommendedZonesState();

  @override
  List<Object> get props => [];
}

class RecommendedZonesInitial extends RecommendedZonesState {}

class RecommendedZonesLoading extends RecommendedZonesState {}

class RecommendedZonesLoaded extends RecommendedZonesState {
  final List<RecommendedZoneModel> zones;

  const RecommendedZonesLoaded(this.zones);

  @override
  List<Object> get props => [zones];
}

class RecommendedZonesError extends RecommendedZonesState {
  final String message;

  const RecommendedZonesError(this.message);

  @override
  List<Object> get props => [message];
}
