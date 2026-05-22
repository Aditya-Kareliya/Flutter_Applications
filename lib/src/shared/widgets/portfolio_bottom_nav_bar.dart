import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/preview_app/logic/preview_provider.dart';

class PortfolioBottomNavBar extends StatelessWidget {
  const PortfolioBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlatformProvider, ThemeProvider>(
      builder: (context, previewProvider, themeProvider, _) {
        const platformOrder = [
          Platform.androidPhone,
          Platform.iphone,
          Platform.iPad,
        ];
        final selectedIndex = platformOrder.indexOf(previewProvider.selectedPlatform);
        final themeMode = themeProvider.themeMode;
        final isDark = themeMode == ThemeMode.dark;
        final accent = themeProvider.seedColor;

        final bgColor = isDark ? accent.withOpacity(0.25) : accent.withOpacity(0.15);

        Color iconColor(bool selected) {
          if (selected) return accent;
          if (themeMode == ThemeMode.light) return Colors.black54;
          if (themeMode == ThemeMode.dark) return Colors.white54;
          return Colors.grey;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
                  onTap: (index) {
                    previewProvider.updatePlatform(platformOrder[index]);
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: previewProvider.selectedPlatform == Platform.androidPhone ? 1.3 : 1.0,
                        child: Icon(Icons.android, color: iconColor(previewProvider.selectedPlatform == Platform.androidPhone), size: 3.h),
                      ),
                      label: 'Android',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: previewProvider.selectedPlatform == Platform.iphone ? 1.3 : 1.0,
                        child: Icon(Icons.apple, color: iconColor(previewProvider.selectedPlatform == Platform.iphone), size: 3.h),
                      ),
                      label: 'iOS',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: previewProvider.selectedPlatform == Platform.iPad ? 1.3 : 1.0,
                        child: Icon(Icons.tablet_mac, color: iconColor(previewProvider.selectedPlatform == Platform.iPad), size: 3.h),
                      ),
                      label: 'Tablet',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
