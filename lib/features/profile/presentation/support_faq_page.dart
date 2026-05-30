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

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I update my payment method?',
      'answer':
          'Go to Settings > Payment Methods to add, update, or remove your payment methods. We support credit cards, debit cards, and digital wallets.',
    },
    {
      'question': 'What fees does ZonaX charge?',
      'answer':
          'ZonaX takes a 15% commission from your earnings. We also charge a small transaction fee for certain payment methods. You can see the exact breakdown in your earnings section.',
    },
    {
      'question': 'How long does it take to withdraw my earnings?',
      'answer':
          'Withdrawals typically take 2-3 business days to appear in your bank account. Weekend and holiday withdrawals may take longer.',
    },
    {
      'question': 'How is my rating calculated?',
      'answer':
          'Your rating is based on passenger feedback, punctuality, vehicle cleanliness, and safety records. Ratings are updated in real-time after each trip.',
    },
    {
      'question': 'Can I cancel a trip after accepting it?',
      'answer':
          'You can cancel within 2 minutes of accepting a trip without any penalty. Cancellations after 2 minutes may result in a small fee.',
    },
    {
      'question': 'How do I report an issue with a trip?',
      'answer':
          'After completing a trip, you can report any issues through the trip details page. Our support team will investigate and respond within 24 hours.',
    },
    {
      'question': 'Is my personal information secure?',
      'answer':
          'Yes, we use industry-standard encryption and security measures to protect your data. Your information is never shared with third parties.',
    },
    {
      'question': 'How do I contact customer support?',
      'answer': 'You can reach our support team via email (support@zonax.com), phone (+1-800-ZONAX-HELP), or in-app chat. We\'re available 24/7.',
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
                    'Need Immediate Help?',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactButton(
                          appColors,
                          Icons.phone,
                          'Call Us',
                          'appColors.accent',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildContactButton(
                          appColors,
                          Icons.chat,
                          'Chat Now',
                          'appColors.accent',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildContactButton(
                    appColors,
                    Icons.email,
                    'Email Support (support@zonax.com)',
                    'appColors.accent',
                  ),
                ],
              ),
            ),

            // FAQ Search Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search FAQ...',
                  hintStyle: TextStyle(color: appColors.textSecondary),
                  prefixIcon: Icon(Icons.search, color: appColors.textSecondary),
                  filled: true,
                  fillColor: appColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: appColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: appColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: appColors.accent),
                  ),
                ),
              ),
            ),

            // FAQ List
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

            // Help Center Link
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: appColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: appColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visit Our Help Center',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: appColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Browse articles and guides',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16.sp, color: appColors.accent),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
    AppColors appColors,
    IconData icon,
    String label,
    String colorRef,
  ) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label - Feature coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: appColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: appColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: appColors.accent, size: 20.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: appColors.accent,
              ),
            ),
          ],
        ),
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

