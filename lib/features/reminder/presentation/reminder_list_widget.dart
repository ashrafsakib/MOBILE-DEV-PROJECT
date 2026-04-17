import 'package:flutter/material.dart';

import '../../reminder/domain/reminder.dart';

class ReminderListWidget extends StatelessWidget {
  final List<Reminder> reminders;
  final void Function(Reminder)? onDelete;

  const ReminderListWidget({super.key, required this.reminders, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const Center(child: Text('No reminders.'));
    }
    return ListView.separated(
      itemCount: reminders.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ListTile(
          title: Text(reminder.title),
          subtitle: Text(reminder.subtitle),
          trailing: onDelete != null
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete!(reminder),
                )
              : null,
          leading: const Icon(Icons.notifications_active),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        );
      },
    );
  }
}
