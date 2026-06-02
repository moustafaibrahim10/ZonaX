import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:zona_x_16_4/features/map/presentation/screens/heatmap_screen.dart';
import 'package:zona_x_16_4/features/earnings/presentation/screens/earnings_screen.dart';
import 'package:zona_x_16_4/features/profile/presentation/profile_page.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:zona_x_16_4/features/map/data/repositories/map_repository_impl.dart';
import 'package:zona_x_16_4/features/map/data/datasources/map_mock_data_source.dart';
import 'package:zona_x_16_4/features/map/data/datasources/hive_local_data_source.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HeatmapScreen(),
    const AnalyticsScreen(), // Second page as requested
    const EarningsScreen(),
    const LeaderboardScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapCubit>(
      create: (context) {
        final mockDataSource = MapMockDataSourceImpl();
        final mapRepository = MapRepositoryImpl(mockDataSource);
        final hiveLocalDataSource = HiveLocalDataSourceImpl();
        return MapCubit(mapRepository, hiveLocalDataSource);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F111A),
        body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F111A),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(
            0xFF00D293,
          ), // Teal/Green accent from image
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          selectedFontSize: 11.sp,
          unselectedFontSize: 11.sp,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_rounded),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    ));
  }
}

// --- Static Dummy Screens ---

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F111A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 80),
            SizedBox(height: 20),
            Text(
              "Leaderboard\n(Coming Soon)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
