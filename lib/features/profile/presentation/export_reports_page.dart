import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';

class ExportReportsPage extends StatefulWidget {
  const ExportReportsPage({super.key});

  @override
  State<ExportReportsPage> createState() => _ExportReportsPageState();
}

class _ExportReportsPageState extends State<ExportReportsPage> {
  String selectedPeriod = 'monthly';
  String selectedFormat = 'pdf';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!.copyWith(
      background: const Color(0xFF0F111A),
      surface: const Color(0xFF1E1E2A),
      inputBorder: Colors.white10,
      accent: const Color(0xFF00D293),
      textPrimary: Colors.white,
      textSecondary: Colors.grey,
    );

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
          'Export Reports',
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
            // Select Period Section
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Period',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      _buildPeriodButton(appColors, 'This Week', 'weekly'),
                      _buildPeriodButton(appColors, 'This Month', 'monthly'),
                      _buildPeriodButton(appColors, 'Last Month', 'last_month'),
                      _buildPeriodButton(appColors, 'This Year', 'yearly'),
                      _buildPeriodButton(appColors, 'Custom', 'custom'),
                    ],
                  ),
                ],
              ),
            ),

            // Select Format Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Format',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFormatOption(appColors, 'PDF', 'pdf', Icons.picture_as_pdf),
                      _buildFormatOption(appColors, 'CSV', 'csv', Icons.table_chart),
                      _buildFormatOption(appColors, 'Excel', 'excel', Icons.grid_on),
                      _buildFormatOption(appColors, 'JSON', 'json', Icons.code),
                    ],
                  ),
                ],
              ),
            ),

            // Report Preview Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                'Report Preview',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: appColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: appColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewRow(appColors, 'Report Period:', 'This Month'),
                    SizedBox(height: 12.h),
                    _buildPreviewRow(appColors, 'Total Earnings:', '\$14,500.00'),
                    SizedBox(height: 12.h),
                    _buildPreviewRow(appColors, 'Total Trips:', '324'),
                    SizedBox(height: 12.h),
                    _buildPreviewRow(appColors, 'Online Hours:', '186h'),
                    SizedBox(height: 12.h),
                    _buildPreviewRow(appColors, 'Average Rating:', '4.8 ⭐'),
                    SizedBox(height: 12.h),
                    _buildPreviewRow(appColors, 'Export Format:', selectedFormat.toUpperCase()),
                  ],
                ),
              ),
            ),

            // Export History Section
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 32.h, bottom: 12.h),
              child: Text(
                'Previous Exports',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildExportHistoryItem(appColors, 'Monthly Report - May 2024', 'PDF', '2024-05-15'),
                  SizedBox(height: 12.h),
                  _buildExportHistoryItem(appColors, 'Quarterly Report - Q1 2024', 'Excel', '2024-04-01'),
                  SizedBox(height: 12.h),
                  _buildExportHistoryItem(appColors, 'Monthly Report - April 2024', 'PDF', '2024-04-15'),
                ],
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: appColors.surface,
          border: Border(top: BorderSide(color: appColors.inputBorder)),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _exportReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.accent,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(appColors.background),
                  ),
                )
              : Text(
                  'Export Report',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: appColors.background,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(AppColors appColors, String label, String value) {
    final isSelected = selectedPeriod == value;
    return InkWell(
      onTap: () => setState(() => selectedPeriod = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? appColors.accent : appColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? appColors.accent : appColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? appColors.background : appColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOption(
    AppColors appColors,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = selectedFormat == value;
    return InkWell(
      onTap: () => setState(() => selectedFormat = value),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected ? appColors.accent : appColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? appColors.accent : appColors.inputBorder,
              ),
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: isSelected ? appColors.background : appColors.accent,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(AppColors appColors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: appColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: appColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportHistoryItem(
    AppColors appColors,
    String title,
    String format,
    String date,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: appColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  format,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: appColors.accent,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.download, color: appColors.accent, size: 20.sp),
            ],
          ),
        ],
      ),
    );
  }

  void _exportReport() async {
    setState(() => isLoading = true);

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported as $selectedFormat'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

