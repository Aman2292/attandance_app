
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/leave_record.dart';
import '../../../models/attendance_record.dart' as models;
import '../../../models/user_model.dart';
import '../utils/report_utils.dart';
import 'user_lists_widget.dart';


class UserDetailsWidget extends StatelessWidget {
  final String userId;
  final AsyncValue<List<models.AttendanceRecord>> attendanceAsync;
  final AsyncValue<List<LeaveRecord>> leavesAsync;
  final AsyncValue<List<UserWithId>> usersAsync;
  final VoidCallback onClose;

  const UserDetailsWidget({
    super.key,
    required this.userId,
    required this.attendanceAsync,
    required this.leavesAsync,
    required this.usersAsync,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.surface, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Iconsax.user, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'User Activity Report',
                        style: AppTextStyles.heading3.copyWith(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Iconsax.close_circle, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _buildUserDetailsContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailsContent(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Modern Tab Bar
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyles.bodySmall,
              tabs: const [
                Tab(text: 'Attendance \nRecords'),
                Tab(text: 'Leave \nBalance'),
                Tab(text: 'Break \nRecords'),
              ],
            ),
          ),
          // Tab Content with proper scrolling
          Expanded(
            child: TabBarView(
              children: [
                _buildAttendanceTab(),
                _buildLeaveBalanceTab(),
                _buildBreakRecordsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return attendanceAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return ReportUtils.buildEmptyTabContent('No attendance records found', Iconsax.calendar);
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: ReportUtils.getAttendanceStatusColor(record.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        ReportUtils.getAttendanceStatusIcon(record.status),
                        color: ReportUtils.getAttendanceStatusColor(record.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                record.date.toString().substring(0, 10),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ReportUtils.getAttendanceStatusColor(record.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  record.status.toUpperCase(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: ReportUtils.getAttendanceStatusColor(record.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                          
                            children: [
                              Icon(Iconsax.login, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'In: ${record.checkInTime?.toString().substring(11, 16) ?? 'Not recorded'}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 10),
                              Icon(Iconsax.logout, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 2),
                              Text(
                                'Out: ${record.checkOutTime?.toString().substring(11, 11) ?? 'Not recorded'}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          if (record.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Notes: ${record.notes}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                          if (record.isLate) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LATE ARRIVAL',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stackTrace) {
        print('Error loading attendance records: $e');
        return ReportUtils.buildErrorTabContent('Failed to load attendance records');
      },
    );
  }

  Widget _buildLeaveBalanceTab() {
    return leavesAsync.when(
      data: (leaves) {
        final approvedLeaves = leaves.where((l) => l.status == 'approved').length;
        final pendingLeaves = leaves.where((l) => l.status == 'pending').length;
        final rejectedLeaves = leaves.where((l) => l.status == 'rejected').length;

        final user = usersAsync.when(
          data: (usersWithId) => usersWithId
              .firstWhere(
                (u) => u.id == userId,
                orElse: () => UserWithId(
                  user: UserModel(
                    name: '',
                    email: '',
                    role: '',
                    verified: false,
                  ),
                  id: '',
                ),
              )
              .user,
          loading: () => null,
          error: (e, s) => null,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Balance Section
              if (user != null && user.email.isNotEmpty) ...[
                Text(
                  'Leave Balance',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ReportUtils.buildModernSummaryCard(
                        'Paid Leave',
                        '${user.leaveBalance.paidLeave}',
                        AppColors.success,
                        Iconsax.calendar_tick,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReportUtils.buildModernSummaryCard(
                        'Sick Leave',
                        '${user.leaveBalance.sickLeave}',
                        AppColors.info,
                        Iconsax.health,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ReportUtils.buildModernSummaryCard(
                        'Earned Leave',
                        '${user.leaveBalance.earnedLeave}',
                        AppColors.warning,
                        Iconsax.award,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReportUtils.buildModernSummaryCard(
                        'Total Requests',
                        '${leaves.length}',
                        AppColors.primary,
                        Iconsax.document_text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              // Leave Statistics
              Row(
                children: [
                  Expanded(
                    child: ReportUtils.buildModernSummaryCard(
                      'Approved',
                      '$approvedLeaves',
                      AppColors.success,
                      Iconsax.tick_circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ReportUtils.buildModernSummaryCard(
                      'Pending',
                      '$pendingLeaves',
                      AppColors.warning,
                      Iconsax.clock,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ReportUtils.buildModernSummaryCard(
                      'Rejected',
                      '$rejectedLeaves',
                      AppColors.error,
                      Iconsax.close_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Leave Requests',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Leave Records List
              if (leaves.isEmpty)
                ReportUtils.buildEmptyTabContent('No leave records found', Iconsax.calendar_remove)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaves.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final leave = leaves[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: ReportUtils.getLeaveStatusColor(leave.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.calendar_2,
                                    color: ReportUtils.getLeaveStatusColor(leave.status),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${leave.type.toUpperCase()} Leave',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${leave.startDate.toString().substring(0, 10)} - ${leave.endDate.toString().substring(0, 10)}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ReportUtils.getLeaveStatusColor(leave.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    leave.status.toUpperCase(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: ReportUtils.getLeaveStatusColor(leave.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Reason: ${leave.reason}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (leave.rejectionReason?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Rejection Reason: ${leave.rejectionReason}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stackTrace) {
        print('Error loading leave records: $e');
        return ReportUtils.buildErrorTabContent('Failed to load leave records');
      },
    );
  }

  Widget _buildBreakRecordsTab() {
    return attendanceAsync.when(
      data: (records) {
        final recordsWithBreaks = records
            .where((r) => r.breakStartTime != null || r.breakEndTime != null || r.totalBreakDuration > 0)
            .toList();

        if (recordsWithBreaks.isEmpty) {
          return ReportUtils.buildEmptyTabContent('No break records found', Iconsax.coffee);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: recordsWithBreaks.length,
          itemBuilder: (context, index) {
            final record = recordsWithBreaks[index];
            final breakDurationMinutes = (record.totalBreakDuration / 60).round();
            final isExceeded = breakDurationMinutes > 60;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Break Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isExceeded ? AppColors.warning.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.coffee,
                        color: isExceeded ? AppColors.warning : AppColors.info,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                record.date.toString().substring(0, 10),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isExceeded
                                      ? AppColors.warning.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isExceeded ? 'EXCEEDED' : 'NORMAL',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isExceeded ? AppColors.warning : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Iconsax.clock, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'Start: ${record.breakStartTime?.toString().substring(11, 16) ?? 'Not recorded'}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 16),
                              Icon(Iconsax.clock, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'End: ${record.breakEndTime?.toString().substring(11, 16) ?? 'Not recorded'}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Iconsax.timer, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'Duration: ${breakDurationMinutes}m',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isExceeded ? AppColors.warning : AppColors.textSecondary,
                                  fontWeight: isExceeded ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          if (isExceeded) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'BREAK TIME EXCEEDED',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stackTrace) {
        print('Error loading break records: $e');
        return ReportUtils.buildErrorTabContent('Failed to load break records');
      },
    );
  }
}
