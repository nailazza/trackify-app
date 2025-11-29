// lib/models/activity.dart
class Activity {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final String? date;
  final int? duration;
  final String category;
  final String? note;
  final String? startTime;
  final String? endTime;
  final String? createdAt;

  Activity({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    this.date,
    this.duration,
    required this.category,
    this.note,
    this.startTime,
    this.endTime,
    this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'],
      duration: json['duration'],
      category: json['category'] ?? 'Other',
      note: json['note'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
    };

    if (userId != null) json['user_id'] = userId!;
    if (description != null) json['description'] = description!;

    // Extract date from startTime if date is not provided
    final dateToSend =
        date ?? (startTime != null ? startTime!.split('T')[0] : null);
    if (dateToSend != null) json['date'] = dateToSend;

    if (duration != null) json['duration'] = duration!;
    if (note != null) json['note'] = note!;
    if (startTime != null) json['start_time'] = startTime!;
    if (endTime != null) json['end_time'] = endTime!;

    return json;
  }
}
