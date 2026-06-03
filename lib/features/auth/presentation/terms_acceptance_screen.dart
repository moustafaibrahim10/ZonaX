import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/screens/main_screen.dart';

class TermsAcceptanceScreen extends StatefulWidget {
  const TermsAcceptanceScreen({super.key});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _isAccepted = false;

  void _onContinue() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    if (!_isAccepted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: appColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28.sp),
              SizedBox(width: 10.w),
              Text(
                'Acceptance Required',
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Text(
            'To continue and use the ZonaX driver application, you must accept our Terms & Conditions and Privacy Policy.',
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Save acceptance to Hive
    final box = Hive.box('app_box');
    box.put('terms_accepted', true);

    // Navigate to MainScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Welcome to ZonaX',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please review and accept our policies to proceed.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: appColors.textSecondary,
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: appColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: appColors.inputBorder),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(appColors, Icons.description, 'Terms & Conditions Summary'),
                        SizedBox(height: 10.h),
                        _buildBulletPoint(appColors, 'Comply with all local driving and safety laws.'),
                        _buildBulletPoint(appColors, 'Maintain professional conduct and safe transport standards.'),
                        _buildBulletPoint(appColors, 'Keep your personal and vehicle documentation up to date.'),
                        SizedBox(height: 20.h),
                        _buildSectionHeader(appColors, Icons.privacy_tip, 'Privacy & Policy Summary'),
                        SizedBox(height: 10.h),
                        _buildBulletPoint(
                          appColors,
                          'Location Access: We access your location in the foreground and background to track trips and provide navigation.',
                        ),
                        _buildBulletPoint(
                          appColors,
                          'Gallery Access: To upload or change your profile picture, we require your permission to access your photo library.',
                        ),
                        _buildBulletPoint(appColors, 'Your data is securely encrypted and never shared with unauthorized parties.'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isAccepted,
                    activeColor: appColors.accent,
                    checkColor: appColors.background,
                    onChanged: (val) {
                      setState(() {
                        _isAccepted = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I accept the Terms & Conditions and Privacy Policy',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: appColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.background,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppColors appColors, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: appColors.accent, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(AppColors appColors, String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, top: 6.h, bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: appColors.accent, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: appColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
