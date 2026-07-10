import 'package:flutter/material.dart';
import 'main.dart';
import 'task.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import 'add_task_sheet.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  String filter = 'todas';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    NotificationService.requestPermission();
  }

  Future<void> _load() async {
    final loaded = await StorageService.loadTasks();
    if (loaded.isEmpty) {
      final t = DateTime.now();
      loaded.addAll([
        Task(id: '1', title: 'Resolver ejercicios págs. 45-50', materia: 'Matemáticas', date: t.add(const Duration(days: 1)), priority: Priority.alta),
        Task(id: '2', title: 'Leer capítulo 4 sobre la Revolución Francesa', materia: 'Historia', date: t.add(const Duration(days: 7)), priority: Priority.media),
        Task(id: '3', title: 'Informe sobre la célula eucariota', materia: 'Biología', date: t.add(const Duration(days: 1)), priority: Priority.alta),
        Task(id: '4', title: 'Vocabulario unidad 6', materia: 'Inglés', date: t.add(const Duration(days: 7)), priority: Priority.baja, done: true),
      ]);
      await StorageService.saveTasks(loaded);
    }
    setState(() { tasks = loaded; loading = false; });
    await NotificationService.rescheduleAll(tasks);
  }

  Future<void> _save() async {
    await StorageService.saveTasks(tasks);
    await NotificationService.rescheduleAll(tasks);
  }

  List<Task> get filtered {
    List<Task> list;
    switch (filter) {
      case 'pendientes': list = tasks.where((t) => !t.done).toList(); break;
      case 'done':       list = tasks.where((t) => t.done).toList(); break;
      case 'alta':       list = tasks.where((t) => t.priority == Priority.alta && !t.done).toList(); break;
      case 'media':      list = tasks.where((t) => t.priority == Priority.media && !t.done).toList(); break;
      case 'baja':       list = tasks.where((t) => t.priority == Priority.baja && !t.done).toList(); break;
      default:           list = List.from(tasks);
    }
    list.sort((a, b) {
      if (a.done != b.done) return a.done ? 1 : -1;
      if (a.date != null && b.date != null) return a.date!.compareTo(b.date!);
      if (a.date != null) return -1;
      if (b.date != null) return 1;
      return 0;
    });
    return list;
  }

  int get pending => tasks.where((t) => !t.done).length;
  int get done    => tasks.where((t) => t.done).length;
  int get urgent  => tasks.where((t) => t.isUrgent).length;

  void _toggleTask(Task t) { setState(() => t.done = !t.done); _save(); }
  void _deleteTask(Task t) {
    setState(() => tasks.removeWhere((x) => x.id == t.id));
    NotificationService.cancelForTask(t.id);
    _save();
  }

  void _openAddSheet() async {
    final newTask = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
    if (newTask != null) { setState(() => tasks.insert(0, newTask)); _save(); }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
    final months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month-1]}';

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: loading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20,20,20,0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  RichText(text: const TextSpan(
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText),
                    children: [TextSpan(text: 'Estudia'), TextSpan(text: 'Ya', style: TextStyle(color: kAccent))],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: kSurface, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(20)),
                    child: Text(dateStr, style: const TextStyle(color: kTextMuted, fontSize: 12)),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20,16,20,0),
                child: Row(children: [
                  _StatCard(num: pending.toString(), label: 'Pendientes', color: kAccent),
                  const SizedBox(width: 12),
                  _StatCard(num: urgent.toString(), label: 'Urgentes', color: kYellow),
                  const SizedBox(width: 12),
                  _StatCard(num: done.toString(), label: 'Completadas', color: kGreen),
                ]),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.fromLTRB(20,0,20,10),
                child: Text('PROGRESO POR MATERIA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted, letterSpacing: 1)),
              ),
              MateriasRow(tasks: tasks),
              const SizedBox(height: 12),
              FilterRow(current: filter, onChanged: (f) => setState(() => filter = f)),
              Expanded(
                child: filtered.isEmpty
                  ? const EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20,0,20,100),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => TaskCard(
                        task: filtered[i],
                        onToggle: () => _toggleTask(filtered[i]),
                        onDelete: () => _deleteTask(filtered[i]),
                      ),
                    ),
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: kAccent,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num, label;
  final Color color;
  const _StatCard({required this.num, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: kSurface, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(num, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}
