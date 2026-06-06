import 'package:equatable/equatable.dart';

abstract class RecommendedZonesEvent extends Equatable {
  const RecommendedZonesEvent();

  @override
  List<Object> get props => [];
}

class FetchRecommendedZones extends RecommendedZonesEvent {}
