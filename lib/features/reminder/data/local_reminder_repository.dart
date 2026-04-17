import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/reminder.dart';
import 'reminder_repository.dart';

class LocalReminderRepository implements ReminderRepository {
  static const _remindersKey = 'reminders';

  @override
  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey) ?? [];
    return remindersJson.map((e) => Reminder.fromMap(jsonDecode(e))).toList();
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList(_remindersKey) ?? [];
    reminders.add(jsonEncode(reminder.toMap()));
    await prefs.setStringList(_remindersKey, reminders);
  }

  @override
  Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList(_remindersKey) ?? [];
    reminders.removeWhere((e) => Reminder.fromMap(jsonDecode(e)).id == id);
    await prefs.setStringList(_remindersKey, reminders);
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = prefs.getStringList(_remindersKey) ?? [];
    final idx = reminders.indexWhere(
      (e) => Reminder.fromMap(jsonDecode(e)).id == reminder.id,
    );
    if (idx != -1) {
      reminders[idx] = jsonEncode(reminder.toMap());
      await prefs.setStringList(_remindersKey, reminders);
    }
  }
}
