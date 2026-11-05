import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/bootstrap/firebase_bootstrap.dart';
import 'core/dependency_injection/dependency_injection.dart';
import 'core/my_app_text_style/my_app_text_styles.dart';
import 'core/widgets/image/app_cached_image.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure high-performance memory image cache (200 images, 100 MB pool)
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;

  // Pre-warm local heritage brand logo assets directly into memory
  AppCachedImage.prewarm('assets/images/pavan_putra_logo.png');
  AppCachedImage.prewarm('assets/images/pavan_putra_logo.jpg');

  usePathUrlStrategy();

  await FirebaseBootstrap.initialize();
  await initDependencyInjection();

  // Await Gujarati & English font loading before runApp to completely eliminate tofu boxes on frame 0, hot reload, and hot restart
  await MyAppTextStyles.preloadAllFonts();

  runApp(const PavanPutraApp());
}
