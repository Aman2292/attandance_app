import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Present', 'Late', 'Absent'];

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final attendanceRecordsAsync = ref.watch(attendanceRecordsProvider(userId)); // Fixed provider name

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.filter, color: AppColors.surface, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filter:',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            selectedColor: AppColors.surface.withOpacity(1),
                            backgroundColor: AppColors.surface.withOpacity(0.5),
                            labelStyle: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Attendance List
          Expanded(
            child: attendanceRecordsAsync.when(
              data: (attendanceList) {
                final filteredList = _selectedFilter == 'All'
                    ? attendanceList
                    : attendanceList.where((attendance) {
                        return attendance.status.toString().toLowerCase().contains(_selectedFilter.toLowerCase());
                      }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.document_text,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records found',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final attendance = filteredList[index];
                    return _buildAttendanceCard(attendance);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading attendance history',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic attendance) {
    final statusColor = _getStatusColor(attendance.status.toString());
    final statusIcon = _getStatusIcon(attendance.status.toString());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(attendance.date),
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.1),
                        statusColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        attendance.status.toString().split('.').last.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Time Details
            Row(
              children: [
                Expanded(
                  child: _buildTimeDetail(
                    'Check In',
                    attendance.checkInTime != null 
                        ? DateFormat('hh:mm a').format(attendance.checkInTime!)
                        : 'Not checked in',
                    Iconsax.login,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeDetail(
                    'Check Out',
                    attendance.checkOutTime != null 
                        ? DateFormat('hh:mm a').format(attendance.checkOutTime!)
                        : 'Not checked out',
                    Iconsax.logout,
                    AppColors.error,
                  ),
                ),
              ],
            ),
            
            // Working Hours
            if (attendance.checkInTime != null && attendance.checkOutTime != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Iconsax.timer_1, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Working Hours: ${_calculateWorkHours(attendance.checkInTime!, attendance.checkOutTime!)}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info),
                  ),
                ],
              ),
            ],
            
            // Notes if any
            if (attendance.notes != null && attendance.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.message_text, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attendance.notes!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('present')) return AppColors.success;
    if (status.toLowerCase().contains('late')) return AppColors.warning;
    if (status.toLowerCase().contains('absent')) return AppColors.error;
    return AppColors.textHint;
  }

  IconData _getStatusIcon(String status) {
    if (status.toLowerCase().contains('present')) return Iconsax.tick_circle;
    if (status.toLowerCase().contains('late')) return Iconsax.clock;
    if (status.toLowerCase().contains('absent')) return Iconsax.close_circle;
    return Iconsax.info_circle;
  }

  String _calculateWorkHours(DateTime checkIn, DateTime checkOut) {
    final duration = checkOut.difference(checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
