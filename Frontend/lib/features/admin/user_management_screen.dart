import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_provider.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AdminProvider>().allUsers;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registered Users', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${user.email}\nRFID: ${user.rfid}'),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Points', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          '${user.points}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
