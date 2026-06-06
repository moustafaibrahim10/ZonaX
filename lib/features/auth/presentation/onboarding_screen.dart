import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'terms_acceptance_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'AI-Powered Demand Heatmap',
      'description':
          'See real-time demand zones and navigate to high-earning areas with intelligent routing across Egypt',
      'image':
          'https://images.unsplash.com/photo-1514041181368-bca62cceffcd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0YXhpJTIwZHJpdmVyJTIwZGFzaGJvYXJkJTIwdmlld3xlbnwxfHx8fDE3ODA3NjY2NzJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    },
    {
      'title': 'Live Traffic Hot Spots',
      'description':
          'Track crowded areas and high-demand locations in Egypt updated every minute to maximize your earnings',
      'image':
          'https://images.unsplash.com/photo-1699781895588-d5822c2dd3d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxDYWlybyUyMGNpdHklMjB0cmFmZmljJTIwYWVyaWFsJTIwdmlld3xlbnwxfHx8fDE3ODA3NjY2NzF8MA&ixlib=rb-4.1.0&q=80&w=1080',
    },
    {
      'title': 'Smart Route Navigation',
      'description':
          'Get turn-by-turn directions to the busiest pickup points and avoid traffic congestion in real-time',
      'image':
          'https://images.unsplash.com/photo-1652022262085-d454346a353e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwzfHxDYWlybyUyMEVneXB0JTIwc3RyZWV0cyUyMGJ1c3l8ZW58MXx8fHwxNzgwNzY2NjcyfDA&ixlib=rb-4.1.0&q=80&w=1080',
    },
  ];

  void _completeOnboarding() {
    Hive.box('app_box').put('onboarding_completed', true);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TermsAcceptanceScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Empty space for balance
                  SizedBox(width: 60.w),

                  // Center: Glowing Pin Icon
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: appColors.accent,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.accent.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  // Right: Skip Button
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // PageView for Onboarding Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Rounded Image Container
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Image.network(
                              page['image']!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: double.infinity,
                                      color: appColors.surface,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  color: appColors.surface,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        color: appColors.textHint,
                                        size: 48.sp,
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: appColors.textSecondary,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Title Text
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: appColors.textPrimary,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Description Text
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            page['description']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: appColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isActive ? 24.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? appColors.accent
                          : appColors.inputBorder,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // Bottom Button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _currentPage < 2
                    ? TextButton(
                        key: const ValueKey('next_button'),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                color: appColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.chevron_right,
                              color: appColors.textPrimary,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('start_button'),
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _completeOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: appColors.background,
                            ),
                          ),
                        ),
                      ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
