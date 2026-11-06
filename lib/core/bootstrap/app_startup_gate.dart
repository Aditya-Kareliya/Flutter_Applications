import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../modules/home_module/presentation/home_screen.dart';
import '../dependency_injection/dependency_injection.dart';
import '../my_app_bloc/my_app_bloc.dart';
import '../my_app_bloc/my_app_state.dart';
import '../my_app_colors/my_app_colors.dart';
import '../widgets/my_app_blurred_loader.dart';

class AppStartupGate extends StatelessWidget {
  const AppStartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAppBloc, MyAppState>(
      builder: (context, state) {
        if (state.isInitialized) {
          return const HomeScreen();
        }

        final colors = serviceLocator<MyAppColors>();
        final isGu = state.locale.languageCode == 'gu';

        return Scaffold(
          backgroundColor: colors.getBackgroundColor(context),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: colors.getBackgroundColor(context)),
              Center(
                child: MyAppBlurredLoader(
                  message: state.loadingMessage ?? (isGu ? 'સ્વાગત છે...\nમાહિતી લોડ થઈ રહી છે...' : 'Welcome...\nPlease wait a moment...'),
                  isFullScreen: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
