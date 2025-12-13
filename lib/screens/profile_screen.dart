import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pressure_diary_fresh/theme/scale.dart'; // dp(context, ...)

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Контроллеры/фокусы
  final _name = TextEditingController();
  final _sys  = TextEditingController(text: '120');
  final _dia  = TextEditingController(text: '80');

  final _sysNode = FocusNode();
  final _diaNode = FocusNode();

  // --- Состояние
  int _sex = 0;                // 0 = Муж., 1 = Жен.
  DateTime? _birth;
  int _lastSys = 120;
  int _lastDia = 80;
  Timer? _debounce;
  bool _isLoggingIn = false;

  // --- Токены (цвета)
  static const _textValue = Color(0xFF2E5D85);
  static const _textHint  = Color(0xFFA0AEC0);
  static const _chipBg    = Color(0xFFF5F7FA);
  static const _cardBorder= Color(0xFFE3EBF3);
  static const _shadowCol = Color(0x1A000000);
  static const _innerFill = Color(0xFFF0F4F8);


  // --- Хелперы размеров
  double get _pad => dp(context, 20);
  double get _r   => dp(context, 10);
  double get _hInp=> dp(context, 46);
  double get _hBtn=> dp(context, 52);
  double get _accW   => dp(context, 320);
  double get _accH   => dp(context, 128);
  double get _innerW => dp(context, 296);
  double get _innerH => dp(context, 84);
  double get _btnW   => dp(context, 272);
  double get _btnH   => dp(context, 48);


  List<BoxShadow> get _shadow => const [
    BoxShadow(color: _shadowCol, blurRadius: 10, offset: Offset(0, 3)),
  ];

  @override
  void initState() {
    super.initState();
    _sysNode.addListener(() { if (!_sysNode.hasFocus) _enforceOrRevert(_sys, true); });
    _diaNode.addListener(() { if (!_diaNode.hasFocus) _enforceOrRevert(_dia, false); });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose(); _sys.dispose(); _dia.dispose();
    _sysNode.dispose(); _diaNode.dispose();
    super.dispose();
  }

  // --- Валидация норм (НЕ мед. нормы, а пользовательские «правила» для профиля)
  bool _okSys(int v) => v >= 90 && v <= 140;
  bool _okDia(int v) => v >= 70 && v <= 100;

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final s = int.tryParse(_sys.text);
      final d = int.tryParse(_dia.text);
      if (s != null && d != null && _okSys(s) && _okDia(d)) {
        _lastSys = s;
        _lastDia = d;
        // TODO: сохранить в настройки/хранилище
        // например: SettingsService.saveNorms(s, d);
      }
    });
  }

  void _enforceOrRevert(TextEditingController c, bool isSys) {
    final v = int.tryParse(c.text);
    final ok = v != null && (isSys ? _okSys(v) : _okDia(v));
    final fb = (isSys ? _lastSys : _lastDia).toString();
    if (!ok && c.text != fb) {
      c.text = fb;
      c.selection = TextSelection.collapsed(offset: fb.length);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // --- Шапка 128dp
          Container(
            height: dp(context, 128),
            color: theme.primaryColor,
            padding: EdgeInsets.only(
              left: _pad, right: _pad,
              bottom: dp(context, 16),
              top: MediaQuery.of(context).padding.top + dp(context, 8),
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              'Профиль',
              style: TextStyle(
                fontSize: dp(context, 26),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),

          // --- Контент
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  _pad, _pad, _pad,
                  MediaQuery.of(context).padding.bottom + dp(context, 120),
                ),
                children: [
                  _accountCard(),
                  SizedBox(height: _pad),
                  _profileCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Account
  Widget _accountCard() {
    // размеры как договорились
    final double sidePad  = (_accW - _innerW) / 2;          // 12dp
    final double titleTop = dp(context, 10);                // "Аккаунт"
    final double titleToInner = dp(context, 8);             // от заголовка до серой области
    final double innerTop = titleTop + titleToInner;

    // фиксируем высоты элементов внутри серой области
    final double labelH = dp(context, 14);                  // высота подписи "Вы не вошли…"
    final double gap = (_innerH - _btnH - labelH).clamp(0, _innerH);

    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: _accW,
        height: _accH,
        child: Material(
          color: Colors.white,
          elevation: 0,
          shadowColor: _shadowCol,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_r),
            side: const BorderSide(color: _cardBorder),
          ),
          child: Stack(
            children: [
              // Заголовок "Аккаунт"
              Positioned(
                left: sidePad,
                top: titleTop,
                child: Text(
                  'Аккаунт',
                  style: _tsLabel().copyWith(fontSize: dp(context, 15)),
                ),
              ),

              // Серая область 296×84, F0F4F8
              Positioned(
                left: sidePad,
                top: innerTop,
                child: Container(
                  width: _innerW,
                  height: _innerH,
                  decoration: BoxDecoration(
                    color: _innerFill,                       // #F0F4F8
                    borderRadius: BorderRadius.circular(_r),
                    boxShadow: _shadow,
                  ),
                  // только горизонтальные отступы, чтобы влезть в 84px
                  padding: EdgeInsets.symmetric(horizontal: dp(context, 12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: labelH,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Вы не вошли в аккаунт',
                            style: TextStyle(
                              fontSize: dp(context, 14),
                              height: 1.0,                   // фиксируем реальную высоту
                              fontWeight: FontWeight.w600,
                              color: _textHint,              // #A0AEC0
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: gap),                 // автоматически займёт остаток
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: _btnW,                      // 272
                          height: _btnH,                     // 48
                          child: ElevatedButton(
                            onPressed: _isLoggingIn ? null : () async {
                              setState(() => _isLoggingIn = true);
                              try { await Future.delayed(const Duration(milliseconds: 600)); }
                              finally { if (mounted) setState(() => _isLoggingIn = false); }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E5D85), // #2E5D85
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_r),  // 10
                              ),
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: .12),
                              textStyle: TextStyle(
                                fontSize: dp(context, 18),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Войти'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // ───────────────── Profile
  Widget _profileCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Имя
        _label('Имя'),
        SizedBox(height: dp(context, 8)),
        _pill(
          child: TextField(
            controller: _name,
            decoration: _inputDecoration('Имя'),
            style: _tsValue(),
            onEditingComplete: () {
              final v = _name.text.trim();
              if (v.isEmpty) _name.text = '';
              // TODO: save name
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        SizedBox(height: dp(context, 12)),

        // Пол + Дата рождения
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Пол'),
                  SizedBox(height: dp(context, 8)),
                  Wrap(
                    spacing: dp(context, 8),
                    runSpacing: dp(context, 8), // если вдруг уйдёт на вторую строку
                    children: [
                      _sexChip('Муж.', _sex == 0, () => setState(() => _sex = 0)),
                      _sexChip('Жен.', _sex == 1, () => setState(() => _sex = 1)),
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(width: dp(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Дата рождения'),
                  SizedBox(height: dp(context, 8)),
                  _pill(
                    trailingChevron: true,
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _birth ?? DateTime(now.year - 30, now.month, now.day),
                        firstDate: DateTime(1900, 1, 1),
                        lastDate: DateTime(now.year, now.month, now.day),
                        helpText: 'Дата рождения',
                      );
                      if (picked != null) setState(() => _birth = picked);
                    },
                    child: Text(
                      _birth == null
                          ? 'Дата рождения'
                          : '${_d2(_birth!.day)}.${_d2(_birth!.month)}.${_birth!.year}',
                      style: _tsValue(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: dp(context, 12)),

        // Нормы давления
        _label('Нормы давления'),
        SizedBox(height: dp(context, 8)),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel('Верхнее'),
                  SizedBox(height: dp(context, 8)),
                  _pill(
                    child: TextField(
                      controller: _sys, focusNode: _sysNode,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('120'),
                      style: _tsValue(),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: dp(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subLabel('Нижнее'),
                  SizedBox(height: dp(context, 8)),
                  _pill(
                    child: TextField(
                      controller: _dia, focusNode: _diaNode,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('80'),
                      style: _tsValue(),
                      onChanged: (_) => _scheduleSave(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: dp(context, 12)),

        // Политика
        Center(
          child: Text('Политика конфиденциальности', style: TextStyle(
            color: _textValue, fontWeight: FontWeight.w600, fontSize: dp(context, 14),
          )),
        ),
      ],
    ),
  );

  // ───────────────── Примитивы
  Widget _card({required Widget child}) => Material(
    color: Colors.white,
    elevation: 0,
    shadowColor: _shadowCol,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_r),
      side: const BorderSide(color: _cardBorder),
    ),
    child: Padding(
      padding: EdgeInsets.all(dp(context, 16)),
      child: child,
    ),
  );

  Widget _pill({
    required Widget child,
    bool trailingChevron = false,
    VoidCallback? onTap,
    Color? fill,
  }) {
    final box = Container(
      height: _hInp,
      padding: EdgeInsets.symmetric(horizontal: dp(context, 14)),
      decoration: BoxDecoration(
        color: fill ?? Colors.white,
        borderRadius: BorderRadius.circular(_r),
        boxShadow: _shadow,
      ),
      child: Row(
        children: [
          Expanded(child: DefaultTextStyle(style: _tsValue(), child: child)),
          if (trailingChevron)
            Padding(
              padding: EdgeInsets.only(left: dp(context, 8)),
              child: Icon(Icons.arrow_drop_down, size: dp(context, 22), color: _textHint),
            ),
        ],
      ),
    );
    return onTap == null
        ? box
        : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: box);
  }

  Widget _primaryButton({
    required String title,
    required VoidCallback? onTap,
    bool loading = false,
  }) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      height: _hBtn,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: loading ? const Color(0xFFD9DEE5) : _textValue,
        borderRadius: BorderRadius.circular(_r),
        boxShadow: _shadow,
      ),
      child: loading
          ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text('Войти', style: TextStyle(
          color: Colors.white, fontSize: dp(context, 18), fontWeight: FontWeight.w700)),
    ),
  );

  Widget _sexChip(String text, bool selected, VoidCallback onTap) {
    final bg    = selected ? _textValue.withOpacity(.10) : _chipBg;
    final color = selected ? _textValue : _textValue.withOpacity(.85);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: _hInp,
      padding: EdgeInsets.symmetric(horizontal: dp(context, 14)),
      constraints: BoxConstraints(minWidth: dp(context, 80)), // стабилизирует ширину
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_r),
        boxShadow: _shadow,
      ),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: _tsValue().copyWith(fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }


  TextStyle _tsValue() => TextStyle(fontSize: dp(context, 18), fontWeight: FontWeight.w700, color: _textValue);
  TextStyle _tsLabel() => TextStyle(fontSize: dp(context, 14), fontWeight: FontWeight.w600, color: _textHint);

  Widget _label(String s)    => Text(s, style: _tsLabel().copyWith(fontSize: dp(context, 15)));
  Widget _subLabel(String s) => Text(s, style: _tsLabel().copyWith(fontWeight: FontWeight.w700));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero,
    hintText: hint, hintStyle: _tsValue().copyWith(color: _textHint),
  );

  String _d2(int v) => v < 10 ? '0$v' : '$v';
}
