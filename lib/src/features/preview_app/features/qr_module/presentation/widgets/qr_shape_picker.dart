import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../logic/preview_provider.dart';

class QRShapePicker extends StatelessWidget {
  final String selectedShape;
  final ValueChanged<String> onShapeChanged;
  final String label;
  final List<ShapeOption> options;

  const QRShapePicker({super.key, required this.selectedShape, required this.onShapeChanged, required this.label, required this.options});

  @override
  Widget build(BuildContext context) {
    final isCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCupertino ? CupertinoColors.label.resolveFrom(context) : Theme.of(context).textTheme.titleMedium?.color),
        ),
        const SizedBox(height: 12),
        if (isCupertino) _buildCupertinoPicker(context) else _buildMaterialPicker(context),
      ],
    );
  }

  Widget _buildMaterialPicker(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedShape == option.value;
        return GestureDetector(
          onTap: () => onShapeChanged(option.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).unselectedWidgetColor.withValues(alpha: 0.5) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option.icon, color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: TextStyle(color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCupertinoPicker(BuildContext context) {
    final isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Container(
      height: 50,
      decoration: BoxDecoration(color: isDarkMode ? CupertinoColors.systemGrey6.darkHighContrastColor : CupertinoColors.systemGrey6.color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          final isSelected = selectedShape == option.value;
          return GestureDetector(
            onTap: () => onShapeChanged(option.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: isSelected ? CupertinoColors.activeBlue : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.icon, color: isSelected ? CupertinoColors.white : CupertinoColors.secondaryLabel.resolveFrom(context), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? CupertinoColors.white : CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ShapeOption {
  final String value;
  final String label;
  final IconData icon;

  const ShapeOption({required this.value, required this.label, required this.icon});
}
