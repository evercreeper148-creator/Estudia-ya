import 'dart:convert';

enum Priority { alta, media, baja }

class Task {
  final String id;
  String title;
  String materia;
  DateTime? date;
  Priority priority;
  bool done;
  DateTime created;

  Task({
    required this.id,
    required this.title,
    this.materia = '',
    this.date,
    this.priority = Priority.media,
    this.done = false,
    DateTime? created,
  }) : created = created ?? DateTime.now();

  int? get daysLeft {
    if (date == null) return null;
    final today = DateTime.now();
    final d = DateTime(date!.year, date!.month, date!.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.difference(t).inDays;
  }

  bool get isUrgent => !done && daysLeft != null && daysLeft! <= 2;

  Map<String, dynamic> toMap() => {
        'id': id, 'title': title, 'materia': materia,
        'date': date?.toIso8601String(),
        'priority': priority.name, 'done': done,
        'created': created.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'], title: m['title'], materia: m['materia'] ?? '',
        date: m['date'] != null ? DateTime.parse(m['date']) : null,
        priority: Priority.values.firstWhere((p) => p.name == m['priority'], orElse: () => Priority.media),
        done: m['done'] ?? false,
        created: m['created'] != null ? DateTime.parse(m['created']) : DateTime.now(),
      );

  String toJson() => jsonEncode(toMap());
  factory Task.fromJson(String s) => Task.fromMap(jsonDecode(s));
}
