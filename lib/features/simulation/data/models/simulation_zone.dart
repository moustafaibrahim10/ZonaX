class SimulationZone {
  final int zoneId;
  final double demand;

  SimulationZone({
    required this.zoneId,
    required this.demand,
  });

  factory SimulationZone.fromJson(Map<String, dynamic> json) {
    return SimulationZone(
      zoneId: (json['zoneId'] as num?)?.toInt() ?? 0,
      demand: (json['demand'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'demand': demand,
    };
  }
}
