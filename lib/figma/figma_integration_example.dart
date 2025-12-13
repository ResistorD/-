/// Пример интеграции Figma-дизайна в приложение
/// 
/// Этот файл демонстрирует, как использовать компоненты и принципы,
/// разработанные для оптимизации под Figma-эскизы

import 'package:flutter/material.dart';
import 'figma_guidelines.dart';

/// Демонстрационный экран, показывающий использование Figma-компонентов
class FigmaIntegrationDemo extends StatelessWidget {
  const FigmaIntegrationDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Figma Integration Demo',
          style: FigmaDesignSystem.typography['titleLarge'],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Карточка с данными, оформленная согласно Figma-дизайну
              FigmaContainer.card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Пример карточки данных',
                      style: FigmaDesignSystem.typography['titleMedium'],
                    ),
                    FigmaSizedBox.unit(heightFactor: 1),
                    Text(
                      'Это пример контента внутри карточки, оформленной по Figma-спецификациям.',
                      style: FigmaDesignSystem.typography['bodyMedium'],
                    ),
                  ],
                ),
              ),
              
              FigmaSizedBox.unit(heightFactor: 2), // 16dp отступа
                
              // Кнопка, оформленная согласно Figma-дизайну
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: FigmaDesignSystem.borderRadius['medium'],
                ),
                child: Center(
                  child: Text(
                    'Figma Button',
                    style: FigmaDesignSystem.typography['labelLarge']
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              
              FigmaSizedBox.unit(heightFactor: 2), // 16dp отступа
              
              // Список с Figma-оформлением
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => FigmaSizedBox.unit(heightFactor: 0.5),
                itemBuilder: (context, index) => FigmaContainer(
                  padding: EdgeInsets.all(12),
                  borderRadius: FigmaDesignSystem.borderRadius['small'],
                  color: Theme.of(context).cardColor,
                  child: Text(
                    'Элемент списка $index',
                    style: FigmaDesignSystem.typography['bodyMedium'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}