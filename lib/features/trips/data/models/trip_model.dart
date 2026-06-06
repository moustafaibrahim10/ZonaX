class TripModel {
  final String id;
  final String? driverId;
  final String? passengerId;
  final int? zoneId;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final double? fare;

  TripModel({
    required this.id,
    this.driverId,
    this.passengerId,
    this.zoneId,
    required this.status,
    this.startTime,
    this.endTime,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.fare,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id']?.toString() ?? json['tripId']?.toString() ?? '',
      driverId: json['driverId']?.toString(),
      passengerId: json['passengerId']?.toString(),
      zoneId: json['zoneId'] as int?,
      status: json['status']?.toString() ?? 'Unknown',
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble(),
      dropoffLatitude: (json['dropoffLatitude'] as num?)?.toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num?)?.toDouble(),
      fare: (json['fare'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'passengerId': passengerId,
      'zoneId': zoneId,
      'status': status,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropoffLatitude': dropoffLatitude,
      'dropoffLongitude': dropoffLongitude,
      'fare': fare,
    };
  }
}

class PaginatedTripHistory {
  final List<TripModel> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  PaginatedTripHistory({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory PaginatedTripHistory.fromJson(Map<String, dynamic> json) {
    return PaginatedTripHistory(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TripModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}
