import 'package:flutter/material.dart';
import 'main.dart';
import 'task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const TaskCard({super.key, required this.task, required this.onToggle, required this.onDelete});

  static const _colors = {
    'Matemáticas': Color(0xFF7C5CFC), 'Historia': Color(0xFFF87171),
    'Biología': Color(0xFF4ADE80),    'Literatura': Color(0xFFFBBF24),
    'Física': Color(0xFF38BDF8),      'Química': Color(0xFFFB923C),
    'Inglés': Color(0xFFA78BFA),      'Geografía': Color(0xFF34D399),
    'Arte': Color(0xFFF472B6),        'Educación Física': Color(0xFF60A5FA),
  };

  String get _dateLabel {
    final d = task.daysLeft;
    if (d == null) return '';
    if (d == 0) return '⚡ Hoy';
    if (d == 1) return '⚡ Mañana';
    if (d < 0) return 'Vencida';
    final m = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return '📅 ${task.date!.day} ${m[task.date!.month-1]}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[task.materia] ?? kAccent;
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: kRed.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline, color: kRed),
      ),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedOpacity(
          opacity: task.done ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kSurface, border: Border.all(color: kBorder, width: 1.5), borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.done ? kGreen : Colors.transparent,
                    border: Border.all(color: task.done ? kGreen : kBorder, width: 2),
                  ),
                  child: task.done ? const Icon(Icons.check, size: 14, color: kBg) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(task.title, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: task.done ? kTextMuted : kText,
                  decoration: task.done ? TextDecoration.lineThrough : null,
                )),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (task.materia.isNotEmpty)
                    _Badge(label: task.materia, textColor: color, bgColor: color.withOpacity(0.13)),
                  _PriorityBadge(priority: task.priority),
                  if (_dateLabel.isNotEmpty)
                    Text(_dateLabel, style: TextStyle(
                      fontSize: 11,
                      color: task.isUrgent ? kRed : kTextMuted,
                      fontWeight: task.isUrgent ? FontWeight.w600 : FontWeight.normal,
                    )),
                ]),
              ])),
              GestureDetector(
                onTap: onDelete,
                child: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.close, size: 18, color: kTextMuted)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color textColor, bgColor;
  const _Badge({required this.label, required this.textColor, required this.bgColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
  );
}

class _PriorityBadge extends StatelessWidget {
  final Priority priority;
  const _PriorityBadge({required this.priority});
  @override
  Widget build(BuildContext context) {
    final label = priority == Priority.alta ? '🔴 Alta' : priority == Priority.media ? '🟡 Media' : '🟢 Baja';
    final color = priority == Priority.alta ? kRed : priority == Priority.media ? kYellow : kGreen;
    return _Badge(label: label, textColor: color, bgColor: color.withOpacity(0.15));
  }
}

class MateriasRow extends StatelessWidget {
  final List<Task> tasks;
  const MateriasRow({super.key, required this.tasks});
  static const _colors = {
    'Matemáticas': Color(0xFF7C5CFC), 'Historia': Color(0xFFF87171),
    'Biología': Color(0xFF4ADE80),    'Literatura': Color(0xFFFBBF24),
    'Física': Color(0xFF38BDF8),      'Química': Color(0xFFFB923C),
    'Inglés': Color(0xFFA78BFA),      'Geografía': Color(0xFF34D399),
    'Arte': Color(0xFFF472B6),        'Educación Física': Color(0xFF60A5FA),
  };
  @override
  Widget build(BuildContext context) {
    final map = <String, (int, int)>{};
    for (final t in tasks) {
      if (t.materia.isEmpty) continue;
      final p = map[t.materia] ?? (0, 0);
      map[t.materia] = (p.$1 + 1, p.$2 + (t.done ? 1 : 0));
    }
    if (map.isEmpty) return const Padding(
      padding: EdgeInsets.fromLTRB(20,0,20,0),
      child: Text('Agrega tareas para ver tu progreso', style: TextStyle(color: kTextMuted, fontSize: 13)),
    );
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: map.entries.map((e) {
          final color = _colors[e.key] ?? kAccent;
          final pct = e.value.$1 == 0 ? 0.0 : e.value.$2 / e.value.$1;
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.fromLTRB(14,10,14,10),
            width: 120,
            decoration: BoxDecoration(color: kSurface, border: Border.all(color: kBorder, width: 1.5), borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: pct, backgroundColor: kBorder, valueColor: AlwaysStoppedAnimation(color), minHeight: 4),
              ),
              const SizedBox(height: 4),
              Text('${e.value.$2}/${e.value.$1} · ${(pct*100).round()}%', style: const TextStyle(fontSize: 10, color: kTextMuted)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class FilterRow extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const FilterRow({super.key, required this.current, required this.onChanged});
  static const filters = [('todas','Todas'),('pendientes','Pendientes'),('alta','🔴 Alta'),('media','🟡 Media'),('baja','🟢 Baja'),('done','✓ Hechas')];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: filters.map((f) {
        final active = f.$1 == current;
        return GestureDetector(
          onTap: () => onChanged(f.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: active ? kAccent : Colors.transparent,
              border: Border.all(color: active ? kAccent : kBorder, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(f.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : kTextMuted)),
          ),
        );
      }).toList(),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('📚', style: TextStyle(fontSize: 48)),
      SizedBox(height: 12),
      Text('Sin tareas aquí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
      SizedBox(height: 6),
      Text('Toca + para agregar una nueva tarea', style: TextStyle(fontSize: 13, color: kTextMuted)),
    ]),
  );
}
