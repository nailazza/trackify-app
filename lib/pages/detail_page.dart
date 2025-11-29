// lib/pages/detail_page.dart
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../utils/colors.dart';

class DetailPage extends StatelessWidget {
  final Activity activity;
  const DetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Detail'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: AppColors.text,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  activity.category,
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  '${activity.startTime ?? 'N/A'} - ${activity.endTime ?? 'N/A'}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activity.duration != null)
              Text(
                'Duration: ${activity.duration} minutes',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 16),
            const Text('Note:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(activity.note ?? 'No notes'),
          ],
        ),
      ),
    );
  }
}
