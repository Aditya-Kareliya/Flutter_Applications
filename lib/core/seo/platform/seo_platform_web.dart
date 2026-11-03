// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void updateBrowserSeo({String? title, String? description, String? canonical, String? ogImage}) {
  try {
    if (js.context.hasProperty('setPageSeo')) {
      js.context.callMethod('setPageSeo', [title, description, canonical, ogImage]);
    } else if (js.context.hasProperty('document') && title != null) {
      js.context['document']['title'] = title;
    }
  } catch (_) {
    // Silently ignore if JS DOM context unavailable
  }
}

