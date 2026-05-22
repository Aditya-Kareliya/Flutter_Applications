import 'dart:ui';
import 'dart:async';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/portfolio_bottom_nav_bar.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/theme_color_box.dart';
import '../../../shared/widgets/theme_mode_toggle.dart';
import '../../preview_app/logic/preview_provider.dart';
import '../../preview_app/presentation/preview_app_theme.dart';
import 'package:intl/intl.dart' as intl;
import '../data/gita_data.dart';
import '../logic/portfolio_provider.dart';
import 'widgets/gita_shloka_popup.dart';
import 'widgets/intro_popup.dart';
import 'widgets/clock_popup.dart';

class PortfolioScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const PortfolioScreen({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Consumer3<PortfolioProvider, ThemeProvider, PlatformProvider>(
      builder: (context, portfolioProvider, themeProvider, platformProvider, _) {
        final bool isMobileLayout = portfolioProvider.isMobileLayout(context);
        final bool isDashboard = location == '/';

        if (isMobileLayout) {
          final isApple = platformProvider.useCupertinoStyle;
          final theme = Theme.of(context);
          final scaffoldBgColor = theme.scaffoldBackgroundColor;
          final safeAreaColor = isApple ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white) : scaffoldBgColor;

          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              if (portfolioProvider.panelOpen) {
                portfolioProvider.closePanel();
              }
            },
            child: Scaffold(
              body: ColoredBox(
                color: safeAreaColor,
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      PreviewAppTheme(child: child),
                      if (portfolioProvider.panelOpen)
                        GestureDetector(
                          onTap: portfolioProvider.closePanel,
                          child: Container(color: Colors.transparent),
                        ),
                      _MobileSidePanel(provider: portfolioProvider),
                      if (isDashboard) _MenuButton(provider: portfolioProvider),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return GradientScaffold(
          bottomNavigationBar: const PortfolioBottomNavBar(),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(flex: 2, child: const _LeftSection()),
                  SizedBox(width: 4.w),
                  Expanded(flex: 3, child: _MiddleSection(child: child)),
                  SizedBox(width: 4.w),
                  Expanded(flex: 2, child: const _RightSection()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileSidePanel extends StatelessWidget {
  final PortfolioProvider provider;

  const _MobileSidePanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      right: provider.panelOpen ? 0 : -80.w,
      top: 0,
      bottom: 0,
      width: 80.w,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    Divider(thickness: 0.8, color: Theme.of(context).colorScheme.primary),
                    SizedBox(height: 1.h),
                    const _LeftSection(),
                    SizedBox(height: 3.h),
                    const _RightSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final PortfolioProvider provider;

  const _MenuButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 1.h,
      right: 4.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: provider.togglePanel,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6), borderRadius: BorderRadius.circular(14)),
            child: Image.asset(provider.panelOpen ? "assets/icons/menu_open.png" : "assets/icons/menu_close.png", width: 24, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class _LeftSection extends StatelessWidget {
  const _LeftSection();

  void _showShloka(BuildContext context, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => GitaShlokaPopup(initialIndex: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _IntroSection(),
        SizedBox(height: 3.h),
        _GitaSection(onTap: (index) => _showShloka(context, index)),
      ],
    );
  }
}

class _IntroSection extends StatefulWidget {
  const _IntroSection();

  @override
  State<_IntroSection> createState() => _IntroSectionState();
}

class _IntroSectionState extends State<_IntroSection> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showIntro(BuildContext context) {
    showDialog(context: context, barrierColor: Colors.black.withOpacity(0.4), builder: (context) => const IntroPopup());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => _showIntro(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(_isHovering ? 0.2 : 0.1), primaryColor.withOpacity(_isHovering ? 0.05 : 0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryColor.withOpacity(_isHovering ? 0.5 : 0.3), width: _isHovering ? 1.5 : 1.0),
            boxShadow: _isHovering ? [BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 15, spreadRadius: 2)] : [],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(scale: 1.0 + (_pulseController.value * 0.05), child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    border: Border.all(color: themeProvider.seedColor),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10)],
                  ),
                  child: Icon(Icons.handshake_rounded, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, I am Aditya Kareliya',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flutter Developer & UI Enthusiast',
                      style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: primaryColor.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GitaSection extends StatefulWidget {
  final Function(int) onTap;

  const _GitaSection({required this.onTap});

  @override
  State<_GitaSection> createState() => _GitaSectionState();
}

class _GitaSectionState extends State<_GitaSection> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _currentIndex = 0;
  bool _isHovering = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _currentIndex = DateTime.now().millisecond % GitaData.shlokas.length;
    _timer = Timer.periodic(const Duration(seconds: 70), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % GitaData.shlokas.length;
        });
      }
    });

    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentShloka = GitaData.shlokas[_currentIndex];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => widget.onTap(_currentIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(_isHovering ? 0.2 : 0.1), primaryColor.withOpacity(_isHovering ? 0.05 : 0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(_isHovering ? 0.5 : 0.3), width: _isHovering ? 1.5 : 1.0),
            boxShadow: _isHovering ? [BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 15, spreadRadius: 2)] : [],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(scale: 1.0 + (_pulseController.value * 0.05), child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    border: Border.all(color: themeProvider.seedColor),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bhagavad Gita',
                            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, letterSpacing: 0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            'Ch ${currentShloka.chapter}',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Text(
                        currentShloka.shloka.split('\n').first,
                        key: ValueKey<int>(_currentIndex),
                        style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white70 : Colors.black54, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiddleSection extends StatelessWidget {
  final Widget child;

  const _MiddleSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlatformProvider>(
      builder: (_, previewProvider, _) {
        return Center(
          child: SizedBox(
            key: ValueKey(previewProvider.selectedPlatform),
            height: 100.h,
            child: DeviceFrame(
              device: previewProvider.deviceInfo,
              orientation: previewProvider.orientation,
              isFrameVisible: true,
              screen: PreviewAppTheme(child: child),
            ),
          ),
        );
      },
    );
  }
}

class _RightSection extends StatelessWidget {
  const _RightSection();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, PlatformProvider>(
      builder: (_, themeProvider, platformProvider, _) {
        return Column(
          children: [
            const _DigitalClockSection(),
            SizedBox(height: 3.h),
            const ThemeModeToggle(),
            SizedBox(height: 2.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: themeProvider.colors.length,
              padding: EdgeInsets.all(2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2.w, mainAxisSpacing: 2.w, childAspectRatio: 1),
              itemBuilder: (_, i) {
                return ThemeColorBox(color: themeProvider.colors[i]);
              },
            ),
          ],
        );
      },
    );
  }
}

class _DigitalClockSection extends StatefulWidget {
  const _DigitalClockSection();

  @override
  State<_DigitalClockSection> createState() => _DigitalClockSectionState();
}

class _DigitalClockSectionState extends State<_DigitalClockSection> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late DateTime _currentTime;
  bool _isHovering = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _openPopup(BuildContext context) {
    showDialog(context: context, barrierColor: Colors.black.withOpacity(0.4), builder: (_) => const ClockPopup());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final portfolioProvider = context.watch<PortfolioProvider>();
    final primaryColor = themeProvider.seedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool is24Hour = portfolioProvider.is24Hour;
    final int hourRaw = is24Hour ? _currentTime.hour : (_currentTime.hour % 12 == 0 ? 12 : _currentTime.hour % 12);
    final hours = hourRaw.toString().padLeft(2, '0');
    final minutes = _currentTime.minute.toString().padLeft(2, '0');
    final seconds = _currentTime.second.toString().padLeft(2, '0');
    final period = _currentTime.hour >= 12 ? 'PM' : 'AM';
    final dateStr = intl.DateFormat(portfolioProvider.dateFormat).format(_currentTime);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => _openPopup(context),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(_isHovering ? 0.2 : 0.08 + _glowController.value * 0.06), primaryColor.withOpacity(_isHovering ? 0.06 : 0.01 + _glowController.value * 0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withOpacity(_isHovering ? 0.55 : 0.28 + _glowController.value * 0.12), width: _isHovering ? 1.5 : 1.0),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(_isHovering ? 0.2 : 0.06 + _glowController.value * 0.08), blurRadius: _isHovering ? 18 : 12, spreadRadius: _isHovering ? 2 : 0)],
              ),
              child: child,
            );
          },
          child: Column(
            children: [
              // Main Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildAnimatedDigit(hours[0], isDark),
                  _buildAnimatedDigit(hours[1], isDark),
                  _buildBlinkingColon(isDark),
                  _buildAnimatedDigit(minutes[0], isDark),
                  _buildAnimatedDigit(minutes[1], isDark),
                  if (!is24Hour) ...[const SizedBox(width: 6), _buildAmPmBadge(period, isDark, primaryColor)],
                ],
              ),
              const SizedBox(height: 6),
              // Seconds row (smaller)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedDigit(seconds[0], isDark, isSeconds: true),
                  _buildAnimatedDigit(seconds[1], isDark, isSeconds: true),
                  const SizedBox(width: 4),
                  Text(
                    'sec',
                    style: TextStyle(fontSize: 11.sp, color: isDark ? Colors.white30 : Colors.black26),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date + tap hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: isDark ? Colors.white60 : Colors.black54, letterSpacing: 1.0),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.date_range_outlined, size: 13, color: isDark ? Colors.white30 : Colors.black26),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDigit(String digit, bool isDark, {bool isSeconds = false}) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInQuint,
        transitionBuilder: (child, animation) {
          final isEntering = child.key == ValueKey<String>('${isSeconds ? "s" : "t"}$digit');
          final slide = Tween<Offset>(begin: isEntering ? const Offset(0, 0.7) : const Offset(0, -0.7), end: Offset.zero).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Text(
          digit,
          key: ValueKey<String>('${isSeconds ? "s" : "t"}$digit'),
          style: TextStyle(
            fontSize: isSeconds ? 15.sp : 22.sp,
            fontWeight: isSeconds ? FontWeight.w400 : FontWeight.bold,
            color: isSeconds ? (isDark ? Colors.white.withOpacity(0.45) : Colors.black.withOpacity(0.30)) : (isDark ? Colors.white : Colors.black87),
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildBlinkingColon(bool isDark) {
    return AnimatedOpacity(
      opacity: _currentTime.second.isEven ? 1.0 : 0.25,
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
        child: Text(
          ':',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black45),
        ),
      ),
    );
  }

  Widget _buildAmPmBadge(String period, bool isDark, Color primary) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(period),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
        margin: const EdgeInsets.only(bottom: 6, left: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary.withOpacity(0.25), primary.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.4), width: 1.2),
          boxShadow: [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Text(
          period,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: isDark ? Colors.white54 : Colors.black54, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
