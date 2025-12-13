import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/entry.dart';

enum _Field { sys, dia, pulse, note }

class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({Key? key, this.initialEntry}) : super(key: key);

  final Entry? initialEntry; // <-- новый параметр
  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _sys = StringBuffer();
  final _dia = StringBuffer();
  final _pulse = StringBuffer();
  final _noteCtrl = TextEditingController();

  final _sysNode = FocusNode();
  final _diaNode = FocusNode();
  final _pulseNode = FocusNode();
  final _noteNode = FocusNode();

  _Field _active = _Field.sys;
  DateTime _when = DateTime.now();

  // Пороговые значения — подправь при желании
  static const _minSys = 70, _maxSys = 250;
  static const _minDia = 40, _maxDia = 160;
  static const _minPulse = 30, _maxPulse = 220;

  @override
  void initState() {
    super.initState();
    // Сразу ставим курсор в САД
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sysNode.requestFocus();
      setState(() => _active = _Field.sys);
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _sysNode.dispose();
    _diaNode.dispose();
    _pulseNode.dispose();
    _noteNode.dispose();
    super.dispose();
  }

  // ------- helpers -------

  String get _sysText => _sys.toString();
  String get _diaText => _dia.toString();
  String get _pulseText => _pulse.toString();

  void _switchTo(_Field f) {
    setState(() => _active = f);
    switch (f) {
      case _Field.sys: _sysNode.requestFocus(); break;
      case _Field.dia: _diaNode.requestFocus(); break;
      case _Field.pulse: _pulseNode.requestFocus(); break;
      case _Field.note: _noteNode.requestFocus(); break;
    }
  }

  void _onKeyTap(String d) {
    StringBuffer buf;
    int maxLen = 3;

    switch (_active) {
      case _Field.sys:   buf = _sys;   break;
      case _Field.dia:   buf = _dia;   break;
      case _Field.pulse: buf = _pulse; break;
      case _Field.note:
      // Для заметки включаем системную клавиатуру и не трогаем нашу
        return;
    }
    if (buf.length >= maxLen) return;
    buf.write(d);
    setState(() {});
  }

  void _onBackspace() {
    StringBuffer buf;
    switch (_active) {
      case _Field.sys:   buf = _sys;   break;
      case _Field.dia:   buf = _dia;   break;
      case _Field.pulse: buf = _pulse; break;
      case _Field.note:  return;
    }
    if (buf.isNotEmpty) {
      buf.clear();
      // Оставляем все кроме последнего символа
      // (clear + add заново быстрее, чем удаление из StringBuffer)
      // но чтобы просто удалить 1 символ:
      // к сожалению StringBuffer не умеет removeLast, поэтому делаем так:
    }
  }

  // remove last char helper
  void _onBackspaceOne() {
    StringBuffer buf;
    switch (_active) {
      case _Field.sys:   buf = _sys;   break;
      case _Field.dia:   buf = _dia;   break;
      case _Field.pulse: buf = _pulse; break;
      case _Field.note:  return;
    }
    final s = buf.toString();
    if (s.isEmpty) return;
    buf.clear();
    buf.write(s.substring(0, s.length - 1));
    setState(() {});
  }

  bool get _validSys {
    if (_sys.isEmpty) return false;
    final v = int.parse(_sys.toString());
    return v >= _minSys && v <= _maxSys;
  }

  bool get _validDia {
    if (_dia.isEmpty) return false;
    final v = int.parse(_dia.toString());
    return v >= _minDia && v <= _maxDia;
  }

  bool get _validPulse {
    if (_pulse.isEmpty) return true; // необязательно
    final v = int.parse(_pulse.toString());
    return v >= _minPulse && v <= _maxPulse;
  }

  bool get _canSave => _validSys && _validDia && _validPulse;

  void _save() {
    if (!_canSave) return;

    final entry = Entry(
      systolic: int.parse(_sys.toString()),
      diastolic: int.parse(_dia.toString()),
      pulse: _pulse.isEmpty ? null : int.parse(_pulse.toString()),
      timestamp: _when,
      comment: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      // если у тебя есть поле mood/emoji — тут же можно добавить
    );

    Navigator.of(context).pop(entry);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _when,
    );
    if (d == null) return;
    setState(() => _when = DateTime(d.year, d.month, d.day, _when.hour, _when.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (t == null) return;
    setState(() => _when = DateTime(_when.year, _when.month, _when.day, t.hour, t.minute));
  }

  // ------- UI -------

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  TextStyle get _mono =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMEd();
    final tf = DateFormat.Hm();

    final saveEnabled = _canSave;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая запись'),
        actions: [
          TextButton(
            onPressed: saveEnabled ? _save : null,
            child: const Text('Сохранить'),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // форма прокручиваемая
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _sysNode,
                            readOnly: true, // наша клавиатура
                            onTap: () => _switchTo(_Field.sys),
                            controller: TextEditingController(text: _sys.toString()),
                            decoration: _dec('САД', hint: '$_minSys–$_maxSys'),
                            style: _mono,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            focusNode: _diaNode,
                            readOnly: true,
                            onTap: () => _switchTo(_Field.dia),
                            controller: TextEditingController(text: _dia.toString()),
                            decoration: _dec('ДАД', hint: '$_minDia–$_maxDia'),
                            style: _mono,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            focusNode: _pulseNode,
                            readOnly: true,
                            onTap: () => _switchTo(_Field.pulse),
                            controller: TextEditingController(text: _pulse.toString()),
                            decoration: _dec('Пульс', hint: '$_minPulse–$_maxPulse'),
                            style: _mono,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: InputDecorator(
                              decoration: _dec('Дата'),
                              child: Text(df.format(_when)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(10),
                            child: InputDecorator(
                              decoration: _dec('Время'),
                              child: Text(tf.format(_when)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteCtrl,
                      focusNode: _noteNode,
                      onTap: () => _switchTo(_Field.note),
                      decoration: _dec('Комментарий'),
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    // смайлики — оставляю как заглушку
                    Row(
                      children: [
                        for (final e in ['🙂','😐','😕','😟','🤒'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(label: Text(e)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // нижняя панель управления + цифровая клавиатура
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -2))],
              ),
              child: Column(
                children: [
                  // строка с кнопками
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _onBackspaceOne,
                            icon: const Icon(Icons.backspace),
                            label: const Text('Стереть'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: saveEnabled ? _save : null,
                            child: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // keypad
                  _NumberPad(
                    onTap: _onKeyTap,
                    onBackspace: _onBackspaceOne,
                    enabled: _active != _Field.note, // для заметки клавиатура не нужна
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onTap,
    required this.onBackspace,
    required this.enabled,
  });

  final void Function(String) onTap;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final keys = ['1','2','3','4','5','6','7','8','9','0'];
    Widget _key(String t) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: FilledButton.tonal(
          onPressed: enabled ? () => onTap(t) : null,
          child: Text(t, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );

    return AbsorbPointer(
      absorbing: !enabled,
      child: Column(
        children: [
          Row(children: [_key('1'), _key('2'), _key('3')]),
          Row(children: [_key('4'), _key('5'), _key('6')]),
          Row(children: [_key('7'), _key('8'), _key('9')]),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _key('0'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: FilledButton.tonalIcon(
                    onPressed: onBackspace,
                    icon: const Icon(Icons.backspace),
                    label: const Text(''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
