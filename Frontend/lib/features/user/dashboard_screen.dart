import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import '../../shared/stat_card.dart';
import '../../shared/waste_category_card.dart';
import '../../core/theme.dart';
import 'package:camera/camera.dart';
import '../camera/camera_screen.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final breakdown = userProvider.categoryBreakdown;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by layout or main scaffold
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Extra bottom padding for floating bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user!.name}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to save the planet?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person_outline_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Total Points Card (Large High Impact)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL ECO POINTS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${userProvider.totalPoints}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Top 5% Eco-Warrior',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Daily Stat
              StatCard(
                title: "Today's Contribution",
                value: '${userProvider.todaysWasteWeight.toStringAsFixed(1)} kg',
                icon: Icons.auto_awesome,
                iconColor: Colors.cyanAccent,
              ),
              const SizedBox(height: 32),

              // Section Titles
              Text(
                'Waste Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Scrolling Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    WasteCategoryCard(
                      category: 'Dry',
                      weight: '${breakdown['dry']?.toStringAsFixed(1)} kg',
                      color: Colors.blueAccent,
                      icon: Icons.delete_outline,
                    ),
                    WasteCategoryCard(
                      category: 'Wet',
                      weight: '${breakdown['wet']?.toStringAsFixed(1)} kg',
                      color: Colors.greenAccent,
                      icon: Icons.compost,
                    ),
                    WasteCategoryCard(
                      category: 'Plastic',
                      weight: '${breakdown['plastic']?.toStringAsFixed(1)} kg',
                      color: Colors.orangeAccent,
                      icon: Icons.recycling,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showCameraScreen(context),
                      child: _buildQuickAction(context, Icons.qr_code_scanner, 'Scan Bin', Colors.purpleAccent),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAction(context, Icons.map_outlined, 'Drop-points', Colors.blueAccent),
                  const SizedBox(width: 16),
                  _buildQuickAction(context, Icons.emoji_events_outlined, 'Vouchers', Colors.amberAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraScreen(BuildContext context) async {
    final cameras = await availableCameras();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(cameras: cameras),
        ),
      );
    }
  }
}
