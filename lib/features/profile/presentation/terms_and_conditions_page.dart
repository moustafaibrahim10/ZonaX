import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

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
          'Terms & Conditions',
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
                'ZonaX Terms of Service',
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
                '1. Acceptance of Terms',
                'By registering or using the ZonaX application, you agree to comply with and be bound by these terms. If you do not agree, you cannot use the application.',
              ),
              _buildSection(
                appColors,
                '2. User Account & Eligibility',
                'You must be at least 18 years old and hold a valid driver\'s license and vehicle registration. You are responsible for maintaining the confidentiality of your account credentials.',
              ),
              _buildSection(
                appColors,
                '3. Guidelines for Drivers',
                'As a driver on ZonaX, you must comply with all local traffic laws and regulations. You are expected to maintain professional standards and provide safe transport services.',
              ),
              _buildSection(
                appColors,
                '4. Limitation of Liability',
                'ZonaX is a platform connecting drivers and passengers. We are not liable for direct, indirect, or incidental damages arising from your trips or use of the application.',
              ),
              _buildSection(
                appColors,
                '5. Updates to Terms',
                'We may update these terms from time to time. Continued use of the app constitutes acceptance of the new terms.',
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
