import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/activity_card.dart';
import '../models/activity.dart';
import '../utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = SupabaseService();

  List<Activity> activities = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  Future<void> loadActivities() async {
    final data = await service.getActivities();
    setState(() {
      activities = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        centerTitle: false,
        title: const Text(
          "Trackify",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : activities.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 84,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Belum ada aktivitas",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tekan tombol + untuk menambah aktivitas baru",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tambah Aktivitas',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/add');
                        loadActivities();
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                return ActivityCard(
                  activity: activities[i],
                  onDelete: () async {
                    await service.deleteActivity(activities[i].id);
                    loadActivities();
                  },
                  onEdit: () async {
                    await Navigator.pushNamed(
                      context,
                      '/edit',
                      arguments: activities[i],
                    );
                    loadActivities();
                  },
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: activities[i],
                    );
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          loadActivities();
        },
      ),
    );
  }
}
