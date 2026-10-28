import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/bootstrap/firebase_bootstrap.dart';
import 'core/dependency_injection/dependency_injection.dart';
import 'core/my_app_text_style/my_app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await FirebaseBootstrap.initialize();
  await initDependencyInjection();

  unawaited(MyAppTextStyles.preloadAllFonts());
  runApp(const PavanPutraApp());
}
