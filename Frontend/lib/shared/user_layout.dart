import 'dart:ui';
import 'package:flutter/material.dart';

class UserLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const UserLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/user_dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/waste_history');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/rewards');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for glassmorphism effect
      body: widget.child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  labelTextStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
                  ),
                ),
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: widget.currentIndex,
                  onDestinationSelected: _onItemTapped,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded, color: Colors.white54),
                      selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.white),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_rounded, color: Colors.white54),
                      selectedIcon: Icon(Icons.history_rounded, color: Colors.white),
                      label: 'History',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.card_giftcard_rounded, color: Colors.white54),
                      selectedIcon: Icon(Icons.card_giftcard_rounded, color: Colors.white),
                      label: 'Rewards',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_rounded, color: Colors.white54),
                      selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
