import 'package:get_it/get_it.dart';
import '../../utils/navigation_manager.dart';
import '../my_app_bloc/my_app_bloc.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import '../../modules/admin_module/auth/presentation/admin_auth_cubit.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initDependencyInjection() async {
  // Navigation
  serviceLocator.registerLazySingleton<NavigationManager>(
    () => NavigationManager(),
  );

  // Core Design System
  serviceLocator.registerLazySingleton<MyAppColors>(() => const MyAppColors());
  serviceLocator.registerLazySingleton<MyAppTextStyles>(
    () => MyAppTextStyles(),
  );

  // Global Application Bloc
  serviceLocator.registerLazySingleton<MyAppBloc>(() => MyAppBloc());

  // Admin Auth Cubit
  serviceLocator.registerLazySingleton<AdminAuthCubit>(() => AdminAuthCubit());
}
