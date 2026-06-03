import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String id;
  final String name;
  final double rating;
  final int trips;
  final double earnings;
  final int rank;
  final bool isCurrentUser;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.rating,
    required this.trips,
    required this.earnings,
    required this.rank,
    this.isCurrentUser = false,
  });

  @override
  List<Object?> get props => [id, name, rating, trips, earnings, rank, isCurrentUser];
}

