import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/features/auth/data/auth_service.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:zona_x_16_4/features/profile/domain/models/profile_model.dart';
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
  late ProfileModel _profileData;
  int _selectedIndex = 4; // Profile tab is selected

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data
    _profileData = ProfileModel(
      id: 'dummy-id-123',
      name: 'Ahmed Hassan',
      email: authService.getCurrentUserEmail() ?? 'user@example.com',
      rating: 4.8,
      rank: 5,
      vehicleModel: 'Toyota Camry 2023',
      vehiclePlate: 'ABC 1234',
      earnedThisMonth: 14500,
      tripsThisMonth: 324,
      onlineHoursThisMonth: 186,
      achievements: [
        Achievement(
          id: '1',
          title: 'Rising Star',
          description: 'Earnings increased by 20% this week',
          icon: 'star',
          unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Achievement(
          id: '2',
          title: '5-Star Service',
          description: 'Maintained 4.8+ rating for 30 days',
          icon: 'grade',
          unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
    );
  }

  void logout() async {
    await authService.signOut();
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
    final profile = _profileData;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SingleChildScrollView(
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
                          color: appColors.accent.withOpacity(0.2),
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
                              profile.name,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: appColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              profile.email,
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

                  // Rating and Rank
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
                      SizedBox(width: 24.w),
                      Text(
                        'Rank #${profile.rank}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appColors.textPrimary,
                        ),
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
                        Icon(Icons.directions_car, color: appColors.accent, size: 24.sp),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.vehicleModel,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: appColors.textPrimary,
                              ),
                            ),
                            Text(
                              profile.vehiclePlate,
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
                    '\$${(profile.earnedThisMonth / 1000).toStringAsFixed(1)}K',
                    'Earned',
                  ),
                  _buildStatCard(
                    appColors,
                    Icons.trending_up,
                    '${profile.tripsThisMonth}',
                    'Trips',
                  ),
                  _buildStatCard(
                    appColors,
                    Icons.schedule,
                    '${profile.onlineHoursThisMonth}h',
                    'Online',
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Recent Achievements
            if (profile.achievements.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(left: 20.w, bottom: 12.h),
                child: Text(
                  'Recent Achievements',
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
                  children: profile.achievements.take(2).map((achievement) {
                    return Column(
                      children: [
                        _buildAchievementCard(
                          appColors,
                          Icons.star_outline,
                          achievement.title,
                          achievement.description,
                        ),
                        SizedBox(height: 12.h),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],

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
                  _buildMenuItem(appColors, Icons.play_circle_outline, 'Tutorial Videos'),
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
                  border: Border(
                    top: BorderSide(color: appColors.inputBorder),
                  ),
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
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appColors.surface,
        selectedItemColor: appColors.accent,
        unselectedItemColor: appColors.textSecondary,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard(AppColors appColors, IconData icon, String value, String label) {
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
            style: TextStyle(
              fontSize: 11.sp,
              color: appColors.textSecondary,
            ),
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
              color: appColors.accent.withOpacity(0.2),
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
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: appColors.textSecondary),
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
             Icon(Icons.arrow_forward_ios, size: 16.sp, color: appColors.textSecondary),
           ],
         ),
       ),
     );
   }
}
