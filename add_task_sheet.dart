import 'package:flutter/material.dart';
import 'main.dart';
import 'task.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});
  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _ctrl = TextEditingController();
  String _materia = '';
  DateTime? _date;
  Priority _priority = Priority.media;
  bool _error = false;

  static const _materias = ['','Matemáticas','Historia','Biología','Literatura','Física','Química','Inglés','Geografía','Arte','Educación Física'];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) { setState(() => _error = true); return; }
    Navigator.pop(context, Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _ctrl.text.trim(), materia: _materia, date: _date, priority: _priority,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: kBorder), left: BorderSide(color: kBorder), right: BorderSide(color: kBorder)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 36),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(margin: const EdgeInsets.only(top: 12, bottom: 20), width: 40, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)))),
        const Text('Nueva tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
        const SizedBox(height: 20),
        _lbl('Tarea'), const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          onChanged: (_) => setState(() => _error = false),
          style: const TextStyle(color: kText, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Ej: Estudiar capítulo 3...', hintStyle: const TextStyle(color: kTextMuted), counterText: '',
            filled: true, fillColor: kBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _error ? kRed : kBorder, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _error ? kRed : kBorder, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kAccent, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        _lbl('Materia'), const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _materia,
          items: _materias.map((m) => DropdownMenuItem(value: m, child: Text(m.isEmpty ? 'Seleccionar...' : m, style: TextStyle(color: m.isEmpty ? kTextMuted : kText, fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _materia = v ?? ''),
          dropdownColor: kSurface2,
          decoration: InputDecoration(filled: true, fillColor: kBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kAccent, width: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        _lbl('Fecha límite'), const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final p = await showDatePicker(
              context: context, initialDate: DateTime.now(),
              firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: kAccent, surface: kSurface2, onSurface: kText)), child: child!),
            );
            if (p != null) setState(() => _date = p);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(color: kBg, border: Border.all(color: kBorder, width: 1.5), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: kTextMuted), const SizedBox(width: 8),
              Text(
                _date == null ? 'Seleccionar fecha...' : '${_date!.day} ${months[_date!.month-1]} ${_date!.year}',
                style: TextStyle(color: _date == null ? kTextMuted : kText, fontSize: 14),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        _lbl('Prioridad'), const SizedBox(height: 8),
        Row(children: Priority.values.map((p) {
          final label = p == Priority.alta ? '🔴 Alta' : p == Priority.media ? '🟡 Media' : '🟢 Baja';
          final color = p == Priority.alta ? kRed : p == Priority.media ? kYellow : kGreen;
          final sel = _priority == p;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? color.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: sel ? color : kBorder, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? color : kTextMuted)),
            ),
          ));
        }).toList()),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Agregar tarea', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ])),
    );
  }

  Widget _lbl(String t) => Text(t.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted, letterSpacing: 0.7));
}
