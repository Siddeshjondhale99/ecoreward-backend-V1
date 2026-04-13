import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Waste Trends', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Weekly waste collection (mock data)'),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar(context, 'Mon', 0.4),
                    _buildBar(context, 'Tue', 0.6),
                    _buildBar(context, 'Wed', 0.3),
                    _buildBar(context, 'Thu', 0.8),
                    _buildBar(context, 'Fri', 0.5),
                    _buildBar(context, 'Sat', 0.7),
                    _buildBar(context, 'Sun', 0.4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double heightRatio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 30,
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}

