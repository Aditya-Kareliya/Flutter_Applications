import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/widgets/my_app_blurred_loader.dart';
import '../../dashboard/presentation/admin_dashboard_screen.dart';
import 'admin_login_screen.dart';
import 'admin_auth_cubit.dart';

class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<AdminAuthCubit>(),
      child: BlocBuilder<AdminAuthCubit, AdminAuthState>(
        builder: (context, state) {
          if (state is AdminLoggedIn) return const AdminDashboardScreen();
          if (state is AdminAuthenticating) {
            return const Scaffold(
              body: MyAppBlurredLoader(
                isFullScreen: true,
                message: 'Authenticating Admin Portal...',
              ),
            );
          }
          return const AdminLoginScreen();
        },
      ),
    );
  }
}

