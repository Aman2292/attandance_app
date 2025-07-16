
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/admin_report_provider.dart';
import 'widgets/searchbar_reports.dart';
import 'widgets/user_details_widget.dart';
import 'widgets/user_lists_widget.dart';


class ReportOverviewScreen extends ConsumerStatefulWidget {
  const ReportOverviewScreen({super.key});

  @override
  ConsumerState<ReportOverviewScreen> createState() => _ReportOverviewScreenState();
}

class _ReportOverviewScreenState extends ConsumerState<ReportOverviewScreen> {
  String? selectedUserId;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final attendanceAsync = selectedUserId != null ? ref.watch(userAttendanceProvider(selectedUserId!)) : null;
    final leavesAsync = selectedUserId != null ? ref.watch(userLeavesProvider(selectedUserId!)) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        title: Text(
          'User Activity Reports',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SearchBarWidget(
                controller: _searchController,
                searchQuery: searchQuery,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
              ),
              UserListWidget(
                usersAsync: usersAsync,
                searchQuery: searchQuery,
                onUserSelected: (userId) {
                  setState(() {
                    selectedUserId = userId;
                  });
                },
              ),
            ],
          ),
          if (selectedUserId != null && attendanceAsync != null && leavesAsync != null)
            UserDetailsWidget(
              userId: selectedUserId!,
              attendanceAsync: attendanceAsync,
              leavesAsync: leavesAsync,
              usersAsync: usersAsync,
              onClose: () {
                setState(() {
                  selectedUserId = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
