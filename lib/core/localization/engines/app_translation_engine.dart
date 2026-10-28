abstract class AppTranslationEngine {
  Future<String> translateToGujarati(String text);
  Future<String> translateToEnglish(String text);
  void dispose();
}
