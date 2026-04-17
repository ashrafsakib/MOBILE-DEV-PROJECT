import 'package:flutter/material.dart';

import '../data/local_reminder_repository.dart';
import '../data/notification_service.dart';
import '../domain/reminder.dart';
import 'create_reminder_screen.dart';
import 'reminder_list_widget.dart';

class ReminderTabScreen extends StatefulWidget {
  const ReminderTabScreen({super.key});

  @override
  State<ReminderTabScreen> createState() => _ReminderTabScreenState();
}

class _ReminderTabScreenState extends State<ReminderTabScreen> {
  List<Reminder> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    NotificationService.initialize();
  }

  Future<void> _loadReminders() async {
    final reminders = await LocalReminderRepository().getReminders();
    setState(() {
      _reminders = reminders;
      _loading = false;
    });
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await LocalReminderRepository().deleteReminder(reminder.id);
    await NotificationService.cancelReminderNotification(reminder.id);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ReminderListWidget(
              reminders: _reminders,
              onDelete: _deleteReminder,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateReminderScreen()),
          );
          if (created == true) _loadReminders();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
