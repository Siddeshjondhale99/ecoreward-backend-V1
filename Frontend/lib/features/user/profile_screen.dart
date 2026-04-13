import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 24),
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('RFID Tag ID'),
                  subtitle: Text(user.rfid),
                  trailing: const Icon(Icons.content_copy),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
