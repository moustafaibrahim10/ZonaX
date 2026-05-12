import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:zona_x_16_4/features/map/presentation/screens/heatmap_screen.dart';
import 'package:zona_x_16_4/features/earnings/presentation/screens/earnings_screen.dart';

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
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F111A),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00D293), // Teal/Green accent from image
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
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.attach_money_rounded), label: 'Earnings'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Leaderboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
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
            Text("Leaderboard\n(Coming Soon)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F111A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, color: Colors.purpleAccent, size: 80),
            SizedBox(height: 20),
            Text("Driver Profile\n(Coming Soon)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
