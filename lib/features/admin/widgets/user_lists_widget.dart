import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../models/user_model.dart';

import 'package:iconsax/iconsax.dart';

import '../report_utils.dart';

class UserWithId {
  final UserModel user;
  final String id;

  UserWithId({required this.user, required this.id});
}

class UserListWidget extends StatelessWidget {
  final AsyncValue<List<UserWithId>> usersAsync;
  final String searchQuery;
  final ValueChanged<String> onUserSelected;

  const UserListWidget({
    super.key,
    required this.usersAsync,
    required this.searchQuery,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: usersAsync.when(
        data: (usersWithId) {
          final filteredUsers = usersWithId.where((userWithId) {
            if (searchQuery.isEmpty) return true;
            return userWithId.user.name.toLowerCase().contains(searchQuery) ||
                userWithId.user.email.toLowerCase().contains(searchQuery);
          }).toList();

          if (filteredUsers.isEmpty) {
            return ReportUtils.buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userWithId = filteredUsers[index];
              return _buildModernUserCard(context, userWithId);
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (e, stackTrace) {
          print('Error loading users: $e, StackTrace: $stackTrace');
          return ReportUtils.buildErrorState(() {});
        },
      ),
    );
  }

  Widget _buildModernUserCard(BuildContext context, UserWithId userWithId) {
    final user = userWithId.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onUserSelected(userWithId.id),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Enhanced Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.verified
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.verified
                                      ? Iconsax.verify
                                      : Iconsax.close_circle,
                                  size: 12,
                                  color: user.verified
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.verified ? 'Verified' : 'Not Verified',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: user.verified
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  
                  children: [
                    // Role Badge
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: user.role == 'admin'
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: user.role == 'admin'
                              ? AppColors.warning
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      Iconsax.arrow_right_3,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
