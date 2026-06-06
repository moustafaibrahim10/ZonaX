import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:zona_x_16_4/features/map/presentation/screens/heatmap_screen.dart';
import 'package:zona_x_16_4/features/earnings/presentation/screens/earnings_screen.dart';

import 'package:zona_x_16_4/features/voice_assistant/presentation/bloc/voice_cubit.dart';
import 'package:zona_x_16_4/features/voice_assistant/presentation/bloc/voice_state.dart';

import 'package:zona_x_16_4/features/profile/presentation/profile_page.dart';
import 'package:zona_x_16_4/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:zona_x_16_4/features/profile/presentation/bloc/profile_event.dart';
import 'package:zona_x_16_4/features/profile/domain/usecases/get_driver_profile_usecase.dart';
import 'package:zona_x_16_4/features/profile/domain/usecases/update_driver_status_usecase.dart';
import 'package:zona_x_16_4/features/profile/data/repositories/driver_profile_repository_impl.dart';
import 'package:zona_x_16_4/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:zona_x_16_4/features/map/data/repositories/map_repository_impl.dart';
import 'package:zona_x_16_4/features/map/data/datasources/map_mock_data_source.dart';
import 'package:zona_x_16_4/features/map/data/datasources/hive_local_data_source.dart';
import 'package:zona_x_16_4/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:zona_x_16_4/features/leaderboard/presentation/cubit/leaderboard_cubit.dart';
import 'package:zona_x_16_4/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zona_x_16_4/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:zona_x_16_4/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:zona_x_16_4/features/analytics/domain/usecases/get_driver_analytics_usecase.dart';
import 'package:zona_x_16_4/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:zona_x_16_4/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:zona_x_16_4/features/analytics/presentation/bloc/peak_hours_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'package:zona_x_16_4/injection_container.dart' as di;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HeatmapScreen(),
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final repository = AnalyticsRepositoryImpl(
              AnalyticsRemoteDataSourceImpl(),
            );
            return AnalyticsBloc(
              getDriverAnalyticsUseCase: GetDriverAnalyticsUseCase(repository),
            )..add(FetchAnalytics());
          },
        ),
        BlocProvider(
          create: (context) => PeakHoursBloc(
            repository: di.sl<ZoneRepository>(),
          )..add(FetchPeakHours()),
        ),
      ],
      child: const AnalyticsScreen(),
    ), // Second page as requested
    const EarningsScreen(),
    BlocProvider(
      create: (context) => LeaderboardCubit(LeaderboardRepositoryImpl()),
      child: const LeaderboardPage(),
    ),
    BlocProvider(
      create: (context) {
        final profileRepository = DriverProfileRepositoryImpl(
          ProfileRemoteDataSourceImpl(),
        );
        return ProfileBloc(
          getDriverProfileUseCase: GetDriverProfileUseCase(profileRepository),
          updateDriverStatusUseCase: UpdateDriverStatusUseCase(profileRepository),
        )..add(FetchProfile());
      },
      child: const ProfilePage(),
    ),
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
      child: BlocProvider<VoiceCubit>(
        create: (context) => di.sl<VoiceCubit>(),
        child: Scaffold(
          backgroundColor: const Color(0xFF0F111A),
          body: BlocListener<VoiceCubit, VoiceState>(
            listener: (context, state) {
              if (state is VoiceActionTriggered) {
                if (state.action == 'navigate_to_demand') {
                  setState(() => _currentIndex = 0);
                } else if (state.action == 'navigate_to_earnings') {
                  setState(() => _currentIndex = 2);
                } else if (state.action == 'navigate_to_profile') {
                  setState(() => _currentIndex = 4);
                } else if (state.action == 'navigate_to_trips') {
                  // Assuming Trips might be leaderboard or map. Since there's no trip tab, we fallback to 0
                  setState(() => _currentIndex = 0);
                }
              }
            },
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
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
    )));
  }
}
