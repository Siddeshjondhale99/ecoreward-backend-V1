import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_provider.dart';
import '../../shared/stat_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final stats = provider.categoryStats;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Users',
                  value: '${provider.allUsers.length}',
                  icon: Icons.people,
                  iconColor: Colors.blue,
                ),
              ),
              Expanded(
                child: StatCard(
                  title: 'Total Waste (kg)',
                  value: provider.totalWasteCollected.toStringAsFixed(1),
                  icon: Icons.delete_sweep,
                  iconColor: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatCard(
            title: 'Points Awarded',
            value: '${provider.totalPointsAwarded}',
            icon: Icons.card_giftcard,
            iconColor: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatRow('Plastic', stats['plastic'] ?? 0, Colors.orange),
                  const Divider(),
                  _buildStatRow('Wet Waste', stats['wet'] ?? 0, Colors.green),
                  const Divider(),
                  _buildStatRow('Dry Waste', stats['dry'] ?? 0, Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 6, backgroundColor: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Text('${value.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
