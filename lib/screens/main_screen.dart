import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/custom_fab.dart';
import '../theme/scale.dart'; // dp(), sp()

import 'journal_tab.dart';
import 'chart_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart' show ProfileScreen;
import 'entry_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  late final List<Widget> _pages = const [
    JournalTab(), ChartScreen(), SettingsScreen(), ProfileScreen(),
  ];

  void _onSelect(int i) => setState(() => _index = i);

  Future<void> _addEntry() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EntryScreen()),
    );
    if (created == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Масштабируемые размеры (как в макете)
    final ring        = dp(context, 86); // диаметр внешнего кольца FAB
    final inner       = dp(context,  60); // диаметр самой кнопки
    final barHeight   = dp(context, 69); // высота нижнего бара
    final notchMargin = dp(context,   6); // зазор выреза
    final plusSize    = dp(context,  32); // размер «+» на FAB
    final navIconSize = dp(context,  30); // размер иконок внизу

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),

      floatingActionButton: CustomFab(
        onPressed: _addEntry,
        ring: ring,
        inner: inner,
        iconSize: plusSize,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

      bottomNavigationBar: BottomNav(
        index: _index,
        onSelect: _onSelect,
        fabRing: ring,            // окно под кольцо = диаметр ring
        barHeight: barHeight,     // управляет высотой бара
        notchMargin: notchMargin, // аккуратный стык
        iconSize: navIconSize,    // размер иконок внизу
      ),
    );
  }
}
