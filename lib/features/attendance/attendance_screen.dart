import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Current Time', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    Text(
                      '12:00 PM', // Placeholder
                      style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    ActionSlider.standard(
                      action: (controller) async {
                        // Placeholder for check-in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checked In')),
                        );
                      },
                      backgroundColor: AppColors.surface,
                      toggleColor: AppColors.success,
                      icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
                      child: const Text('Slide to Check In', style: AppTextStyles.bodyLarge),
                    ),
                    const SizedBox(height: 16),
                    ActionSlider.standard(
                      action: (controller) async {
                        // Placeholder for check-out
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checked Out')),
                        );
                      },
                      backgroundColor: AppColors.surface,
                      toggleColor: AppColors.error,
                      icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
                      child: const Text('Slide to Check Out', style: AppTextStyles.bodyLarge),
                    ),
                    const SizedBox(height: 16),
                    ActionSlider.standard(
                      action: (controller) async {
                        // Placeholder for break
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Break Started/Ended')),
                        );
                      },
                      backgroundColor: AppColors.surface,
                     
                      icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
                      child: const Text('Slide for Break', style: AppTextStyles.bodyLarge),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}