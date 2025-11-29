import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/supabase_service.dart';
import '../utils/colors.dart';
import '../utils/format.dart';

class EditActivityPage extends StatefulWidget {
  final Activity activity;

  const EditActivityPage({Key? key, required this.activity}) : super(key: key);

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late String _selectedCategory;
  late DateTime? _selectedStartTime;
  late DateTime? _selectedEndTime;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title);
    _noteController = TextEditingController(text: widget.activity.note ?? '');

    // Parse start time if it exists
    try {
      _selectedStartTime = widget.activity.startTime != null
          ? DateTime.parse(widget.activity.startTime!)
          : null;
      _startTimeController = TextEditingController(
        text: _selectedStartTime != null ? _selectedStartTime.toString() : '',
      );
    } catch (e) {
      _selectedStartTime = null;
      _startTimeController = TextEditingController();
    }

    // Parse end time if it exists
    try {
      _selectedEndTime = widget.activity.endTime != null
          ? DateTime.parse(widget.activity.endTime!)
          : null;
      _endTimeController = TextEditingController(
        text: _selectedEndTime != null ? _selectedEndTime.toString() : '',
      );
    } catch (e) {
      _selectedEndTime = null;
      _endTimeController = TextEditingController();
    }

    _selectedCategory = widget.activity.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  String formatDateTime(DateTime dateTime) {
    return F.datetime(dateTime);
  }

  Future<void> _updateActivity() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    try {
      final updatedActivity = Activity(
        id: widget.activity.id,
        title: _titleController.text,
        category: _selectedCategory,
        startTime: _selectedStartTime?.toIso8601String(),
        endTime: _selectedEndTime?.toIso8601String(),
        note: _noteController.text,
        duration: _selectedStartTime != null && _selectedEndTime != null
            ? _selectedEndTime!.difference(_selectedStartTime!).inMinutes
            : null,
      );

      await _supabaseService.updateActivity(updatedActivity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity updated successfully')),
        );
        Navigator.pop(context, updatedActivity);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating activity: $e')));
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          (isStartTime ? _selectedStartTime : _selectedEndTime) ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          (isStartTime ? _selectedStartTime : _selectedEndTime) ??
              DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        final DateTime newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _selectedStartTime = newDateTime;
            _startTimeController.text = formatDateTime(newDateTime);
          } else {
            _selectedEndTime = newDateTime;
            _endTimeController.text = formatDateTime(newDateTime);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter activity title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Work', child: Text('Work')),
                      DropdownMenuItem(
                        value: 'Personal',
                        child: Text('Personal'),
                      ),
                      DropdownMenuItem(value: 'Health', child: Text('Health')),
                      DropdownMenuItem(
                        value: 'Education',
                        child: Text('Education'),
                      ),
                      DropdownMenuItem(value: 'Study', child: Text('Study')),
                      DropdownMenuItem(
                        value: 'Exercise',
                        child: Text('Exercise'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Start Time',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _startTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select start time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDateTime(context, true),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'End Time',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _endTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select end time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDateTime(context, false),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Note',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Enter activity note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _updateActivity,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
