import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:action_slider/action_slider.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final attendanceService = ref.watch(attendanceServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar),
            onPressed: () => context.go('/employee/attendance/calendar'),
          ),
          IconButton(
            icon: const Icon(Iconsax.document),
            onPressed: () => context.go('/employee/attendance/list'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Mark Today\'s Attendance', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 16),
            ActionSlider.standard(
              action: (controller) async {
                controller.loading();
                try {
                  await attendanceService.markAttendance(userId: userId, status: 'present');
                  controller.success();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attendance marked as Present')),
                  );
                } catch (e) {
                  controller.failure();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Slide to Mark Present', style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: 16),
            ActionSlider.standard(
              action: (controller) async {
                controller.loading();
                try {
                  await attendanceService.markAttendance(userId: userId, status: 'absent');
                  controller.success();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attendance marked as Absent')),
                  );
                } catch (e) {
                  controller.failure();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Slide to Mark Absent', style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}