import 'seo_platform_stub.dart'
    if (dart.library.html) 'seo_platform_web.dart';

void updatePlatformSeo({String? title, String? description, String? canonical, String? ogImage}) {
  updateBrowserSeo(
    title: title,
    description: description,
    canonical: canonical,
    ogImage: ogImage,
  );
}

