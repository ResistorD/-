// FILE: lib/widgets/custom_header.dart
// Заголовок «Мой дневник» + рабочий токен выбора периода (меню).

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/scale.dart';

class CustomHeader extends StatefulWidget {
  const CustomHeader({
    super.key,
    required this.title,
    required this.periodLabel,
    required this.onPick,
  });

  final String title;
  final String periodLabel;
  final ValueChanged<String> onPick;

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final MenuController _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: t.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: HomeTokens.titleFont(context),
            color: Colors.white,
          ),
        ),

        // Токен с выпадающим меню
        MenuAnchor(
          controller: _menu,
          menuChildren: [
            MenuItemButton(onPressed: () { widget.onPick('Сегодня'); }, child: const Text('Сегодня')),
            MenuItemButton(onPressed: () { widget.onPick('Неделя'); },  child: const Text('Неделя')),
            MenuItemButton(onPressed: () { widget.onPick('Месяц'); },   child: const Text('Месяц')),
            MenuItemButton(onPressed: () { widget.onPick('Всё время'); }, child: const Text('Всё время')),
          ],
          builder: (context, controller, child) {
            return GestureDetector(
              onTap: () => controller.isOpen ? controller.close() : controller.open(),
              child: Container(
                height: HomeTokens.tokenHeight(context),                      // ← фикс высота
                padding: EdgeInsets.symmetric(horizontal: HomeTokens.tokenPadH(context)),
                decoration: BoxDecoration(
                  color: HomeTokens.tokenBg(context),
                  borderRadius: BorderRadius.circular(HomeTokens.tokenRadius(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.periodLabel,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: HomeTokens.tokenFont(context),
                        color: HomeTokens.tokenFg(context),
                      ),
                    ),
                    SizedBox(width: dp(context, 6)),
                    Icon(Icons.arrow_drop_down,
                      size: HomeTokens.arrowSize(context),
                      color: HomeTokens.arrowColor(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
