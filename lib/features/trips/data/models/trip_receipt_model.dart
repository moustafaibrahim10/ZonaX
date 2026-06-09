class TripReceiptModel {
  final int tripId;
  final int durationMinutes;
  final double baseFare;
  final double surgeMultiplier;
  final double totalFare;
  final DateTime? endedAt;
  final String status;

  TripReceiptModel({
    required this.tripId,
    required this.durationMinutes,
    required this.baseFare,
    required this.surgeMultiplier,
    required this.totalFare,
    this.endedAt,
    required this.status,
  });

  factory TripReceiptModel.fromJson(Map<String, dynamic> json) {
    double fare = (json['fareAmount'] as num?)?.toDouble() ?? (json['baseFare'] as num?)?.toDouble() ?? 0.0;
    double tip = (json['tipAmount'] as num?)?.toDouble() ?? 0.0;
    double total = (json['totalAmount'] as num?)?.toDouble() ?? (json['totalFare'] as num?)?.toDouble() ?? (fare + tip);

    return TripReceiptModel(
      tripId: json['tripId'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      baseFare: fare,
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      totalFare: total,
      endedAt: json['endedAt'] != null ? DateTime.tryParse(json['endedAt']) : null,
      status: json['status']?.toString() ?? 'Completed',
    );
  }
}
