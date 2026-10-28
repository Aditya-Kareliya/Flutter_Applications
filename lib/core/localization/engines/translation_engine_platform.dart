import 'app_translation_engine.dart';
import 'translation_engine_stub.dart'
    if (dart.library.html) 'translation_engine_web.dart'
    if (dart.library.io) 'translation_engine_io.dart';

AppTranslationEngine createPlatformTranslationEngine() => getPlatformTranslationEngine();
