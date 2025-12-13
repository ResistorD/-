# Оптимизация кода под эскизы Figma

## Введение

Этот документ описывает лучшие практики для оптимизации кода под эскизы Figma в вашем Flutter-проекте. Он поможет вам создать более точное соответствие между дизайном в Figma и реализованным пользовательским интерфейсом.

## Основные принципы

### 1. Система отступов и размеров

В Figma обычно используется система отступов на основе базовой единицы (обычно 8px). Наша реализация использует следующие стандартные значения:

- xxs: 2dp
- xs: 4dp
- sm: 8dp
- md: 12dp
- lg: 16dp
- xl: 20dp
- xxl: 24dp
- xxxl: 32dp

### 2. Типографика

Используйте шкалу типографики, соответствующую Figma-дизайну:

- displayLarge: 57sp
- displayMedium: 45sp
- displaySmall: 36sp
- headlineLarge: 32sp
- headlineMedium: 28sp
- headlineSmall: 24sp
- titleLarge: 22sp
- titleMedium: 16sp
- titleSmall: 14sp
- bodyLarge: 16sp
- bodyMedium: 14sp
- bodySmall: 12sp
- labelLarge: 14sp
- labelMedium: 12sp
- labelSmall: 11sp

### 3. Радиусы скруглений

Стандартные радиусы скруглений:

- small: 4px
- medium: 8px
- large: 12px
- xlarge: 16px
- full: 9999px

## Практические рекомендации

### 1. Измерение расстояний

Когда вы видите элементы в Figma, используйте инструмент измерения, чтобы точно определить расстояния между элементами, и применяйте соответствующие значения из нашей системы отступов.

### 2. Использование Figma-компонентов

Наша библиотека содержит готовые компоненты:

```dart
// Для отступов:
FigmaSizedBox.unit(widthFactor: 2, heightFactor: 1); // 16x8 dp

// Для карточек:
FigmaContainer.card(
  child: MyContent(),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
);
```

### 3. Цветовая палитра

Убедитесь, что вы используете те же цвета, что и в Figma. Вы можете экспортировать цветовую палитру из Figma и добавить её в файл темы приложения.

### 4. Высота строк и отслеживание

Обратите внимание на параметры высоты строк (lineHeight) и отслеживания (letterSpacing), которые также должны соответствовать Figma-дизайну.

## Примеры использования

### Создание карточки, соответствующей Figma-дизайну:

```dart
FigmaContainer.card(
  child: Column(
    children: [
      Text('Заголовок', style: FigmaDesignSystem.typography['titleLarge']),
      FigmaSizedBox.unit(heightFactor: 1), // 8dp отступа
      Text('Содержание', style: FigmaDesignSystem.typography['bodyMedium']),
    ],
  ),
),
```

### Создание кнопки с точными размерами:

```dart
Container(
  width: 120, // Ширина из Figma
  height: 48, // Высота из Figma
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: FigmaDesignSystem.borderRadius['medium'],
  ),
  child: Center(
    child: Text('Кнопка', style: FigmaDesignSystem.typography['labelLarge']),
  ),
)
```

## Интеграция с существующим проектом

Файл `/lib/figma/figma_guidelines.dart` уже интегрирован в проект и может быть импортирован в любых других файлах:

```dart
import 'package:pressure_diary_fresh/lib/figma/figma_guidelines.dart';
```

## Проверка соответствия дизайну

1. После реализации компонента сравните его с Figma-дизайном
2. Убедитесь, что все размеры, цвета, отступы и шрифты соответствуют
3. Используйте инструменты разработчика Flutter для проверки размеров элементов
4. Проверьте отображение на разных размерах экрана

## Заключение

Следование этим рекомендациям поможет обеспечить точное соответствие между дизайном в Figma и финальным продуктом, улучшая качество пользовательского опыта и упрощая процесс верстки.