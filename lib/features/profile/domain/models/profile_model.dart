class ProfileModel {
  final String id;
  final String name;
  final String email;
  final double rating;
  final int rank;
  final String vehicleModel;
  final String vehiclePlate;
  final double earnedThisMonth;
  final int tripsThisMonth;
  final int onlineHoursThisMonth;
  final List<Achievement> achievements;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.rank,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.earnedThisMonth,
    required this.tripsThisMonth,
    required this.onlineHoursThisMonth,
    required this.achievements,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      rating: (json['rating'] ?? 4.8).toDouble(),
      rank: json['rank'] ?? 5,
      vehicleModel: json['vehicle_model'] ?? 'Toyota Camry 2023',
      vehiclePlate: json['vehicle_plate'] ?? 'ABC 1234',
      earnedThisMonth: (json['earned_this_month'] ?? 14500).toDouble(),
      tripsThisMonth: json['trips_this_month'] ?? 324,
      onlineHoursThisMonth: json['online_hours_this_month'] ?? 186,
      achievements: json['achievements'] != null
          ? (json['achievements'] as List)
              .map((a) => Achievement.fromJson(a))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'rating': rating,
        'rank': rank,
        'vehicle_model': vehicleModel,
        'vehicle_plate': vehiclePlate,
        'earned_this_month': earnedThisMonth,
        'trips_this_month': tripsThisMonth,
        'online_hours_this_month': onlineHoursThisMonth,
        'achievements': achievements.map((a) => a.toJson()).toList(),
      };
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'star',
      unlockedAt: DateTime.parse(json['unlocked_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'unlocked_at': unlockedAt.toIso8601String(),
      };
}

