import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'task.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    const channel = AndroidNotificationChannel(
      'estudia_ya_channel', 'EstudiaYa Recordatorios',
      description: 'Recordatorios de tareas próximas a vencer',
      importance: Importance.high,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static Future<void> scheduleForTask(Task task) async {
    if (task.done || task.date == null) return;
    final base = DateTime(task.date!.year, task.date!.month, task.date!.day, 8, 0);
    final reminders = [
      (base.subtract(const Duration(days: 2)), 'en 2 días'),
      (base.subtract(const Duration(days: 1)), 'mañana'),
      (base, '¡hoy!'),
    ];
    for (final r in reminders) {
      if (r.$1.isAfter(DateTime.now())) {
        final id = (task.id + r.$2).hashCode.abs() % 100000;
        await _plugin.zonedSchedule(
          id,
          '📚 Tarea vence ${r.$2}',
          '${task.title}${task.materia.isNotEmpty ? ' · ${task.materia}' : ''}',
          tz.TZDateTime.from(r.$1, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'estudia_ya_channel', 'EstudiaYa Recordatorios',
              importance: Importance.high, priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> cancelForTask(String taskId) async {
    for (final label in ['en 2 días', 'mañana', '¡hoy!']) {
      await _plugin.cancel((taskId + label).hashCode.abs() % 100000);
    }
  }

  static Future<void> rescheduleAll(List<Task> tasks) async {
    await _plugin.cancelAll();
    for (final t in tasks) await scheduleForTask(t);
  }
}
