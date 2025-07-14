import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';

class LeaveFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Map<String, String> filterOptions;
  final String selectedStatusFilter;
  final Map<String, String> statusFilterOptions;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onStatusFilterChanged;

  const LeaveFilterChips({
    super.key,
    required this.selectedFilter,
    required this.filterOptions,
    required this.selectedStatusFilter,
    required this.statusFilterOptions,
    required this.onFilterChanged,
    required this.onStatusFilterChanged,
  });

  Widget _buildFilterChip({
    required String key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? selectedColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              
            ],
            Text(label),
          ],
        ),
        onSelected: (selected) {
          if (selected) onTap();
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: selectedColor ?? AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1,
        ),
        elevation: isSelected ? 2 : 0,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
    );
  }

  IconData _getFilterIcon(String key) {
    switch (key.toLowerCase()) {
      case 'all':
        return Iconsax.category;
      case 'today':
        return Iconsax.calendar_1;
      case 'this_week':
        return Iconsax.calendar_2;
      case 'this_month':
        return Iconsax.calendar;
      case 'paid':
        return Iconsax.calendar_tick;
      case 'sick':
        return Iconsax.health;
      case 'earned':
        return Iconsax.medal_star;
      default:
        return Iconsax.filter;
    }
  }

  IconData _getStatusIcon(String key) {
    switch (key.toLowerCase()) {
      case 'all':
        return Iconsax.category;
      case 'approved':
        return Iconsax.tick_circle;
      case 'pending':
        return Iconsax.clock;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _getStatusColor(String key) {
    switch (key.toLowerCase()) {
      case 'approved':
        return AppColors.approved.withOpacity(0.2);
      case 'pending':
        return AppColors.pending.withOpacity(0.2);
      case 'rejected':
        return AppColors.rejected.withOpacity(0.2);
      default:
        return AppColors.primary.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row - Filter Options
          Row(
            children: [
              Icon(
                Iconsax.filter,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter by:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.entries.map((entry) {
                final isSelected = selectedFilter == entry.key;
                return _buildFilterChip(
                  key: entry.key,
                  label: entry.value,
                  isSelected: isSelected,
                  onTap: () => onFilterChanged(entry.key),
                  icon: _getFilterIcon(entry.key),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 5),
          
          // Second Row - Status Filter Options
          Row(
            children: [
              Icon(
                Iconsax.status,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Status:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statusFilterOptions.entries.map((entry) {
                final isSelected = selectedStatusFilter == entry.key;
                return _buildFilterChip(
                  key: entry.key,
                  label: entry.value,
                  isSelected: isSelected,
                  onTap: () => onStatusFilterChanged(entry.key),
                  icon: _getStatusIcon(entry.key),
                  selectedColor: _getStatusColor(entry.key),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}