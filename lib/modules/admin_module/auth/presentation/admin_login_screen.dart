import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/localization/my_app_translations.dart';
import '../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../core/widgets/cultural_frame_card.dart';
import '../../../../core/widgets/heritage_badge.dart';
import '../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../core/widgets/my_app_ui_components.dart';
import 'admin_auth_cubit.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      MyAppToastMessage.warning(
        context,
        title: 'Credentials Required',
        description: 'Please enter both administrator username and password.',
      );
      return;
    }

    context.read<AdminAuthCubit>().signIn(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAuthCubit, AdminAuthState>(
      listener: (context, state) {
        if (state is AdminAuthFailure) {
          MyAppToastMessage.error(
            context,
            title: 'Sign In Failed',
            description: state.message,
          );
        } else if (state is AdminLoggedIn) {
          MyAppToastMessage.success(
            context,
            title: 'Login Successful',
            description: 'Welcome to the Mandal Administration Portal.',
          );
        }
      },
      builder: (context, state) => _buildScaffold(
        context,
        isLoading: state is AdminAuthenticating,
        error: state is AdminAuthFailure ? state.message : null,
        onSignIn: _handleSignIn,
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required bool isLoading,
    required String? error,
    required VoidCallback? onSignIn,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return Scaffold(
      backgroundColor: colors.getBackgroundColor(context),
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: CulturalFrameCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.heritageGold,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/pavan_putra_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: HeritageBadge(
                      label: context.tr('nav_admin'),
                      backgroundColor: colors.getAccentColor(context).withValues(
                        alpha: 0.08,
                      ),
                      textColor: colors.getAccentColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      context.tr('admin_title'),
                      textAlign: TextAlign.center,
                      style: styles.editorialSerif(
                        context,
                        size: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      context.tr('admin_subtitle'),
                      textAlign: TextAlign.center,
                      style: styles
                          .bodySmall(context)
                          .copyWith(color: colors.getMutedTextColor(context)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  MyAppTextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    labelText: context.tr('admin_email_label'),
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 16),
                  MyAppTextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    labelText: context.tr('admin_pass_label'),
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    showClearIcon: true,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      error,
                      style: styles.cleanSans(
                        context,
                        color: colors.getAccentColor(context),
                        size: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  MyAppFillButton(
                    onPressed: isLoading ? null : onSignIn,
                    label: context.tr('admin_login_btn'),
                    isLoading: isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Authorized Personnel Only. Strictly monitored.',
                      textAlign: TextAlign.center,
                      style: styles.cleanSans(
                        context,
                        size: 11,
                        color: colors.getMutedTextColor(context),
                      ),
                    ),
                  ),
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
