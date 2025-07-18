import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';

class LeaveBalanceWidget extends StatelessWidget {
  final UserModel user;

  const LeaveBalanceWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.calendar_tick,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Leave Balance',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Main content container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildLeaveBalanceCard(
                        'Paid Leave',
                        user.leaveBalance.paidLeave,
                        AppConstants.defaultPaidLeaves, // Using constant
                        [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        Iconsax.calendar,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLeaveBalanceCard(
                        'Sick Leave',
                        user.leaveBalance.sickLeave,
                        AppConstants.defaultSickLeaves, // Using constant
                        [AppColors.error, AppColors.error.withOpacity(0.8)],
                        Iconsax.health,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLeaveBalanceCard(
                        'Earned Leave',
                        user.leaveBalance.earnedLeave,
                        user.leaveBalance.earnedLeave , // Dynamic total
                        [AppColors.success, AppColors.success.withOpacity(0.8)],
                        Iconsax.star,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLeaveBalanceCard(
                        'Total Available',
                        user.leaveBalance.paidLeave + user.leaveBalance.sickLeave + user.leaveBalance.earnedLeave,
                        AppConstants.defaultPaidLeaves + AppConstants.defaultSickLeaves ,
                        [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                        Iconsax.calendar_2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveBalanceCard(
    String title,
    int available,
    int total,
    List<Color> gradientColors,
    IconData icon,
  ) {
    final percentage = total > 0 ? (available / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradientColors[0].withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gradientColors[0].withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const Spacer(),
              Text(
                '$available/$total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: gradientColors[0],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: gradientColors[0].withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(gradientColors[0]),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
