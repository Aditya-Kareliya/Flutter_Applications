import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/theme/theme_provider.dart';

class IntroPopup extends StatefulWidget {
  const IntroPopup({super.key});

  @override
  State<IntroPopup> createState() => _IntroPopupState();
}

class _IntroPopupState extends State<IntroPopup> with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = CurvedAnimation(parent: _enterController, curve: Curves.fastOutSlowIn);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = themeProvider.seedColor;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
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
                        // Decorative Background Elements
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.15),
                              backgroundBlendMode: BlendMode.screen,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -60,
                          left: -40,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.1),
                              backgroundBlendMode: BlendMode.colorDodge,
                            ),
                          ),
                        ),
                        
                        // Content
                        Column(
                          children: [
                            // Header with Close Button
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
                                        Icon(Icons.person_outline_rounded, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          'About Me',
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
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoTile(
                                      context,
                                      Icons.person_rounded,
                                      'Professional Overview',
                                      'Experienced Flutter Developer passionate about creating beautiful, performant, and user-centric mobile and web applications.',
                                      primaryColor,
                                      isDark,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildInfoTile(
                                      context,
                                      Icons.bolt_rounded,
                                      'Key Skills',
                                      '• Flutter & Dart\n• State Management (Provider, Bloc)\n• Clean Architecture\n• Firebase Integration\n• Custom UI/UX Design',
                                      primaryColor,
                                      isDark,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildInfoTile(
                                      context,
                                      Icons.history_edu_rounded,
                                      'Experience',
                                      '3+ years of building robust cross-platform solutions for diverse clients and domains.',
                                      primaryColor,
                                      isDark,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Bottom Action/Contact Bar
                            Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: isDark ? Colors.white10 : Colors.white, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {}, // Can be wired up later
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.mail_outline_rounded, color: primaryColor, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Get in Touch',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String content, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? color.withOpacity(0.8) : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black87,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
