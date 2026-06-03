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

  // Factory to create from JSON map
  factory DriverEntity.fromJson(Map<String, dynamic> json) {
    return DriverEntity(
      id: json['driverId'] as String? ?? json['id'] as String? ?? '',
      name: json['driverName'] as String? ?? json['name'] as String? ?? '',
      rating: (json['averageRating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 0.0,
      trips: json['totalTrips'] as int? ?? json['trips'] as int? ?? 0,
      earnings: (json['totalEarnings'] as num?)?.toDouble() ?? (json['earnings'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int? ?? json['position'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  // copyWith to create modified copies
  DriverEntity copyWith({
    String? id,
    String? name,
    double? rating,
    int? trips,
    double? earnings,
    int? rank,
    bool? isCurrentUser,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      trips: trips ?? this.trips,
      earnings: earnings ?? this.earnings,
      rank: rank ?? this.rank,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  // Optional toJson for future use
  Map<String, dynamic> toJson() => {
        'driverId': id,
        'driverName': name,
        'averageRating': rating,
        'totalTrips': trips,
        'totalEarnings': earnings,
        'rank': rank,
        'isCurrentUser': isCurrentUser,
      };

  @override
  List<Object?> get props => [id, name, rating, trips, earnings, rank, isCurrentUser];
}

