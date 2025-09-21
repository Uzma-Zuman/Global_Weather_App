import 'package:flutter/material.dart';

import 'glass-card.dart';

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(
            '⚠️ $message',
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          )
        ],
      ),
    );
  }
}
