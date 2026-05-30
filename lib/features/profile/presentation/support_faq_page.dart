import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';

class SupportFAQPage extends StatefulWidget {
  const SupportFAQPage({super.key});

  @override
  State<SupportFAQPage> createState() => _SupportFAQPageState();
}

class _SupportFAQPageState extends State<SupportFAQPage> {
  int selectedFAQIndex = -1;

  // TODO: Replace with API call to fetch FAQs from backend
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I update my payment method?',
      'answer': 'Go to Settings > Payment Methods to add or update your payment methods.',
    },
    {
      'question': 'What fees does ZonaX charge?',
      'answer': 'ZonaX takes a 15% commission from your earnings.',
    },
    {
      'question': 'How long does withdrawal take?',
      'answer': 'Withdrawals typically take 2-3 business days to appear in your account.',
    },
    {
      'question': 'How is my rating calculated?',
      'answer': 'Your rating is based on passenger feedback, punctuality, and vehicle cleanliness.',
    },
  ];

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
          'Support & FAQ',
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
            // Quick Contact Section
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildContactTile(appColors, Icons.email, 'Email', 'support@zonax.com'),
                  SizedBox(height: 8.h),
                  _buildContactTile(appColors, Icons.phone, 'Phone', '+1-800-ZONAX'),
                  SizedBox(height: 8.h),
                  _buildContactTile(appColors, Icons.chat, 'Live Chat', 'Available 24/7'),
                ],
              ),
            ),

            // FAQ Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(appColors, index);
                },
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    AppColors appColors,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: appColors.accent, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: appColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(AppColors appColors, int index) {
    final faq = faqs[index];
    final isExpanded = selectedFAQIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFAQIndex = isExpanded ? -1 : index;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      faq['question']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: appColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: appColors.accent,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.w),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: appColors.inputBorder),
                  ),
                ),
                child: Text(
                  faq['answer']!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: appColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

