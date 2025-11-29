// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<List<Activity>> getActivities({DateTime? forDate}) async {
    final select = supabase
        .from('activities')
        .select()
        .order('start_time', ascending: false);

    final data = await select; // returns List<dynamic>
    return (data as List)
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Activity> getActivity(String id) async {
    final data = await supabase
        .from('activities')
        .select()
        .eq('id', id)
        .single();
    return Activity.fromJson(data);
  }

  Future<void> addActivity(Activity a) async {
    try {
      final jsonData = a.toJson();
      print('Sending to Supabase: $jsonData');
      await supabase.from('activities').insert(jsonData);
    } catch (e) {
      print('Error adding activity: $e');
      rethrow;
    }
  }

  Future<void> updateActivity(Activity a) async {
    await supabase.from('activities').update(a.toJson()).eq('id', a.id);
  }

  Future<void> deleteActivity(String id) async {
    await supabase.from('activities').delete().eq('id', id);
  }

  String generateId() => _uuid.v4();
}
