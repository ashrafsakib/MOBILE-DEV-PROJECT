import 'package:abroadready/features/reminder/data/local_reminder_repository.dart';
import 'package:abroadready/features/reminder/domain/reminder.dart';
import 'package:flutter/material.dart';

class UpcomingRemindersWidget extends StatefulWidget {
  const UpcomingRemindersWidget({super.key});

  @override
  State<UpcomingRemindersWidget> createState() =>
      _UpcomingRemindersWidgetState();
}

class _UpcomingRemindersWidgetState extends State<UpcomingRemindersWidget> {
  List<Reminder> _upcoming = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcoming();
  }

  Future<void> _loadUpcoming() async {
    final all = await LocalReminderRepository().getReminders();
    final now = DateTime.now();
    final in24h = now.add(const Duration(days: 1));
    final upcoming = all
        .where(
          (r) =>
              r.scheduledDate.isAfter(now) && r.scheduledDate.isBefore(in24h),
        )
        .toList();
    setState(() {
      _upcoming = upcoming;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_upcoming.isEmpty) return const SizedBox();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.yellow[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Reminders',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._upcoming.map(
              (r) => ListTile(
                title: Text(r.title),
                subtitle: Text(r.subtitle),
                trailing: Text(
                  '${r.scheduledDate.hour.toString().padLeft(2, '0')}:${r.scheduledDate.minute.toString().padLeft(2, '0')}',
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
