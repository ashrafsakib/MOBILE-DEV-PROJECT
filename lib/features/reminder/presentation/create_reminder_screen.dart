import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/local_reminder_repository.dart';
import '../data/notification_service.dart';
import '../domain/reminder.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  DateTime? _scheduledDate;
  bool _isSaving = false;

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty || _scheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and date are required.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final reminder = Reminder(
      id: const Uuid().v4(),
      title: _titleController.text,
      subtitle: _subtitleController.text,
      scheduledDate: _scheduledDate!,
    );
    await LocalReminderRepository().addReminder(reminder);
    await NotificationService.scheduleReminderNotification(reminder);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Subtitle'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _scheduledDate == null
                        ? 'No date selected'
                        : 'Scheduled: \\${_scheduledDate!}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                        const Duration(minutes: 1),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _scheduledDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text('Pick Date & Time'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveReminder,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
