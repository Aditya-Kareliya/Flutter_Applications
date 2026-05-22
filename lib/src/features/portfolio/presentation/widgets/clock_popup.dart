import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../logic/portfolio_provider.dart';

class ClockPopup extends StatefulWidget {
  const ClockPopup({super.key});

  @override
  State<ClockPopup> createState() => _ClockPopupState();
}

class _ClockPopupState extends State<ClockPopup> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late DateTime _currentTime;
  late AnimationController _enterController;
  late Animation<double> _scaleAnimation;

  final List<String> _dateFormats = [
    'EEE, dd MMM yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    _enterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = CurvedAnimation(parent: _enterController, curve: Curves.fastOutSlowIn);
    _enterController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final portfolioProvider = context.watch<PortfolioProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = themeProvider.seedColor;

    final bool is24Hour = portfolioProvider.is24Hour;
    final int hourRaw = is24Hour ? _currentTime.hour : (_currentTime.hour % 12 == 0 ? 12 : _currentTime.hour % 12);
    final hours = hourRaw.toString().padLeft(2, '0');
    final minutes = _currentTime.minute.toString().padLeft(2, '0');
    final seconds = _currentTime.second.toString().padLeft(2, '0');
    final period = _currentTime.hour >= 12 ? 'PM' : 'AM';
    final dateStr = intl.DateFormat(portfolioProvider.dateFormat).format(_currentTime);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 580),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 40,
                      spreadRadius: -10,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Stack(
                      children: [
                        // Decorative orbs
                        Positioned(
                          top: -60, left: -60,
                          child: Container(
                            width: 200, height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.15),
                              backgroundBlendMode: BlendMode.screen,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80, right: -40,
                          child: Container(
                            width: 250, height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.1),
                              backgroundBlendMode: BlendMode.colorDodge,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings_suggest_rounded, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Clock Settings',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white60 : Colors.black54, size: 26),
                                  ),
                                ],
                              ),
                            ),
                            
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                child: Column(
                                  children: [
                                    // Large Time Display
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _bigDigit(hours[0], isDark),
                                        _bigDigit(hours[1], isDark),
                                        _bigSeparator(isDark),
                                        _bigDigit(minutes[0], isDark),
                                        _bigDigit(minutes[1], isDark),
                                        if (!is24Hour) ...[
                                          const SizedBox(width: 6),
                                          _ampmBadge(period, primaryColor, isDark),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Seconds row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('sec ', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38)),
                                        _smallDigit(seconds[0], isDark),
                                        _smallDigit(seconds[1], isDark),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Date
                                    Text(
                                      dateStr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(height: 1, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07)),
                                    const SizedBox(height: 20),
                                    
                                    // Settings: 12H / 24H Toggle
                                    _sectionTitle('Time Format', Icons.access_time_rounded, isDark),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          _formatBtn('12 Hour', !is24Hour, primaryColor, isDark, () => portfolioProvider.set24Hour(false)),
                                          _formatBtn('24 Hour', is24Hour, primaryColor, isDark, () => portfolioProvider.set24Hour(true)),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Settings: Date Format
                                    _sectionTitle('Date Format', Icons.calendar_today_rounded, isDark),
                                    const SizedBox(height: 12),
                                    Column(
                                      children: _dateFormats.map((format) {
                                        final bool isSelected = portfolioProvider.dateFormat == format;
                                        // Preview text
                                        final previewStr = intl.DateFormat(format).format(_currentTime);
                                        return GestureDetector(
                                          onTap: () => portfolioProvider.setDateFormat(format),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? primaryColor.withOpacity(0.15) 
                                                  : (isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5)),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(
                                                color: isSelected ? primaryColor.withOpacity(0.5) : Colors.transparent,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    previewStr,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                      color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected) 
                                                  Icon(Icons.check_circle_rounded, color: primaryColor, size: 20),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _bigDigit(String digit, bool isDark) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInQuint,
        transitionBuilder: (child, animation) {
          final isEntering = child.key == ValueKey<String>('t$digit');
          final slide = Tween<Offset>(
            begin: isEntering ? const Offset(0, 0.7) : const Offset(0, -0.7),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
        },
        child: Text(
          digit,
          key: ValueKey<String>('t$digit'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _bigSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 3, right: 3),
      child: AnimatedOpacity(
        opacity: _currentTime.second.isEven ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 600),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _ampmBadge(String period, Color primary, bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(period),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ),
    );
  }

  Widget _smallDigit(String digit, bool isDark) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInQuint,
        transitionBuilder: (child, animation) {
          final isEntering = child.key == ValueKey<String>('s$digit');
          final slide = Tween<Offset>(
            begin: isEntering ? const Offset(0, 0.7) : const Offset(0, -0.7),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
        },
        child: Text(
          digit,
          key: ValueKey<String>('s$digit'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.35),
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _formatBtn(String label, bool selected, Color primary, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? [BoxShadow(color: primary.withOpacity(0.35), blurRadius: 8, spreadRadius: 0)] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
            ),
          ),
        ),
      ),
    );
  }
}
