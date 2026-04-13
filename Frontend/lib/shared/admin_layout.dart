import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/admin_dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/admin_users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/admin_analytics');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
