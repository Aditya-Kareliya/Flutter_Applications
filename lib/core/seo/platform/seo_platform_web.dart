import 'dart:js_interop';

@JS('setPageSeo')
external void _rawSetPageSeo(
  JSString? title,
  JSString? description,
  JSString? canonical,
  JSString? ogImage,
);

void updateBrowserSeo({
  String? title,
  String? description,
  String? canonical,
  String? ogImage,
}) {
  try {
    _rawSetPageSeo(
      title?.toJS,
      description?.toJS,
      canonical?.toJS,
      ogImage?.toJS,
    );
  } catch (_) {
    // Silently ignore if JS DOM context or function is unavailable
  }
}
