import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/routes.dart';

import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';

import 'features/user/user_provider.dart';
import 'features/user/dashboard_screen.dart';
import 'features/user/history_screen.dart';
import 'features/user/rewards_screen.dart';
import 'features/user/profile_screen.dart';

import 'features/admin/admin_provider.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/admin/user_management_screen.dart';
import 'features/admin/analytics_screen.dart';

import 'shared/user_layout.dart';
import 'shared/admin_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(context.read<AuthProvider>().currentUser),
          update: (context, auth, previous) => UserProvider(auth.currentUser),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoReward',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        
        // User Routes wrapped in BottomNavigationBar
        AppRoutes.userDashboard: (context) => const UserLayout(currentIndex: 0, child: DashboardScreen()),
        '/waste_history': (context) => const UserLayout(currentIndex: 1, child: HistoryScreen()),
        '/rewards': (context) => const UserLayout(currentIndex: 2, child: RewardsScreen()),
        '/profile': (context) => const UserLayout(currentIndex: 3, child: ProfileScreen()),
        
        // Admin Routes wrapped in Drawer
        AppRoutes.adminDashboard: (context) => const AdminLayout(title: 'Admin Dashboard', child: AdminDashboard()),
        '/admin_users': (context) => const AdminLayout(title: 'User Management', child: UserManagementScreen()),
        '/admin_analytics': (context) => const AdminLayout(title: 'Analytics', child: AnalyticsScreen()),
      },
    );
  }
}
