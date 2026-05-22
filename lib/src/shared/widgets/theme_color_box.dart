import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/theme/theme_provider.dart';

class ThemeColorBox extends StatelessWidget {
  final Color color;

  const ThemeColorBox({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, _) {
        final bool isSelected = color.value == themeProvider.seedColor.value;

        return GestureDetector(
          onTap: () => themeProvider.setSeedColor(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 0.5.w),
            ),
            child: isSelected ? const Center(child: Icon(Icons.check, color: Colors.white, size: 20)) : null,
          ),
        );
      },
    );
  }
}
