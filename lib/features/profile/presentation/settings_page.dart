import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool locationEnabled = true;
  bool dataAnalyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: appColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: appColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 12.h),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            _buildSettingsTile(
              appColors,
              Icons.edit,
              'Edit Profile',
              'Update your personal information',
            ),
            _buildSettingsTile(
              appColors,
              Icons.credit_card,
              'Payment Methods',
              'Manage your payment methods',
            ),
            _buildSettingsTile(
              appColors,
              Icons.lock,
              'Change Password',
              'Update your password',
            ),

            // Preferences Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 12.h),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            _buildToggleSetting(
              appColors,
              Icons.notifications,
              'Push Notifications',
              'Receive notifications about trips and earnings',
              notificationsEnabled,
              (value) {
                setState(() => notificationsEnabled = value);
              },
            ),
            _buildToggleSetting(
              appColors,
              Icons.location_on,
              'Location Services',
              'Allow access to your location',
              locationEnabled,
              (value) {
                setState(() => locationEnabled = value);
              },
            ),
            _buildToggleSetting(
              appColors,
              Icons.analytics,
              'Data Analytics',
              'Help us improve with anonymous data',
              dataAnalyticsEnabled,
              (value) {
                setState(() => dataAnalyticsEnabled = value);
              },
            ),

            // Appearance Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 12.h),
              child: Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            _buildToggleSetting(
              appColors,
              Icons.dark_mode,
              'Dark Mode',
              'Enable dark theme',
              darkModeEnabled,
              (value) {
                setState(() => darkModeEnabled = value);
              },
            ),

            // About Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 12.h),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            _buildSettingsTile(
              appColors,
              Icons.info,
              'About ZonaX',
              'Version 1.0.0',
            ),
            _buildSettingsTile(
              appColors,
              Icons.description,
              'Terms & Conditions',
              'Read our terms of service',
            ),
            _buildSettingsTile(
              appColors,
              Icons.privacy_tip,
              'Privacy Policy',
              'Review our privacy policy',
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    AppColors appColors,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: appColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    AppColors appColors,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: appColors.accent,
          ),
        ],
      ),
    );
  }
}

