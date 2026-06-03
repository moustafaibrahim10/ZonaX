import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import 'package:zona_x_16_4/features/auth/data/auth_service.dart';
import 'package:zona_x_16_4/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:zona_x_16_4/features/profile/presentation/bloc/profile_state.dart';
import 'package:zona_x_16_4/features/profile/presentation/bloc/profile_event.dart';
import 'package:zona_x_16_4/features/profile/presentation/settings_page.dart';
import 'package:zona_x_16_4/features/profile/presentation/export_reports_page.dart';
import 'package:zona_x_16_4/features/profile/presentation/support_faq_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();

  void logout() async {
    try {
      // Sign out from Supabase
      await authService.signOut();

      // Clear token from local storage
      final secureStorage = const FlutterSecureStorage();
      final localDataSource = AuthLocalDataSourceImpl(
        secureStorage,
        Hive.box('app_box'),
      );
      await localDataSource.clearAllData();

      // Clear token from DioFactory
      DioFactory.clearAuthToken();

      // Navigate back to login screen using pushNamedAndRemoveUntil
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      // Still navigate to login on error
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _navigateToExportReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportReportsPage()),
    );
  }

  void _navigateToSupportFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SupportFAQPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is ProfileLoaded) {
              final profile = state.profile;
              return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with "Profile" title
              Padding(
                padding: EdgeInsets.only(left: 20.w, top: 16.h, bottom: 24.h),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: appColors.textPrimary,
                  ),
                ),
              ),

              // User Profile Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                  // User Avatar and Info
                  Row(
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.w,
                        decoration: BoxDecoration(
                          color: appColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: appColors.accent,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: appColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'License: ${profile.licenseNumber}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Rating and Status Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: appColors.accent, size: 18.sp),
                          SizedBox(width: 6.w),
                          Text(
                            profile.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: appColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            profile.status == 'Available' ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: profile.status == 'Available' ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Switch.adaptive(
                            value: profile.status == 'Available',
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                            onChanged: (bool value) {
                              final newStatus = value ? 'Available' : 'Offline';
                              context.read<ProfileBloc>().add(
                                UpdateDriverStatusEvent(
                                  newStatus: newStatus,
                                  lat: 30.0444, // Tahrir Square
                                  lng: 31.2357, // Tahrir Square
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Vehicle Info
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: appColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: appColors.inputBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: appColors.accent,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Plate',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: appColors.textPrimary,
                              ),
                            ),
                            Text(
                              profile.plateNumber,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // This Month Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, bottom: 12.h),
              child: Text(
                'This Month',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1,
                children: [
                  _buildStatCard(
                    appColors,
                    Icons.monetization_on,
                    '\$${profile.totalEarnings.toStringAsFixed(0)}',
                    'Earnings',
                  ),
                  _buildStatCard(
                    appColors,
                    Icons.trending_up,
                    '${profile.completedTrips}',
                    'Trips',
                  ),
                  _buildStatCard(
                    appColors,
                    Icons.star,
                    profile.rating.toStringAsFixed(1),
                    'Rating',
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),



            // More Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, bottom: 12.h),
              child: Text(
                'More',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildMenuItemWithNavigation(
                    appColors,
                    Icons.settings,
                    'Settings',
                    _navigateToSettings,
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItemWithNavigation(
                    appColors,
                    Icons.download,
                    'Export Reports',
                    _navigateToExportReports,
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItemWithNavigation(
                    appColors,
                    Icons.help_outline,
                    'Support & FAQ',
                    _navigateToSupportFAQ,
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    appColors,
                    Icons.play_circle_outline,
                    'Tutorial Videos',
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    appColors,
                    Icons.cloud_off,
                    'Offline Mode',
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    appColors,
                    Icons.battery_charging_full,
                    'Battery Saver',
                  ),
                  SizedBox(height: 12.h),
                  _buildMenuItem(
                    appColors,
                    Icons.insert_chart,
                    'Data Usage',
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Logout Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: appColors.inputBorder)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: InkWell(
                    onTap: logout,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 80.h), // Space for bottom nav
          ],
        ),
      );
            }
            return const SizedBox.shrink(); // Initial State
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    AppColors appColors,
    IconData icon,
    String value,
    String label,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: appColors.accent, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: appColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: appColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    AppColors appColors,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: appColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: appColors.accent, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(AppColors appColors, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: appColors.accent, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: appColors.textPrimary,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: appColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemWithNavigation(
    AppColors appColors,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: appColors.inputBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: appColors.accent, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: appColors.textPrimary,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: appColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
