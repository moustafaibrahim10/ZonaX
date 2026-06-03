import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: appColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZonaX Privacy Policy',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Last updated: June 2026',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: appColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              _buildSection(
                appColors,
                '1. Location Access Disclosure',
                'ZonaX collects and processes location data of your device in both background and foreground modes. This information is essential to match you with trips, calculate precise routes, track trip progress, and ensure safety during operation.',
              ),
              _buildSection(
                appColors,
                '2. Gallery and Photos Access',
                'If you wish to change your profile picture, the application requires access to your photo gallery so you can choose a photo. We only access the specific image you select and do not collect other files.',
              ),
              _buildSection(
                appColors,
                '3. Information Sharing',
                'We share location details and vehicle information (plate number, name) with passengers to facilitate trips. We do not sell or lease your personal information to third parties.',
              ),
              _buildSection(
                appColors,
                '4. Security',
                'We use industry-standard encryption and security measures to protect your personal details, location logs, and payment information from unauthorized access.',
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(AppColors appColors, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: appColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.sp,
              color: appColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
