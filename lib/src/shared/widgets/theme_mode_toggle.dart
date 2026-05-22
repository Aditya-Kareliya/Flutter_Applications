import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDarkTheme ? 0.12 : 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: AppThemeType.values.map((type) {
                    final bool isSelected = themeProvider.themeType == type;

                    return GestureDetector(
                      onTap: () => themeProvider.setTheme(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? _selectedBackground(context, isDarkTheme) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected && !isDarkTheme ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.6)) : null,
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(isDarkTheme ? 0.4 : 0.15), blurRadius: 6, offset: const Offset(0, 2))] : [],
                        ),
                        child: Icon(_iconForType(type), size: 18, color: isSelected ? Theme.of(context).colorScheme.onPrimary : (isDarkTheme ? Colors.white : Colors.black87)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _selectedBackground(BuildContext context, bool isDarkTheme) {
    final scheme = Theme.of(context).colorScheme;
    return isDarkTheme ? scheme.primary : scheme.primary.withOpacity(0.85);
  }

  IconData _iconForType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return Icons.light_mode;
      case AppThemeType.dark:
        return Icons.dark_mode;
      case AppThemeType.system:
        return Icons.settings;
    }
  }
}
