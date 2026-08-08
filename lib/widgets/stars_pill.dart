import 'package:flutter/material.dart';
import '../services/app_state.dart';

class StarsPill extends StatelessWidget {
  final AppState app;

  const StarsPill({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFFFFD54F), size: 26),
          const SizedBox(width: 8),
          Text(
            '${app.t('total_stars')}: ${app.totalStars}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
