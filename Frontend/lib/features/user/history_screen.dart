import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final submissions = context.watch<UserProvider>().mySubmissions;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Waste History', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Expanded(
            child: submissions.isEmpty
                ? const Center(child: Text('No submissions yet.'))
                : ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final sub = submissions[index];
                      IconData icon;
                      Color color;
                      switch (sub.category.toLowerCase()) {
                        case 'plastic':
                          icon = Icons.recycling;
                          color = Colors.orange;
                          break;
                        case 'wet':
                          icon = Icons.compost;
                          color = Colors.green;
                          break;
                        default:
                          icon = Icons.delete_outline;
                          color = Colors.blue;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.2),
                            child: Icon(icon, color: color),
                          ),
                          title: Text('${sub.weightKg} kg ${sub.category} waste'),
                          subtitle: Text(DateFormat.yMMMd().add_jm().format(sub.date)),
                          trailing: Text(
                            '+${sub.pointsEarned} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
