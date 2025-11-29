// lib/pages/add_activity_page.dart
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/supabase_service.dart';
import '../utils/colors.dart';
import '../utils/format.dart';

class AddActivityPage extends StatefulWidget {
  final Activity? edit; // kalau mau edit, pass Activity melalui constructor

  const AddActivityPage({super.key, this.edit});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _service = SupabaseService();

  final TextEditingController _titleC = TextEditingController();
  final TextEditingController _noteC = TextEditingController();
  String _category = 'Other';

  DateTime? _start;
  DateTime? _end;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) _populateForEdit(widget.edit!);
  }

  void _populateForEdit(Activity e) {
    _titleC.text = e.title;
    _noteC.text = e.note ?? '';
    _category = e.category;
    _start = e.startTime != null ? DateTime.parse(e.startTime!) : null;
    _end = e.endTime != null ? DateTime.parse(e.endTime!) : null;
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = (isStart ? _start : _end) ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart)
        _start = combined;
      else
        _end = combined;
    });
  }

  Future<void> _save() async {
    if (_titleC.text.trim().isEmpty) {
      _showSnack('Please enter a title');
      return;
    }
    if (_category.trim().isEmpty) {
      _showSnack('Please select a category');
      return;
    }
    if (_start == null || _end == null) {
      _showSnack('Please pick start and end time');
      return;
    }
    if (!_end!.isAfter(_start!)) {
      _showSnack('End time must be after start time');
      return;
    }

    setState(() => _loading = true);

    try {
      final id = widget.edit?.id ?? _service.generateId();
      final startTimeStr = _start?.toIso8601String();
      final endTimeStr = _end?.toIso8601String();
      final durationMinutes = _end != null && _start != null
          ? _end!.difference(_start!).inMinutes
          : null;

      final activity = Activity(
        id: id,
        title: _titleC.text.trim(),
        category: _category.trim(),
        startTime: startTimeStr,
        endTime: endTimeStr,
        note: _noteC.text.trim(),
        duration: durationMinutes,
      );

      if (widget.edit != null) {
        await _service.updateActivity(activity);
      } else {
        await _service.addActivity(activity);
      }

      if (mounted)
        Navigator.of(context).pop(true); // return true agar caller refresh
    } catch (e) {
      _showSnack('Failed to save activity. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _titleC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startText = _start == null ? 'Pick start' : F.datetime(_start!);
    final endText = _end == null ? 'Pick end' : F.datetime(_end!);
    final isEditing = widget.edit != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(isEditing ? 'Edit Activity' : 'Add Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(label: 'Title', controller: _titleC),
                  const SizedBox(height: 12),
                  _buildCategoryField(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Note (optional)',
                    controller: _noteC,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _timeBox(
                          label: 'Start',
                          value: startText,
                          onTap: () => _pickDateTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeBox(
                          label: 'End',
                          value: endText,
                          onTap: () => _pickDateTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _loading
                          ? 'Saving...'
                          : (isEditing ? 'Update Activity' : 'Save Activity'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _timeBox({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return TextField(
      controller: TextEditingController(text: _category),
      onChanged: (v) => _category = v,
      decoration: InputDecoration(
        labelText: 'Category',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (v) => setState(() => _category = v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'Work', child: Text('Work')),
            PopupMenuItem(value: 'Personal', child: Text('Personal')),
            PopupMenuItem(value: 'Health', child: Text('Health')),
            PopupMenuItem(value: 'Education', child: Text('Education')),
            PopupMenuItem(value: 'Study', child: Text('Study')),
            PopupMenuItem(value: 'Exercise', child: Text('Exercise')),
            PopupMenuItem(value: 'Other', child: Text('Other')),
          ],
        ),
      ),
    );
  }
}
