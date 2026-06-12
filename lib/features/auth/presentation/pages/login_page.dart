// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../provider/auth_provider.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../provider/login_form_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => LoginFormProvider(), child: const _LoginPageContent());
  }
}

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent();

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Initialize TabController via the provider
    context.read<LoginFormProvider>().initTabController(this);
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (mounted && rememberMe && email != null && password != null) {
      final formProvider = context.read<LoginFormProvider>();
      formProvider.emailController.text = email;
      formProvider.passwordController.text = password;
      formProvider.toggleRememberMe(true);
    }
  }

  void _submit() async {
    final formProvider = context.read<LoginFormProvider>();
    if (formProvider.formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      bool success;

      // Close keyboard
      FocusScope.of(context).unfocus();

      if (formProvider.isLogin) {
        success = await auth.login(formProvider.emailController.text, formProvider.passwordController.text);
      } else {
        success = await auth.register(formProvider.emailController.text, formProvider.passwordController.text, formProvider.nameController.text);
      }

      if (mounted) {
        if (!success) {
          final error = context.read<AuthProvider>().error;
          CustomSnackbar.showError(context, error ?? 'Authentication failed');
        } else {
          try {
            final prefs = await SharedPreferences.getInstance();
            if (formProvider.isRememberMe) {
              await prefs.setString('saved_email', formProvider.emailController.text);
              await prefs.setString('saved_password', formProvider.passwordController.text);
              await prefs.setBool('remember_me', true);
            } else {
              await prefs.remove('saved_email');
              await prefs.remove('saved_password');
              await prefs.setBool('remember_me', false);
            }
          } catch (_) {
            // Ignore storage errors
          }

          final user = context.read<AuthProvider>().user;
          if (user != null) {
            context.read<SettingsProvider>().syncWithUser(user);
            context.read<ThemeProvider>().syncWithUser(user);
          }
          CustomSnackbar.showSuccess(context, 'Welcome back!');
        }
      }
    }
  }

  void _showForgotPassword(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Forgot Password'),
          content: const Text('Password reset link sent to your email (Mock).'),
          actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Forgot Password'),
          content: const Text('Password reset link sent to your email (Mock).'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return PlatformScaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // 1. Animated Mesh Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      settings.primaryColor,
                      settings.primaryColor.withValues(alpha: 0.8),
                      // Dynamic shift between dark/light accent
                      HSLColor.fromColor(settings.primaryColor).withHue((HSLColor.fromColor(settings.primaryColor).hue + 30) % 360).toColor(),
                      isDark ? Colors.black : Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 5.seconds, color: Colors.white10),

              // 2. Floating Particles/Bubbles
              _buildBackgroundParticles(15.h, 10.w, 30.w),
              _buildBackgroundParticles(70.h, -10.w, 40.w, delay: 2.seconds),

              // 3. Main Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header Logo
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 9.h,
                          color: Colors.white.withValues(alpha: 0.95),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack),

                        SizedBox(height: 1.5.h),

                        Text(
                          'Expense Tracker',
                          style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                        SizedBox(height: 4.h),

                        // Glass Form Card
                        GlassContainer(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                          blur: 20,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          color: Colors.white.withValues(alpha: 0.05),
                          // More subtle
                          child: Consumer<LoginFormProvider>(
                            builder: (context, formProvider, _) {
                              return Form(
                                key: formProvider.formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tab Bar
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(25)),
                                      child: TabBar(
                                        controller: formProvider.tabController,
                                        indicator: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(22),
                                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                        ),
                                        labelColor: settings.primaryColor,
                                        unselectedLabelColor: Colors.white70,
                                        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                        dividerColor: Colors.transparent,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        tabs: const [
                                          Tab(text: 'Login'),
                                          Tab(text: 'Register'),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 300.ms),

                                    SizedBox(height: 3.h),

                                    // Animated Form Fields
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        children: [
                                          _buildTextField(controller: formProvider.emailController, label: 'Email Address', icon: Icons.email_rounded, delay: 50),
                                          if (!formProvider.isLogin) ...[
                                            SizedBox(height: 2.h),
                                            _buildTextField(controller: formProvider.nameController, label: 'Full Name', icon: Icons.person_rounded, delay: 50),
                                          ],
                                          SizedBox(height: 2.h),
                                          _buildTextField(controller: formProvider.passwordController, label: 'Password', icon: Icons.lock_rounded, isObscure: true, delay: 50),
                                          if (formProvider.isLogin) ...[
                                            SizedBox(height: 1.h),
                                            Row(
                                              children: [
                                                if (Platform.isIOS)
                                                  Transform.scale(
                                                    scale: 0.8,
                                                    child: CupertinoSwitch(
                                                      value: formProvider.isRememberMe,
                                                      activeTrackColor: settings.primaryColor,
                                                      inactiveTrackColor: Colors.white24,
                                                      onChanged: (v) => formProvider.toggleRememberMe(v),
                                                    ),
                                                  )
                                                else
                                                  Checkbox(
                                                    value: formProvider.isRememberMe,
                                                    activeColor: settings.primaryColor,
                                                    side: const BorderSide(color: Colors.white70),
                                                    onChanged: (v) => formProvider.toggleRememberMe(v ?? false),
                                                  ),
                                                Text(
                                                  'Remember Me',
                                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15.sp),
                                                ),
                                              ],
                                            ).animate().fadeIn(delay: 100.ms),
                                          ],
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 4.h),

                                    // Action Button
                                    Consumer<AuthProvider>(
                                      builder: (context, auth, _) {
                                        return SizedBox(
                                          width: double.infinity,
                                          height: 6.5.h,
                                          child: PlatformButton(
                                            onPressed: auth.isLoading ? null : _submit,
                                            color: Colors.white,
                                            child: auth.isLoading
                                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                                                : AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    child: Text(
                                                      formProvider.isLogin ? 'LOG IN' : 'CREATE ACCOUNT',
                                                      key: ValueKey(formProvider.isLogin),
                                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17.sp, letterSpacing: 1.0, color: settings.primaryColor),
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5, end: 0),

                                    SizedBox(height: 2.h),

                                    TextButton(
                                      onPressed: () => _showForgotPassword(context),
                                      child: Text(
                                        'Forgot Password?',
                                        style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600, fontSize: 15.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                        SizedBox(height: 3.h),

                        Consumer<LoginFormProvider>(
                          builder: (context, form, _) => Text(
                            '', // Placeholder or remove if unnecessary
                            style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.6), fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundParticles(double top, double right, double size, {Duration? delay}) {
    return Positioned(
      top: top,
      right: right,
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1), delay: delay)
              .moveY(duration: 6.seconds, begin: 0, end: -20, delay: delay),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isObscure = false, required int delay}) {
    // Keeping TextFormField for custom transparent styling which matches the gradient look
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.05, end: 0);
  }
}
