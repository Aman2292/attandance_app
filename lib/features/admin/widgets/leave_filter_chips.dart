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
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          if (selected) onTap();
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: selectedColor ?? AppColors.primary,
        checkmarkColor: Colors.white,
        elevation: isSelected ? 4 : 0,
        shadowColor: (selectedColor ?? AppColors.primary).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? (selectedColor ?? AppColors.primary) : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(String key) {
    switch (key.toLowerCase()) {
      case 'all':
        return Iconsax.category;
      case 'sick':
        return Iconsax.health;
      case 'paid':
        return Iconsax.money;
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
        return AppColors.success;
      case 'pending':
        return AppColors.pending;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.5), AppColors.primary.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.filter,
                size: 16,
                color: AppColors.surface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Filter by Leave Type',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
          ],
        ),
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
                selectedColor: AppColors.surface,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.5), AppColors.primary.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.status,
                size: 16,
                color: AppColors.surface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Filter by Status',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
          ],
        ),
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
    );
  }
}