import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // не используется

import '../widgets/svg_icon.dart';
import '../models/entry.dart';
import '../services/storage_service.dart';
import '../theme/scale.dart';
import '../widgets/entry_keypad.dart';

class EntryScreen extends StatefulWidget {
  final Entry? initialEntry;
  const EntryScreen({super.key, this.initialEntry});
  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _sys = TextEditingController();
  final _dia = TextEditingController();
  final _pul = TextEditingController();
  final _comment = TextEditingController();

  final _sysNode = FocusNode();
  final _diaNode = FocusNode();
  final _pulNode = FocusNode();
  final _commentNode = FocusNode();

  DateTime _dt = DateTime.now();

  bool get _isEdit => widget.initialEntry != null;
  bool get _numericFocused => _sysNode.hasFocus || _diaNode.hasFocus || _pulNode.hasFocus;

  // --- РЕАЛИСТИЧНЫЕ ФИЗИЧЕСКИЕ ГРАНИЦЫ (НЕ «НОРМЫ») ---
  static const int kSysAbsMin = 50;   // систолическое
  static const int kSysAbsMax = 240;
  static const int kDiaAbsMin = 30;   // диастолическое
  static const int kDiaAbsMax = 180;
  // Реалистичный коридор пульсового давления: PP = Sys - Dia
  static const int kMinPP = 10;
  static const int kMaxPP = 80;

  // токены
  static const _blueHeader  = Color(0xFF4E7BA1);
  static const _blueButton  = Color(0xFF204D6F);
  static const _pageBg      = Color(0xFFEFF4F8);

  double get _hPad => dp(context, 20);
  double get _gap  => dp(context, 20);
  double get _r    => dp(context, 10);

  double get _capsuleH => dp(context, 48);
  double get _timeH    => dp(context, 48);
  double get _commentH => dp(context, 72);

  List<BoxShadow> get _shadow => [
    BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 16, offset: const Offset(0, 3)),
  ];

  // снап к DPR — убирает переполнение на 1–3px
  double _pxSnap(BuildContext c, double v) {
    final dpr = MediaQuery.of(c).devicePixelRatio;
    return (v * dpr).floorToDouble() / dpr;
  }

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.initialEntry!;
      _sys.text = e.systolic.toString();
      _dia.text = e.diastolic.toString();
      if (e.pulse != null) _pul.text = e.pulse.toString();
      _comment.text = e.comment ?? '';
      _dt = e.timestamp;
    }
    _focusNext(_sysNode);

    for (final n in [_sysNode, _diaNode, _pulNode, _commentNode]) {
      n.addListener(() => setState(() {}));
    }

    _sys.addListener(() {
      if (_sysNode.hasFocus && _sysOk) _focusNext(_diaNode);
      setState(() {});
    });
    _dia.addListener(() {
      if (_diaNode.hasFocus && _diaOk) _focusNext(_pulNode);
      setState(() {});
    });
    _pul.addListener(() {
      if (_pulNode.hasFocus && _pul.text.isNotEmpty && _pulOk) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          FocusScope.of(context).requestFocus(_commentNode);
          setState(() {});
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sys.dispose(); _dia.dispose(); _pul.dispose(); _comment.dispose();
    _sysNode.dispose(); _diaNode.dispose(); _pulNode.dispose(); _commentNode.dispose();
    super.dispose();
  }

  void _focusNext(FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(node);
      setState(() {});
    });
  }

  // --- ВАЛИДАЦИЯ ПОЛЕЙ ДЛЯ «СОХРАНИТЬ» ---
  bool get _sysOk => _inRange(_sys.text, kSysAbsMin, kSysAbsMax);

  bool get _diaOk {
    final d = int.tryParse(_dia.text);
    final s = int.tryParse(_sys.text);
    if (d == null || s == null) return false;
    if (d < kDiaAbsMin || d > kDiaAbsMax) return false;
    final pp = s - d;
    return pp >= kMinPP && pp <= kMaxPP;
  }

  bool get _pulOk => _pul.text.isEmpty ? true : _inRange(_pul.text, 30, 220);

  bool _inRange(String s, int min, int max) {
    final v = int.tryParse(s);
    return v != null && v >= min && v <= max;
  }

  bool get _canSave => _sysOk && _diaOk && _pulOk;

  // --- ХЕЛПЕРЫ ДЛЯ «УМНОЙ КЛАВИАТУРЫ» (префиксная достижимость) ---
  bool _isPrefixFeasible({
    required String prefix,
    required int absMin,
    required int absMax,
  }) {
    if (prefix.isEmpty) return true;
    if (prefix.length > 3) return false;
    if (prefix[0] == '0') return false;

    final int v = int.tryParse(prefix) ?? 0;

    // Собираем ВСЕ достижимые интервалы для этого префикса:
    // len=1 → можно закончить на 2-х цифрах [v*10..v*10+9] ИЛИ на 3-х [v*100..v*100+99]
    // len=2 → можно закончить на 2-х точно [v..v] ИЛИ на 3-х [v*10..v*10+9]
    // len=3 → это уже финальное число [v..v]
    List<List<int>> intervals;
    if (prefix.length == 1) {
      intervals = [
        [v * 10,     v * 10 + 9],     // двухзначное завершение
        [v * 100,    v * 100 + 99],   // трехзначное завершение
      ];
    } else if (prefix.length == 2) {
      intervals = [
        [v,          v],              // остаёмся двухзначным
        [v * 10,     v * 10 + 9],     // трёхзначное завершение
      ];
    } else { // prefix.length == 3
      intervals = [
        [v,          v],              // уже финал
      ];
    }

    // Проверяем: есть ли ХОТЯ БЫ ОДНО пересечение с [absMin..absMax]
    for (final iv in intervals) {
      final lo = iv[0];
      final hi = iv[1];
      final interLo = lo < absMin ? absMin : lo;
      final interHi = hi > absMax ? absMax : hi;
      if (interLo <= interHi) return true;
    }
    return false;
  }


  // если строка уже полноценное число и попадает в границы — вернуть int, иначе null
  int? _tryParseFinal(String txt, {required int absMin, required int absMax}) {
    if (txt.isEmpty) return null;
    final v = int.tryParse(txt);
    if (v == null) return null;
    if (v < absMin || v > absMax) return null;
    return v;
  }

  // Систола: только абсолютные физические границы (50..240)
  bool _sysPrefixOk(String sysPrefix) {
    return _isPrefixFeasible(prefix: sysPrefix, absMin: kSysAbsMin, absMax: kSysAbsMax);
  }

  bool _overlap(int a1, int a2, int b1, int b2) {
    final lo = a1 > b1 ? a1 : b1;
    final hi = a2 < b2 ? a2 : b2;
    return lo <= hi;
  }

  bool _diaFirstDigitAllowed({required int d, required int sys}) {
    // Диапазон диастолы, допускаемый по пульсовому давлению:
    final int ppLo = (sys - kMaxPP).clamp(kDiaAbsMin, kDiaAbsMax); // нижняя граница Dia
    final int ppHi = (sys - kMinPP).clamp(kDiaAbsMin, kDiaAbsMax); // верхняя граница Dia
    if (ppLo > ppHi) return false;

    if (d == 1) {
      // d=1 даёт два «коридора»: 10–19 и 100–180 (с учётом абсолютного макс. 180)
      final ok2 = _overlap(10, 19, ppLo, ppHi);
      final ok3 = _overlap(100, 180, ppLo, ppHi);
      return ok2 || ok3;
    }

    // d=2..9 → только двухзначные (20–29, 30–39, ..., 90–99), но с учётом абсолютов 30–180
    final lo = (d * 10) < kDiaAbsMin ? kDiaAbsMin : d * 10;
    final hi = (d * 10 + 9) > kDiaAbsMax ? kDiaAbsMax : (d * 10 + 9);
    if (lo > hi) return false;

    return _overlap(lo, hi, ppLo, ppHi);
  }


  // Диастола: абсолютные границы + зависимость от уже введённой систолы через PP
  bool _diaPrefixOk({
    required String diaPrefix,
    required int? sysFinal,   // если систола уже добита — включаем строгую проверку PP
  }) {
    // База: абсолютные границы диастолы
    if (!_isPrefixFeasible(prefix: diaPrefix, absMin: kDiaAbsMin, absMax: kDiaAbsMax)) return false;

    // Если систола финальная — проверяем коридор PP на достижимость
    if (sysFinal != null) {
      final int diaMinByPP = (sysFinal - kMaxPP).clamp(kDiaAbsMin, kDiaAbsMax);
      final int diaMaxByPP = (sysFinal - kMinPP).clamp(kDiaAbsMin, kDiaAbsMax);
      if (diaMinByPP > diaMaxByPP) return false;

      final int minPossible = int.parse(diaPrefix.padRight(3, '0'));
      final int maxPossible = int.parse(diaPrefix.padRight(3, '9'));
      final int lo = (minPossible < diaMinByPP) ? diaMinByPP : minPossible;
      final int hi = (maxPossible > diaMaxByPP) ? diaMaxByPP : maxPossible;
      return lo <= hi;
    }

    // Если систола ещё не добита — допускаем префикс по абсолютам
    return true;
  }

  // --- ВКЛЮЧЁННЫЕ ЦИФРЫ ДЛЯ КЛАВИАТУРЫ ---
  Set<String> _enabledDigits() {
    final bool sysF = _sysNode.hasFocus;
    final bool diaF = _diaNode.hasFocus;
    final bool pulF = _pulNode.hasFocus;

    String cur = '';
    if (sysF) cur = _sys.text;
    if (diaF) cur = _dia.text;
    if (pulF) cur = _pul.text;

    // Систола уже финальная?
    final int? sysFinal = _tryParseFinal(_sys.text, absMin: kSysAbsMin, absMax: kSysAbsMax);

    final out = <String>{};
    for (int d = 0; d <= 9; d++) {
      if (cur.isEmpty && d == 0) continue; // не начинаем с нуля
      final next = '$cur$d';
      if (next.length > 3) continue;

      bool ok;
      if (sysF) {
        ok = _sysPrefixOk(next); // 50..240
      } else if (diaF) {
        // если систола уже валидна и диастола ещё пустая —
        // правильно подсветим ПЕРВУЮ цифру по диапазону PP (и абсолютам)
        if (cur.isEmpty && sysFinal != null) {
          for (int d = 1; d <= 9; d++) {
            if (_diaFirstDigitAllowed(d: d, sys: sysFinal)) out.add(d.toString());
          }
          // 0 как первая цифра для диастолы не разрешается
          return out;
        }

        // иначе — обычная префиксная проверка (абсолюты + достижимость по PP)
        ok = _diaPrefixOk(diaPrefix: next, sysFinal: sysFinal);

      } else if (pulF) {
        ok = _isPrefixFeasible(prefix: next, absMin: 30, absMax: 220);
      } else {
        ok = false;
      }

      if (ok) out.add(d.toString());
    }
    return out;
  }

  // эмодзи всегда вставляются; фокус переносим только если можно
  void _insertEmoji(String emoji) {
    final text = _comment.text;
    final sel = _comment.selection;
    int start = sel.isValid ? sel.start : text.length;
    int end   = sel.isValid ? sel.end   : text.length;
    start = start.clamp(0, text.length);
    end   = end.clamp(0, text.length);

    final before = text.substring(0, start);
    final after  = text.substring(end);
    final needsSpaceBefore = before.isNotEmpty && !before.endsWith(' ');
    final insert = (needsSpaceBefore ? ' ' : '') + emoji + ' ';

    _comment.value = TextEditingValue(
      text: before + insert + after,
      selection: TextSelection.collapsed(offset: (before + insert).length),
    );

    if (_sysOk && _diaOk && _pulOk) {
      FocusScope.of(context).requestFocus(_commentNode);
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final newEntry = Entry(
      timestamp: _dt,
      systolic: int.parse(_sys.text),
      diastolic: int.parse(_dia.text),
      pulse: _pul.text.isEmpty ? null : int.parse(_pul.text),
      comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
      mood: null,
    );
    final box = StorageService.entriesBox;
    if (_isEdit) {
      await box.put(widget.initialEntry!.key, newEntry);
    } else {
      await box.add(newEntry);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteOrClear() async {
    if (_isEdit) {
      await StorageService.entriesBox.delete(widget.initialEntry!.key);
      if (mounted) Navigator.of(context).pop();
    } else {
      _sys.clear(); _dia.clear(); _pul.clear(); _comment.clear();
      setState(() { _dt = DateTime.now(); _focusNext(_sysNode); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    return GestureDetector(
      onTap: () => FocusScope.of(c).unfocus(),
      child: Scaffold(
        backgroundColor: _pageBg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(c),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: _gap),
                  child: Column(
                    children: [
                      _tripleRow(c),
                      _timeDateRow(c),
                      _commentBox(c),
                      _emojiRow(c),
                      _saveBtn(context),
                      SizedBox(height: _gap), // единственный 20dp
                      if (_numericFocused)
                        EntryKeypad(
                          onKey: _onKey,
                          enabledDigits: _enabledDigits(),
                          cellWidth: null,
                          cellHeight: _capsuleH,
                          gap: _gap,
                          hPad: _hPad,
                          borderRadius: _r,
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // шапка в две строки
  Widget _header(BuildContext c) {
    return Container(
      height: dp(c, 128),
      padding: EdgeInsets.symmetric(horizontal: _hPad),
      color: _blueHeader,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                splashRadius: dp(c, 24),
                icon: SvgIcon('x', size: dp(c, 22), color: Colors.white),
                onPressed: () => Navigator.of(c).pop(),
              ),
              const Spacer(),
              IconButton(
                splashRadius: dp(c, 24),
                icon: SvgIcon('trash-2', size: dp(c, 22), color: Colors.white),
                onPressed: _deleteOrClear,
              ),
            ],
          ),
          SizedBox(height: dp(c, 8)),
          Text(
            'Новая запись',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(c).textTheme.headlineSmall?.copyWith(
              fontSize: dp(c, 24),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _tsValue(BuildContext c) => Theme.of(c).textTheme.titleMedium?.copyWith(
    fontSize: dp(c, 18),
    fontWeight: FontWeight.w600,
    color: const Color(0xFF2E5D85),
  );

  // капсула-число
  Widget _capNum(
      BuildContext c,
      double width,
      String hint,
      TextEditingController ctl,
      FocusNode node,
      ) {
    final theme = Theme.of(c);

    final placeholder = theme.textTheme.labelLarge?.copyWith(
      fontSize: dp(c, 14),
      fontWeight: FontWeight.w700,
      color: const Color(0xFFA0AEC0),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(_r),
      onTap: () => node.requestFocus(),
      child: Container(
        width: width,
        height: _capsuleH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_r),
          boxShadow: _shadow,
        ),
        alignment: Alignment.center,
        child: SizedBox(
          height: _capsuleH,
          child: TextField(
            controller: ctl,
            focusNode: node,
            readOnly: true,                    // ← не всплывает системная клавиатура
            showCursor: true,                  // ← мигающий курсор
            enableInteractiveSelection: false,
            keyboardType: TextInputType.none,
            textAlign: TextAlign.center,
            style: _tsValue(c),                // ← 2E5D85, 18dp
            cursorColor: const Color(0xFF2E5D85),
            cursorWidth: dp(c, 2),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: placeholder,
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(horizontal: dp(c, 8), vertical: dp(c, 10)),
            ),
            onTap: () => node.requestFocus(),
          ),
        ),
      ),
    );
  }

  // ряд: Сист. [ / ] Диаст.   Пульс
  Widget _tripleRow(BuildContext c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_hPad, _gap, _hPad, _gap),
      child: LayoutBuilder(
        builder: (ctx, cons) {
          final maxW = cons.maxWidth;             // доступная ширина уже БЕЗ внешних паддингов
          final gap  = _pxSnap(ctx, _gap);
          final w    = _pxSnap(ctx, (maxW - 2 * gap) / 3); // 3 колонки и 2 промежутка

          Widget cap(String hint, TextEditingController ctl, FocusNode node) =>
              _capNum(ctx, w, hint, ctl, node);

          return Row(
            children: [
              cap('Сист.', _sys, _sysNode),
              SizedBox(width: gap),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  cap('Диаст.', _dia, _diaNode),
                  Positioned(
                    left: -dp(ctx, 14), top: dp(ctx, 16),
                    child: Text('/',
                      style: TextStyle(
                        color: const Color(0xFFA0AEC0),
                        fontSize: dp(ctx, 16),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: gap),
              cap('Пульс', _pul, _pulNode),
            ],
          );
        },
      ),
    );
  }

  // аккуратный контент таблетки + мягкая стрелка (16dp)
  Widget _pillContent(BuildContext c, String text) {
    final caret = Theme.of(c).colorScheme.onSurface.withValues(alpha: .45);
    final timeDateStyle = Theme.of(c).textTheme.titleMedium?.copyWith(
      fontSize: dp(c, 18),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2E5D85),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dp(c, 14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: timeDateStyle),
          SvgIcon('arrow_drop_down', size: dp(c, 16), color: caret),
        ],
      ),
    );
  }

  // helper: «пол» в лог. пикселях по текущему DPR (чтобы точно не вылезти за край)
  double _snapFloor(BuildContext c, double v) {
    final dpr = MediaQuery.of(c).devicePixelRatio;
    return (v * dpr).floorToDouble() / dpr;
  }

  // Время — Дата: ширина «Время» = ширине верхних капсул
  Widget _timeDateRow(BuildContext c) {
    String hhmm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    String dmy(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')} ${_ruMonth(d.month)} ${d.year}';

    return Padding(
      padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, _gap),
      child: LayoutBuilder(
        builder: (ctx, cons) {
          final maxW = cons.maxWidth;
          final gap  = _snapFloor(ctx, _gap);
          final w    = _snapFloor(ctx, (maxW - 2 * gap) / 3);
          final dateW = maxW - (gap + w);

          Widget pill(String text, double width, VoidCallback onTap) => InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_r),
            child: Container(
              width: width,
              height: _timeH,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_r),
                boxShadow: _shadow,
              ),
              child: _pillContent(ctx, text),
            ),
          );

          return Row(
            children: [
              pill(hhmm(_dt), w, () async {
                final t = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(_dt),
                  helpText: 'Время',
                );
                if (t != null) {
                  setState(() {
                    _dt = DateTime(_dt.year, _dt.month, _dt.day, t.hour, t.minute);
                  });
                }
              }),
              SizedBox(width: gap),
              pill(dmy(_dt), dateW, () async {
                final d = await showDatePicker(
                  context: ctx,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: _dt,
                  helpText: 'Дата',
                );
                if (d != null) {
                  setState(() {
                    _dt = DateTime(d.year, d.month, d.day, _dt.hour, _dt.minute);
                  });
                }
              }),
            ],
          );
        },
      ),
    );
  }

  // «Сохранить» — точь-в-точь ширина «Дата», выравнивание вправо
  Widget _saveBtn(BuildContext c) {
    final can = _canSave;
    final cs  = Theme.of(c).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 0),   // без нижнего отступа
      child: LayoutBuilder(
        builder: (ctx, cons) {
          final maxW = cons.maxWidth;
          final gap  = _snapFloor(ctx, _gap);
          final w    = _snapFloor(ctx, (maxW - 2 * gap) / 3);
          final saveW = maxW - (gap + w);

          return Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: saveW,
              height: _capsuleH,
              child: ElevatedButton(
                onPressed: can ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: can ? _blueButton : cs.surfaceContainerHighest,
                  foregroundColor: can ? Colors.white : cs.onSurface.withValues(alpha: .60),
                  elevation: can ? 2 : 0,
                  shadowColor: Colors.black.withValues(alpha: .12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_r)),
                  textStyle: TextStyle(fontSize: dp(ctx, 18), fontWeight: FontWeight.w700),
                ),
                child: const Text('Сохранить'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _commentBox(BuildContext c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_gap, 0, _gap, _gap),
      child: Container(
        height: _commentH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_r),
          boxShadow: _shadow,
        ),
        child: TextField(
          controller: _comment,
          focusNode: _commentNode,
          expands: true,
          minLines: null,
          maxLines: null,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: 'Комментарий',
            hintStyle: TextStyle(
              fontSize: dp(c, 14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFFA0AEC0),
            ),
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(horizontal: dp(c, 14), vertical: dp(c, 12)),
          ),
        ),
      ),
    );
  }

  // эмодзи — справа
  static const _emojiNames = [
    'heart','pill','grinning','slightly_smiling_face','unamused','face_with_head_bandage'
  ];
  static const _emojiChars = ['❤️','💊','😀','🙂','😒','🤕'];

  Widget _emojiRow(BuildContext c) {
    final item = dp(c, 32), step = dp(c, 16);
    return Padding(
      padding: EdgeInsets.fromLTRB(_gap, 0, _gap, _gap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(_emojiNames.length, (i) => Padding(
          padding: EdgeInsets.only(right: i == _emojiNames.length - 1 ? 0 : step),
          child: SizedBox(
            width: item, height: item,
            child: InkWell(
              borderRadius: BorderRadius.circular(item/2),
              onTap: () => _insertEmoji(_emojiChars[i]),
              child: Center(child: SvgIcon(_emojiNames[i], size: dp(c, 26))),
            ),
          ),
        )),
      ),
    );
  }

  void _onKey(String key) {
    final ctl = _focusedCtl;
    if (ctl == null) return;
    if (key == '⌫') {
      if (ctl.text.isNotEmpty) ctl.text = ctl.text.substring(0, ctl.text.length - 1);
      return;
    }
    if (ctl.text.length >= 3) return;
    ctl.text = (ctl.text + key).replaceAll(RegExp(r'^0+(?=\d)'), '');
  }

  TextEditingController? get _focusedCtl {
    if (_sysNode.hasFocus) return _sys;
    if (_diaNode.hasFocus) return _dia;
    if (_pulNode.hasFocus) return _pul;
    return null;
  }

  String _ruMonth(int m) => const [
    'января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'
  ][m - 1];
}
