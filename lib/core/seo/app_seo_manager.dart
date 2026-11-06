import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'platform/seo_platform.dart';

class AppSeoData {
  final String route;
  final String titleGu;
  final String titleEn;
  final String descGu;
  final String descEn;
  final String canonical;
  final String ogImage;
  final bool isNoIndex;

  const AppSeoData({
    required this.route,
    required this.titleGu,
    required this.titleEn,
    required this.descGu,
    required this.descEn,
    required this.canonical,
    this.ogImage = 'https://pavanputragarbi.web.app/og-image.png',
    this.isNoIndex = false,
  });

  String getTitle(String langCode) => langCode == 'gu' ? titleGu : titleEn;

  String getDescription(String langCode) => langCode == 'gu' ? descGu : descEn;
}

class AppSeoManager {
  AppSeoManager._();

  static final AppSeoManager instance = AppSeoManager._();

  static const String baseUrl = 'https://pavanputragarbi.web.app';
  static const String defaultOgImage = 'https://pavanputragarbi.web.app/og-image.png';

  String _currentPath = '/';
  String _currentLang = 'gu';

  static const Map<String, AppSeoData> _routesMap = {
    '/': AppSeoData(
      route: '/',
      titleGu: 'શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ — રાજકોટ | ૪૫+ વર્ષની અખંડ ભક્તિ પરંપરા',
      titleEn: 'Pavan Putra Garbi Mandal — Rajkot | Official Prachin Garbi & Navratri Heritage',
      descGu: 'ઈ.સ. ૧૯૮૯ થી રાજકોટમાં મા અંબેની અખંડ ભક્તિ સાથે ધબકતું શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ — પ્રાચીન રાસ, જીવંત વાદ્ય સંગીત, છંદ અને પરંપરાગત સંસ્કૃતિનું પવિત્ર મંચ.',
      descEn:
          'Official web portal of Shree Pavan Putra Garbi Mandal, Rajkot (Est. 1989). Celebrating authentic Prachin Garbi, traditional Raas, live acoustic folk music, and sacred Navratri devotion to Maa Ambe.',
      canonical: 'https://pavanputragarbi.web.app/',
    ),
    '/about': AppSeoData(
      route: '/about',
      titleGu: 'મંડળ પરિચય — શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ રાજકોટ | ૧૯૮૯ થી અખંડ પરંપરા',
      titleEn: 'About Us — Pavan Putra Garbi Mandal Rajkot | Sacred Heritage Since 1989',
      descGu: 'શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ રાજકોટનો ઇતિહાસ, સિદ્ધાંતો અને સાંસ્કૃતિક ઉદ્દેશ્યો. ૧૯૮૯ થી વ્યાવસાયિકતા વિના શુદ્ધ પરંપરાગત ગરબી અને મા અંબેની ઉપાસના.',
      descEn:
          'Discover the history, core values, and cultural mission of Shree Pavan Putra Garbi Mandal, Rajkot. Preserving pure Prachin Garbi and traditional Saurashtra folk heritage without commercialization.',
      canonical: 'https://pavanputragarbi.web.app/about',
    ),
    '/history': AppSeoData(
      route: '/history',
      titleGu: 'ઇતિહાસ અને સીમાચિહ્નો — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ | ચાર દાયકાની ભક્તિ યાત્રા',
      titleEn: 'History & Milestones — Pavan Putra Garbi Mandal Rajkot | 45+ Years Journey',
      descGu: '૧૯૮૯ માં પ્રથમ માટીના ગરબાથી લઈને જીવંત વાદ્ય વૃંદ, દુર્લભ છંદ સાધના અને ડિજિટલ આર્કાઇવ સુધીની શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટની સાડા ચાર દાયકાની ગૌરવપૂર્ણ યાત્રા.',
      descEn:
          'Chronicle of Shree Pavan Putra Garbi Mandal from 1989 to present: the first earthen Garbo, growth of acoustic live orchestras, preservation of medieval Gujarati chhand, and digital heritage archive.',
      canonical: 'https://pavanputragarbi.web.app/history',
    ),
    '/archive': AppSeoData(
      route: '/archive',
      titleGu: 'વાર્ષિક સંગ્રહ (આર્કાઇવ) — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ | વર્ષ-વાર સ્મૃતિઓ',
      titleEn: 'Year-Wise Navratri Archive — Pavan Putra Garbi Mandal Rajkot | Historical Records',
      descGu: 'શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટનો વાર્ષિક ડિજિટલ સંગ્રહ. વિવિધ વર્ષોના હાઇ-ડેફિનેશન ફોટોગ્રાફ્સ, વિડિઓઝ અને નવરાત્રિની અવિસ્મરણીય સ્મૃતિઓ.',
      descEn:
          'Explore the multi-decade digital archive of Pavan Putra Garbi Mandal Rajkot. Browse year-wise high-resolution photographs, videos, and sacred memories of Navratri celebrations.',
      canonical: 'https://pavanputragarbi.web.app/archive',
    ),
    '/gallery': AppSeoData(
      route: '/gallery',
      titleGu: 'ઐતિહાસિક ફોટો ગેલેરી — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ | નવરાત્રિ તસવીરો',
      titleEn: 'Photo Gallery — Pavan Putra Garbi Mandal Rajkot | Navratri Archival Photos',
      descGu: 'શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટની સત્તાવાર ફોટો ગેલેરી. નવરાત્રિની ભક્તિ, પરંપરાગત વસ્ત્રો, પ્રાચીન રાસ અને દિવ્ય મહા આરતીની હાઇ-ડેફિનેશન તસવીરો.',
      descEn:
          'High-resolution archival photographs of Shree Pavan Putra Garbi Mandal, Rajkot. View authentic traditional attire, graceful Raas footsteps, devotional deepam, and grand Maha Aarti.',
      canonical: 'https://pavanputragarbi.web.app/gallery',
    ),
    '/videos': AppSeoData(
      route: '/videos',
      titleGu: 'વિડિઓ અને લાઈવ દર્શન — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ | સત્તાવાર વિડિઓ સંગ્રહ',
      titleEn: 'Video Archive & Live Streams — Pavan Putra Garbi Mandal Rajkot | YouTube Live',
      descGu: 'શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટના સત્તાવાર એચડી વિડિઓઝ અને યુટ્યુબ લાઈવ પ્રસારણ. પ્રાચીન રાસ, જીવંત હાર્મોનિયમ-તબલા સંગીત અને નવરાત્રિની પવિત્ર રાતો.',
      descEn:
          'Watch high-definition video recordings and official YouTube live streams of Pavan Putra Garbi Mandal, Rajkot. Experience acoustic folk music, live vocals, and sacred Navratri nights.',
      canonical: 'https://pavanputragarbi.web.app/videos',
    ),
    '/blog': AppSeoData(
      route: '/blog',
      titleGu: 'સાંસ્કૃતિક લેખો અને કથાઓ — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ | ગરબીનો ઇતિહાસ',
      titleEn: 'Cultural Stories & Blog — Pavan Putra Garbi Mandal Rajkot | Navratri Heritage Essays',
      descGu: 'પ્રાચીન ગરબીનું આધ્યાત્મિક મહત્વ, માટીના કુંભની જ્યોતનું રહસ્ય અને સંતકવિ દયારામ-વલ્લભ મેવાડાના ભક્તિ સાહિત્ય પર આધારિત સાંસ્કૃતિક લેખો અને વિશ્લેષણ.',
      descEn:
          'Read insightful articles and cultural essays on the spiritual significance of Prachin Garbi, the history of Navratri in Rajkot, and the devotional poetry of medieval saint-poets.',
      canonical: 'https://pavanputragarbi.web.app/blog',
    ),
    '/contact': AppSeoData(
      route: '/contact',
      titleGu: 'સંપર્ક અને સેવા અર્પણ — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ | સરનામું, હેલ્પલાઇન અને સેવા',
      titleEn: 'Contact Us & Seva Offerings — Pavan Putra Garbi Mandal Rajkot | Address & Helpline',
      descGu: 'શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ સાથે સંપર્ક કરો. સોરઠીયાવાડી ચોક સ્થિત કાર્યાલયનું સરનામું, હેલ્પલાઇન નંબર્સ, નવરાત્રિ સમય અને સેવા અર્પણ માટે સીધા UPI વિગતો.',
      descEn:
          'Get in touch with Shree Pavan Putra Garbi Mandal, Rajkot. Find our address at Sorathiyawadi Chowk, verified helpline numbers, Navratri visiting hours, and direct UPI seva details.',
      canonical: 'https://pavanputragarbi.web.app/contact',
    ),
    '/admin': AppSeoData(
      route: '/admin',
      titleGu: 'મંડળ સંચાલન પોર્ટલ — શ્રી પવનપુત્ર ગરબી મંડળ',
      titleEn: 'Admin Portal — Shree Pavan Putra Garbi Mandal',
      descGu: 'સત્તાવાર એડમિન પોર્ટલ.',
      descEn: 'Authorized administrative portal.',
      canonical: 'https://pavanputragarbi.web.app/admin',
      isNoIndex: true,
    ),
    '/admin/login': AppSeoData(
      route: '/admin/login',
      titleGu: 'એડમિન લૉગિન — શ્રી પવનપુત્ર ગરબી મંડળ',
      titleEn: 'Admin Sign In — Shree Pavan Putra Garbi Mandal',
      descGu: 'સત્તાવાર એડમિન લૉગિન.',
      descEn: 'Authorized administrative sign in.',
      canonical: 'https://pavanputragarbi.web.app/admin/login',
      isNoIndex: true,
    ),
  };

  AppSeoData getSeoData(String path) {
    final cleanPath = path.isEmpty ? '/' : (path.startsWith('/') ? path : '/$path');

    // 1. Direct exact match
    if (_routesMap.containsKey(cleanPath)) {
      return _routesMap[cleanPath]!;
    }

    // 2. Archive sub-route: /archive/:year
    if (cleanPath.startsWith('/archive/')) {
      final year = cleanPath.split('/')[2];
      return AppSeoData(
        route: cleanPath,
        titleGu: 'નવરાત્રિ સંગ્રહ $year — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ',
        titleEn: 'Navratri Archive $year — Pavan Putra Garbi Mandal Rajkot',
        descGu: 'વર્ષ $year ના નવરાત્રિ મહોત્સવના સત્તાવાર ફોટોગ્રાફ્સ, વિડિઓઝ અને દસ્તાવેજોનો સંગ્રહ.',
        descEn: 'Official photographs, recordings, and memorable archives from the Navratri celebration of year $year.',
        canonical: '$baseUrl$cleanPath',
      );
    }

    // 3. Gallery sub-route: /gallery/:year/:album
    if (cleanPath.startsWith('/gallery/')) {
      final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();
      final year = segments.length > 1 ? segments[1] : '';
      return AppSeoData(
        route: cleanPath,
        titleGu: 'ફોટો ગેલેરી ${year.isNotEmpty ? year : ""} — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ',
        titleEn: 'Photo Gallery ${year.isNotEmpty ? year : ""} — Pavan Putra Garbi Mandal Rajkot',
        descGu: 'શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટની હાઇ-ડેફિનેશન તસવીરો અને પવિત્ર સ્મૃતિઓ.',
        descEn: 'Archival high-resolution photographs preserving traditional Gujarati Garbi and Navratri devotion in Rajkot.',
        canonical: '$baseUrl$cleanPath',
      );
    }

    // 4. Blog sub-route: /blog/:slug
    if (cleanPath.startsWith('/blog/')) {
      return AppSeoData(
        route: cleanPath,
        titleGu: 'સાંસ્કૃતિક લેખ — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ',
        titleEn: 'Cultural Article — Pavan Putra Garbi Mandal Rajkot',
        descGu: 'પ્રાચીન ગરબી અને નવરાત્રિ સંસ્કૃતિ વિશે વિશેષ લેખ અને વિશ્લેષણ.',
        descEn: 'Cultural article exploring authentic Prachin Garbi traditions and devotional literature in Rajkot.',
        canonical: '$baseUrl$cleanPath',
      );
    }

    // 5. Admin sub-route protection
    if (cleanPath.startsWith('/admin')) {
      return _routesMap['/admin']!;
    }

    // 6. Default fallback (404 or unknown)
    return AppSeoData(
      route: cleanPath,
      titleGu: 'પેજ મળ્યું નથી — શ્રી પવનપુત્ર ગરબી મંડળ રાજકોટ',
      titleEn: 'Page Not Found — Pavan Putra Garbi Mandal Rajkot',
      descGu: 'તમે શોધેલ પેજ ઉપલબ્ધ નથી.',
      descEn: 'The requested page was not found.',
      canonical: '$baseUrl/',
      isNoIndex: true,
    );
  }

  void updatePath(String path, {String? langCode}) {
    _currentPath = path;
    if (langCode != null && langCode.isNotEmpty) {
      _currentLang = langCode;
    }
    _applySeo();
  }

  void updateLanguage(String langCode) {
    if (_currentLang == langCode) return;
    _currentLang = langCode;
    _applySeo();
  }

  void _applySeo() {
    final seo = getSeoData(_currentPath);
    final title = seo.getTitle(_currentLang);
    final desc = seo.getDescription(_currentLang);

    // 1. Native / Flutter Application Switcher Tab Title
    SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(label: title, primaryColor: 0xFF570814));

    // 2. Web DOM injection (Title, Meta Description, Canonical, OG)
    updatePlatformSeo(title: title, description: desc, canonical: seo.canonical, ogImage: seo.ogImage);

    if (kDebugMode) {
      debugPrint('[AppSeoManager] Applied SEO for $_currentPath [$_currentLang]: $title');
    }
  }
}
