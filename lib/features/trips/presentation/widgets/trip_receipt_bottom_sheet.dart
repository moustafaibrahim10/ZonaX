import 'package:flutter/material.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import '../../data/models/trip_receipt_model.dart';

class TripReceiptBottomSheet extends StatelessWidget {
  final TripReceiptModel receipt;

  const TripReceiptBottomSheet({super.key, required this.receipt});

  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  size: 64,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Trip Completed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildRow("Duration", "${receipt.durationMinutes} mins", appColors),
              _buildRow("Base Fare", "\$${receipt.baseFare.toStringAsFixed(2)}", appColors),
              _buildRow("Surge Multiplier", "${receipt.surgeMultiplier}x", appColors),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: appColors.divider),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Earnings",
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "\$${receipt.totalFare.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: appColors.textSecondary, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
