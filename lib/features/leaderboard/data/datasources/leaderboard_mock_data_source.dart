import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';

class LeaderboardMockDataSource {
  static Future<List<DriverEntity>> getLeaderboard() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const DriverEntity(
        id: '1',
        name: 'Ahmed Hassan',
        rating: 4.9,
        trips: 412,
        earnings: 18500,
        rank: 1,
      ),
      const DriverEntity(
        id: '2',
        name: 'Mohamed Ali',
        rating: 4.8,
        trips: 398,
        earnings: 17800,
        rank: 2,
      ),
      const DriverEntity(
        id: '3',
        name: 'Mahmoud Said',
        rating: 4.9,
        trips: 365,
        earnings: 16200,
        rank: 3,
      ),
      const DriverEntity(
        id: '4',
        name: 'Omar Khaled',
        rating: 4.7,
        trips: 352,
        earnings: 15900,
        rank: 4,
      ),
      const DriverEntity(
        id: 'current',
        name: 'You',
        rating: 4.8,
        trips: 324,
        earnings: 14500,
        rank: 5,
        isCurrentUser: true,
      ),
      const DriverEntity(
        id: '6',
        name: 'Youssef Ibrahim',
        rating: 4.6,
        trips: 310,
        earnings: 13800,
        rank: 6,
      ),
      const DriverEntity(
        id: '7',
        name: 'Hassan Mohamed',
        rating: 4.5,
        trips: 298,
        earnings: 13200,
        rank: 7,
      ),
      const DriverEntity(
        id: '8',
        name: 'Ali Karim',
        rating: 4.4,
        trips: 285,
        earnings: 12800,
        rank: 8,
      ),
      const DriverEntity(
        id: '9',
        name: 'Karim Eldin',
        rating: 4.3,
        trips: 272,
        earnings: 12100,
        rank: 9,
      ),
      const DriverEntity(
        id: '10',
        name: 'Ibrahim Nour',
        rating: 4.2,
        trips: 260,
        earnings: 11500,
        rank: 10,
      ),
    ];
  }
}

