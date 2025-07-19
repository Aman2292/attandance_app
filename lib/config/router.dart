import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/admin/report_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/splash/splash_screen.dart'; 
import '../features/dashboard/dashboard_screen.dart';
import '../features/attendance/attendance_screen.dart';
import '../features/attendance/attendance_list_screen.dart';
import '../features/attendance/attendance_calendar_screen.dart';
import '../features/leave/leave_screen.dart';
import '../features/leave/apply_leave_screen.dart';
import '../features/leave/leave_history_screen.dart';
import '../features/report/report_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/manage_users_screen.dart';
import '../features/admin/approve_leave_screen.dart';
import '../features/admin/attendance_overview_screen.dart';
import '../features/settings/settings_screen.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authService = AuthService();

final routerConfig = GoRouter(
  initialLocation: '/splash', // Changed from '/login' to '/splash'
  redirect: (context, state) async {
    // Skip redirect logic for splash screen
    if (state.matchedLocation == '/splash') {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    // Wait for auth state to settle
    await Future.delayed(const Duration(milliseconds: 300));

    // If no user and not on login/signup page, redirect to login
    if (user == null && state.matchedLocation != '/login' && state.matchedLocation != '/signup') {
      await prefs.setBool('isLoggedIn', false);
      return '/login';
    }

    // If user exists, redirect based on role
    if (user != null) {
      await prefs.setBool('isLoggedIn', true);
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          if (userModel.role == 'employee' && !state.matchedLocation.startsWith('/employee') && !state.matchedLocation.startsWith('/admin')) {
            return '/employee';
          } else if (userModel.role == 'admin' && !state.matchedLocation.startsWith('/admin') && !state.matchedLocation.startsWith('/employee')) {
            return '/admin';
          }
        }
      } catch (e) {
        // Handle any errors in fetching user data
        print('Error fetching user data: $e');
        return '/login';
      }
    }

    // If flag is true but user is null (e.g., token expired), clear flag and redirect
    if (user == null && isLoggedIn) {
      await prefs.setBool('isLoggedIn', false);
      return '/login';
    }

    return null;
  },
  routes: [
    // Add splash screen route
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => BottomNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employee',
              builder: (context, state) => const UserDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employee/attendance',
              builder: (context, state) => const AttendanceScreen(),
              routes: [
                GoRoute(
                  path: 'list',
                  builder: (context, state) => const AttendanceListScreen(),
                ),
                GoRoute(
                  path: 'calendar',
                  builder: (context, state) => const CalendarScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employee/report',
              builder: (context, state) => const ReportScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employee/leave',
              builder: (context, state) => const LeaveScreen(),
              routes: [
                GoRoute(
                  path: 'apply',
                  builder: (context, state) => const ApplyLeaveScreen(),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const LeaveHistoryScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/employee/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'manage-users',
          builder: (context, state) => const ManageUsersScreen(),
        ),
        GoRoute(
          path: 'approve-leave',
          builder: (context, state) => const ApproveLeaveScreen(),
        ),
        GoRoute(
          path: 'attendance-overview',
          builder: (context, state) => const AttendanceOverviewScreen(),
        ),
        GoRoute(
          path: 'report-overview',
          builder: (context, state) => const ReportOverviewScreen(),
        ),
      ],
    ),
  ],
);
