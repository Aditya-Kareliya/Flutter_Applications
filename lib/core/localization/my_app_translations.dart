import 'package:flutter/material.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import 'google_translation_service.dart';

class MyAppTranslations {
  final Locale locale;

  const MyAppTranslations(this.locale);

  bool get isGujarati => locale.languageCode == 'gu';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation & Branding
      'app_title': 'PAVAN PUTRA GARBI MANDAL',
      'pavan_putra_garbi_mandal': 'PAVAN PUTRA GARBI MANDAL',
      'app_short_title': 'PAVAN PUTRA',
      'app_subtitle': 'RAJKOT • GUJARAT • EST. 1977',
      'sacred_invocation': '|| ૐ નમો ભગવતે || || જાગતી જોગમાયા||',
      'nav_home': 'HOME',
      'nav_about': 'ABOUT',
      'nav_history': 'HISTORY',
      'nav_archive': 'ARCHIVE',
      'nav_gallery': 'GALLERY',
      'nav_videos': 'VIDEOS',
      'nav_blog': 'BLOG',
      'nav_contact': 'CONTACT',
      'nav_admin': 'ADMIN',
      'lang_btn': 'Gujarati',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'Device',

      // Hero Section (Preloaded in code, optionally overridden in Admin / Firestore)
      'hero_tag': 'RAJKOT  /  SAURASHTRA  /  FOLK HERITAGE',
      'hero_title': 'The Living Legacy of\nPrachin Garbi.',
      'hero_gujarati_motto': '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      'hero_description':
          'Since 1977 in Rajkot, Pavan Putra Garbi Mandal has preserved the pure, sacred spirit of authentic Gujarati Garbi — celebrating the divine feminine power of Maa Ambe through acoustic folk rhythm, classical poetry, and community devotion.',
      'hero_cta_archive': 'EXPLORE ARCHIVE',
      'hero_cta_about': 'OUR HERITAGE',
      'hero_official_badge': 'OFFICIAL CULTURAL HERITAGE ARCHIVE',
      'hero_motto_badge': 'શુદ્ધ પ્રાચીન ભક્તિ પરંપરા',

      // Quick Heritage Highlights Bar (Preloaded in code)
      'stat_years_title': '45+ Years',
      'stat_years_desc': 'Continuous heritage in Rajkot',
      'stat_music_title': '100% Prachin',
      'stat_music_desc': 'Acoustic live folk instruments',
      'stat_devotion_title': 'Maa Jagti Jogmaya',
      'stat_devotion_desc': 'Sacred deepam & daily Maha Aarti',
      'stat_archive_title': 'Digital Archive',
      'stat_archive_desc': 'Decades of photos & recordings',

      // Home Section 01: About The Mandal (Preloaded in code)
      'sec_01_tag': '01 / THE MANDAL',
      'sec_01_title': 'Preserving the Pure Essence\nof Traditional Garbi.',
      'sec_01_desc':
          'In an era of commercial sound systems and modernized music, Pavan Putra Garbi Mandal stands resolute in safeguarding the authenticity of Prachin Garbi. Every step, rhythm, and verse echoes the timeless devotion of Saurashtra.',
      'sec_01_pillar1_title': 'Pure Cultural Sanity',
      'sec_01_pillar1_desc':
          'Strictly traditional Raas, Be-Taali, Tran-Taali, and Hinch performed in reverence.',
      'sec_01_pillar2_title': 'Acoustic Folk Orchestra',
      'sec_01_pillar2_desc':
          'Harmonium, Tabla, Pakhawaj, Dholak, and Brass Cymbals played live by masters.',
      'sec_01_pillar3_title': 'Sacred Reverence',
      'sec_01_pillar3_desc':
          'Centered around the sacred clay Garbo with an eternal oil flame honoring Mataji.',

      // Home Section 02: Core Pillars of Prachin Garbi
      'sec_pillars_tag': '02 / SACRED FOUNDATIONS',
      'sec_pillars_title': 'Poetry, Rhythm & Divine Grace',
      'pillar_1_title': 'Prachin Raas & Footsteps',
      'pillar_1_desc':
          'Graceful, disciplined synchronized footsteps by devoted participants in authentic traditional Gujarati attire.',
      'pillar_2_title': 'Chhand, Duha & Saint-Poets',
      'pillar_2_desc':
          'Soulful vocal renditions of devotional verses composed by medieval Gujarati masters like Dayaram, Premanand, and Vallabh Mevada.',
      'pillar_3_title': 'Maha Aarti & Deepotsav',
      'pillar_3_desc':
          'Grand daily night Aarti with hundreds of burning oil lamps, creating an unmatched atmosphere of divinity and peace.',

      // Home Section 03: Vocalists & Live Orchestra
      'sec_singers_tag': '03 / SOULS OF THE MUSIC',
      'sec_singers_title': 'Revered Folk Vocalists & Musicians',
      'sec_singers_desc':
          'The soulful identity of Prachin Garbi lives in its live musicians. Without synthesizers or recorded tracks, their voices invoke deep spiritual emotion across all nine sacred nights.',
      'singer_1_name': 'Devotional Vocalists',
      'singer_1_role': 'Traditional Folk Chorus & Lead Chhand',
      'singer_1_desc':
          'Rendering ancient stutis, duhas, and devotional Garbis passed down through generations.',
      'singer_2_name': 'Tabla & Pakhawaj Masters',
      'singer_2_role': 'Rhythm & Taal Harmony',
      'singer_2_desc':
          'Guiding the pace from slow, graceful two-taali to high-energy Saurashtra hinch.',
      'singer_3_name': 'Harmonium & Jhanj Players',
      'singer_3_role': 'Acoustic Melody & Tempo',
      'singer_3_desc':
          'Weaving the musical tapestry that anchors every traditional Garbi night.',

      // Home Section 04: Elders & Dignitaries Blessings
      'sec_opinions_tag': '04 / WORDS OF RESPECT & GUIDANCE',
      'sec_opinions_title': 'Reflections from Elders & Cultural Guardians',
      'opinion_1_quote':
          '“In an era where original folk forms are often diluted, Pavan Putra Garbi Mandal has guarded our sacred heritage with unwavering reverence. It is a pride for Rajkot.”',
      'opinion_1_author': 'Shree Dahyabhai (Mandal Elder & Trustee)',
      'opinion_2_quote':
          '“The devotion and purity with which ancient Chhands and Raas are sung here reminds every Gujarati of our sacred roots. This is where tradition truly breathes.”',
      'opinion_2_author': 'Pandit Jigneshbhai (Folk Music Scholar)',
      'opinion_3_quote':
          '“The discipline of the participants, the warmth of the community, and the sanctity of the Mataji Aarti make this an exemplary cultural institution.”',
      'opinion_3_author': 'Community Patron & Heritage Advocate',

      // Home Section 05: Year-Wise Archive
      'sec_02_tag': '05 / YEAR-WISE ARCHIVE',
      'sec_02_title': 'Find a year.\nRelive a sacred memory.',
      'sec_02_desc':
          'Explore high-resolution photographs, video recordings, and historical chronicles spanning across multiple years.',
      'sec_02_cta': 'VIEW ALL YEARS →',
      'sec_02_media_type': 'PHOTOS • VIDEOS',

      // Home Section 06: Featured Videos & YouTube Live
      'sec_videos_tag': '06 / VIDEO HIGHLIGHTS',
      'sec_videos_title': 'Watch the Sacred Nights.\nListen to the Heritage.',
      'videos_live_badge': '● YOUTUBE STREAM',
      'videos_live_title':
          'Official YouTube Channel — Annual Garbi & Live Streams',
      'videos_live_desc':
          'Catch live streaming during Navratri nights and revisit archival performances in high definition.',
      'videos_live_cta': 'WATCH CHANNEL →',
      'videos_featured': 'FEATURED RECORDINGS',

      // Home Section 07: Blog & Cultural Stories
      'sec_blog_tag': '07 / CULTURAL STORIES & ARTICLES',
      'sec_blog_title': 'Heritage, Meaning & Reflections',
      'blog_read_more': 'READ FULL ARTICLE →',

      // Home Section 08: Cultural Invitation Banner
      'banner_motto':
          '“Preserving the ancient flame of Garbi for generations to come.”',
      'banner_cta_contact': 'CONNECT WITH MANDAL',

      // About Screen
      'about_tag': 'ABOUT THE MANDAL',
      'about_title': 'Pavan Prachin Garbi Mandal',
      'about_desc':
          'A non-profit cultural institution in Rajkot, Gujarat, steadfastly devoted to the preservation and authentic celebration of Prachin Garbi since 1977.',
      'about_history_title': 'Preserving Sacred Traditions since 1977',
      'about_history_desc':
          'Founded by devoted community elders in Rajkot, the Mandal was born out of a profound commitment: to worship Maa Jagti Jogmaya through classical Saurashtra Garbi, retaining natural live instrumentation, spiritual lyricism, and communal harmony without commercial compromises.',
      'about_values_title': 'Core Principles of the Mandal',
      'about_val_1':
          'Strict adherence to Prachin (classical) traditions without modern DJ/electronic adaptations.',
      'about_val_2':
          'Free and open participation for the local community in a sacred, family-friendly atmosphere.',
      'about_val_3':
          'Preservation of medieval Gujarati devotional poetry (Dayaram, Premanand, Vallabh Mevada).',
      'about_val_4':
          'Careful digital documentation of each year’s performances for future generations.',

      // History Screen
      'history_tag': 'CHRONOLOGY & MILESTONES',
      'history_title': 'A History of Devotion & Cultural Fortitude.',
      'history_subtitle':
          'Four and a half decades of unwavering dedication to Maa Ambe in Rajkot.',
      'history_milestone_1977_title': 'Foundation & The First Garbo',
      'history_milestone_1977_desc':
          'Commenced in Rajkot with a modest sacred clay Garba, pure oil deepams, traditional vocals, and devoted neighborhood families.',
      'history_milestone_1990_title': 'Live Acoustic Orchestra & Stage Growth',
      'history_milestone_1990_desc':
          'Formalized a dedicated live orchestra with harmonium and tabla masters, expanding traditional raas repertoire while maintaining strict cultural sanctity.',
      'history_milestone_2005_title': 'Community Recognition Across Saurashtra',
      'history_milestone_2005_desc':
          'Honored by cultural historians and regional patrons as an exemplary beacon of Prachin Garbi in Gujarat.',
      'history_milestone_2018_title': 'Preservation of Classical Chhand & Duha',
      'history_milestone_2018_desc':
          'Introduced structured archival documentation and workshops to ensure young vocalists learn rare medieval Gujarati chhand styles.',
      'history_milestone_now_title': 'A Living Digital Heritage Archive',
      'history_milestone_now_desc':
          'Launch of this comprehensive digital home, preserving high-definition photography, video archives, and historical articles for the worldwide Gujarati diaspora.',

      // Archive Screen
      'archive_tag': 'ARCHIVE REPOSITORY',
      'archive_title': 'Years of Garbi,\nKept for Eternity.',
      'archive_desc':
          'Select any year to explore its official photographs, recordings, and memorable highlights.',
      'albums_tag': 'OFFICIAL ALBUMS',
      'album_main_garbi': 'MAIN PRACHIN GARBI',
      'album_ras': 'TRADITIONAL RAAS & DANDIYA',
      'album_special': 'MAHA AARTI & SACRED MOMENTS',
      'official_media': 'OFFICIAL ARCHIVAL MEDIA',
      'view_album_btn': 'VIEW ALBUM PHOTOS',
      'archive_empty': 'No albums or media available for this selection.',
      'archive_empty_title': 'No Archives Found',
      'archive_empty_desc': 'New albums and recordings for this festival year will be uploaded soon. Please check back later.',

      // Gallery Screen
      'gallery_tag': 'PHOTOGRAPHIC REPOSITORY',
      'gallery_title': 'Archival Photographs',
      'gallery_desc':
          'Captured moments of devotion, vibrant traditional attire, and sacred Navratri nights.',
      'filter_all': 'ALL PHOTOGRAPHS',
      'filter_day1': 'NAVRATRI DAYS 1-3',
      'filter_day2': 'NAVRATRI DAYS 4-6',
      'filter_day3': 'MAHA AARTI & DUSSEHRA',
      'photo_viewer_title': 'OFFICIAL ARCHIVAL PHOTOGRAPH',
      'photo_viewer_desc':
          'Preserved in high resolution by Pavan Putra Garbi Mandal, Rajkot.',

      // Videos Screen
      'videos_tag': 'AUDIO-VISUAL ARCHIVE',
      'videos_title': 'Watch the Sacred Nights.\nHear the Timeless Rhythms.',
      'videos_desc':
          'High-definition recordings capturing the authentic music, footsteps, and devotional fervor.',
      'video_1_title': 'Pavan Putra Garbi — Maha Aarti & Chhand',
      'video_2_title': 'Traditional 2-Taali & 3-Taali Raas',
      'video_3_title': 'Ancient Garbi Singing with Live Harmonium & Tabla',
      'video_4_title': 'Kumkum Pagla & Sacred Deepam Procession',
      'video_5_title': 'Saurashtra Hinch & Devotional Finale',
      'video_6_title': 'Historical Moments & Elders’ Recollections',

      // Blog Screen
      'blog_tag': 'ESSAYS & ARTICLES',
      'blog_title': 'Sacred Stories, Folklore & Updates',
      'blog_desc':
          'Deep dives into the spiritual significance, musical structures, and historical context of Prachin Garbi.',
      'blog_1_title':
          'The Spiritual Difference Between Prachin Garbi and Modern Garba',
      'blog_1_snippet':
          'Why the traditional clay pot with its internal light represents the cosmic womb and eternal spirit of the Divine Mother.',
      'blog_2_title':
          'The Legacy of Saint-Poet Dayaram and Vallabh Mevada in Garbi',
      'blog_2_snippet':
          'How medieval devotional literature gave birth to the melodic structures sung each night across Gujarat.',
      'blog_3_title': 'Rajkot: The Cultural Heartland of Devotional Navratri',
      'blog_3_snippet':
          'Tracing how neighborhood Mandals have kept Saurashtra’s authentic spirit vibrant for over a century.',

      // Contact Screen
      'contact_tag': 'GET IN TOUCH',
      'contact_title': 'Contact the Mandal.',
      'contact_desc':
          'Reach out for inquiries about archive media, cultural visits during Navratri, or Mandal participation.',
      'contact_info_title': 'Mandal Headquarters',
      'contact_address_label': 'Location',
      'contact_address': 'Pavan Putra Chowk, Rajkot, Gujarat 360001, India',
      'contact_email_label': 'Email',
      'contact_email': 'info@pavanputragarbi.org',
      'contact_phone_label': 'Helpline',
      'contact_phone': '+91 98250 12345 / +91 94280 67890',
      'contact_whatsapp_label': 'WhatsApp Helpline',
      'tooltip_call': 'Call Helpline',
      'tooltip_whatsapp': 'Chat on WhatsApp',
      'tooltip_email': 'Send Email',
      'tooltip_maps': 'Open in Google Maps',
      'contact_hours_label': 'Navratri Hours',
      'contact_hours': 'Daily: 8:00 PM to 12:30 AM (During Navratri Festival)',
      'contact_form_title': 'Send a Devotional Message or Inquiry',
      'form_name': 'Your Full Name',
      'form_phone': 'Mobile Number',
      'form_email': 'Email Address',
      'form_message': 'Your Message / Inquiry',
      'form_message_hint': 'Write your message, blessings, or seva inquiry...',
      'form_submit': 'SEND MESSAGE',
      'form_success':
          'Thank you! Your message has been received by the Mandal committee.',

      // Devotional Offerings & QR Payments
      'payment_title': 'Devotional Offerings / Garbi Seva & Dan',
      'payment_subtitle': 'Scan with Google Pay, PhonePe, Paytm, or BHIM UPI',
      'payment_badge': 'UPI VERIFIED • 100% DIRECT SEVA',
      'payment_beneficiary_label': 'VERIFIED MANDAL BENEFICIARY',
      'payment_upi_label': 'DIRECT UPI ID',
      'payment_copy_btn': 'Copy UPI',
      'payment_copied_toast': 'UPI ID Copied',
      'payment_copied_desc': 'copied to clipboard.',
      'payment_accepted_apps': 'ACCEPTED VIA ANY UPI APP:',
      'payment_tap_enlarge': 'Tap to enlarge QR code',
      'payment_modal_title': 'Devotional Offering QR Code',
      'payment_pledge':
          '100% of devotional contributions directly support Shree Pavan Putra Garbi Mandal activities, daily aarti, and traditional Navratri arrangements. No third-party deductions.',
      'payment_done_btn': 'Done',

      // Admin Module
      'admin_title': 'Mandal Administration Portal',
      'admin_subtitle':
          'Secure management for media archives, years, and official announcements.',
      'admin_email_label': 'Administrator Email',
      'admin_pass_label': 'Password',
      'admin_login_btn': 'SIGN IN TO DASHBOARD',

      // Home Call to Action
      'home_cta_invocation': '|| Jagti Jogmaya ||',
      'home_cta_motto':
          'Connect with our sacred tradition and feel the divine presence of Maa Ambe.',
      'home_cta_btn_text': 'Connect With Us',

      // Footer (Preloaded in code, optionally overridden in Admin / Firestore)
      'footer_tagline':
          'Preserving authentic Gujarati folk music, poetry, and cultural traditions in Rajkot since 1977.',
      'footer_location': 'Pavan Putra Chowk, Bhaktinagar, Rajkot - 360002, Gujarat',
      'footer_motto': '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      'footer_links_title': 'QUICK EXPLORE',
      'footer_links2_title': 'CULTURAL RESOURCES',
      'footer_social': 'CONNECT & BLESSINGS',
      'footer_copyright': '© 1977 - 2026 Shree Pavan Putra Garbi Mandal, Rajkot. All rights reserved.',

      // Loader & Common
      'loading_switching_lang': 'Switching language...',
      'loading_wait': 'Please wait a moment...',
      'refresh_loading': 'Updating data...',
      'empty_state_title': 'No items currently available',
      'empty_state_desc':
          'Content will appear here as soon as published by the Mandal archive team.',
      'retry_btn': 'RETRY',
      'close_btn': 'CLOSE',
      'official_photo_label': 'OFFICIAL MANDAL ARCHIVE',
    },
    'gu': {
      // Navigation & Branding
      'app_title': 'શ્રી પવનપુત્ર ગરબી મંડળ',
      'pavan_putra_garbi_mandal': 'શ્રી પવનપુત્ર ગરબી મંડળ',
      'app_short_title': 'પવનપુત્ર ગરબી મંડળ',
      'app_subtitle': 'રાજકોટ • ગુજરાત • સ્થાપના ૧૯૭૭',
      'sacred_invocation': '|| ૐ નમો ભગવતે || || જાગતી જોગમાયા||',
      'nav_home': 'હોમ',
      'nav_about': 'પરિચય',
      'nav_history': 'ઇતિહાસ',
      'nav_archive': 'સંગ્રહ',
      'nav_gallery': 'ગેલેરી',
      'nav_videos': 'વિડિઓઝ',
      'nav_blog': 'લેખો',
      'nav_contact': 'સંપર્ક',
      'nav_admin': 'એડમિન',
      'lang_btn': 'અંગ્રેજી',
      'theme_light': 'લાઇટ',
      'theme_dark': 'ડાર્ક',
      'theme_system': 'સિસ્ટમ',

      // Hero Section (Preloaded in code, optionally overridden in Admin / Firestore)
      'hero_tag': 'રાજકોટ  /  સૌરાષ્ટ્ર  /  લોક સંસ્કૃતિ',
      'hero_title': 'પ્રાચીન ગરબીનો અમર વારસો,\nભક્તિ અને સૂરની સાધના.',
      'hero_gujarati_motto': '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      'hero_description':
          'ઈ.સ. ૧૯૭૭ થી રાજકોટમાં મા અંબેની અખંડ ભક્તિ સાથે ધબકતું શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ — પ્રાચીન રાસ, જીવંત વાદ્ય-સંગીત, છંદ અને પરંપરાગત સંસ્કૃતિનું પવિત્ર મંચ.',
      'hero_cta_archive': 'વાર્ષિક સંગ્રહ જુઓ',
      'hero_cta_about': 'મંડળ વિશે જાણો',
      'hero_official_badge': 'સત્તાવાર સાંસ્કૃતિક સંગ્રહ',
      'hero_motto_badge': 'શુદ્ધ પ્રાચીન ભક્તિ પરંપરા',

      // Quick Heritage Highlights Bar (Preloaded in code)
      'stat_years_title': '૪૫+ વર્ષ',
      'stat_years_desc': 'રાજકોટમાં અખંડ પરંપરા',
      'stat_music_title': '૧૦૦% પ્રાચીન',
      'stat_music_desc': 'જીવંત સૂર અને લોકવાદ્યો',
      'stat_devotion_title': 'જગતી જોગમાયા',
      'stat_devotion_desc': 'અખંડ દીપ અને મહા આરતી',
      'stat_archive_title': 'ડિજિટલ સંગ્રહ',
      'stat_archive_desc': 'દાયકાઓની દુર્લભ સ્મૃતિઓ',

      // Home Section 01: About The Mandal (Preloaded in code)
      'sec_01_tag': '૦૧ / ગરબી મંડળ પરિચય',
      'sec_01_title': 'આધુનિકતા વચ્ચે સચવાયેલ\nશુદ્ધ પ્રાચીન ગરબીની ધરોહર.',
      'sec_01_desc':
          'કોઈપણ વ્યાવસાયિક સંગીત કે ડીજે વિના, મા અંબેના સાન્નિધ્યમાં પ્રાચીન ગરબા, છંદ, દુહા અને સ્તુતિના પવિત્ર સૂર રેલાવીને રાજકોટમાં સંસ્કૃતિનું જતન કરતું અગ્રણી મંડળ.',
      'sec_01_pillar1_title': 'સાંસ્કૃતિક શુદ્ધતા',
      'sec_01_pillar1_desc':
          'માત્ર શુદ્ધ પ્રાચીન રાસ, બે તાલી, ત્રણ તાલી અને પરંપરાગત સૌરાષ્ટ્ર હીંચ.',
      'sec_01_pillar2_title': 'જીવંત વાદ્ય સંગીત',
      'sec_01_pillar2_desc':
          'હાર્મોનિયમ, તબલા, પખવાજ, ઢોલક અને ઝાંઝના મૂળભૂત પ્રાચીન સૂર.',
      'sec_01_pillar3_title': 'સાત્વિક ઉપાસના',
      'sec_01_pillar3_desc':
          'માટીના કુંભમાં અખંડ જ્યોત સાક્ષી રાખીને માતાજીની શ્રદ્ધાપૂર્વક આરાધના.',

      // Home Section 02: Core Pillars of Prachin Garbi
      'sec_pillars_tag': '૦૨ / પ્રાચીન ગરબીના આધારસ્તંભ',
      'sec_pillars_title': 'સૂર, સાહિત્ય અને સાધનાનો ત્રિવેણી સંગમ',
      'pillar_1_title': 'પ્રાચીન રાસ અને કલા',
      'pillar_1_desc':
          'ગુજરાતના પરંપરાગત વસ્ત્રોમાં શિસ્તબદ્ધ અને લયબદ્ધ પગલાં સાથે માતાજીની પરિક્રમા કરતો રાસ.',
      'pillar_2_title': 'છંદ, દુહા અને કવિઓની રચનાઓ',
      'pillar_2_desc':
          'ભક્તકવિ દયારામ, પ્રેમાનંદ અને વલ્લભ મેવાડાના અમર ભક્તિપદોનું ભાવપૂર્વક ગાન.',
      'pillar_3_title': 'મહા આરતી અને દીપોત્સવ',
      'pillar_3_desc':
          'દરરોજ રાત્રે થતી અલૌકિક મહા આરતી, જ્યાં સેંકડો દીવડાઓથી માતાજીનું પ્રાંગણ ઝળહળી ઊઠે છે.',

      // Home Section 03: Vocalists & Live Orchestra
      'sec_singers_tag': '૦૩ / સૂર સાધકો અને વાદ્ય વૃંદ',
      'sec_singers_title': 'જેમના કંઠેથી ગૂંજે છે ભક્તિના અમર બોલ',
      'sec_singers_desc':
          'પ્રાચીન ગરબીનો આત્મા તેના જીવંત ગાયકો અને વાદકોમાં વસે છે. કોઈપણ કૃત્રિમ સંગીત વિના શુદ્ધ સૂર-તાલથી શ્રોતાઓને ભાવવિભોર કરે છે.',
      'singer_1_name': 'ભક્તિમય ગાયક વૃંદ',
      'singer_1_role': 'મુખ્ય છંદ અને પ્રાચીન ગરબી ગાયન',
      'singer_1_desc':
          'પેઢી દર પેઢી ઉતરી આવેલી પ્રાચીન સ્તુતિઓ અને માતાજીના છંદોનું જીવંત ગાન.',
      'singer_2_name': 'તબલા અને પખવાજ વાદક',
      'singer_2_role': 'તાલ અને લય સાધના',
      'singer_2_desc':
          'ધીમી બે તાલીથી લઈને જોમવંતી સૌરાષ્ટ્ર હીંચ સુધી તાલની અવિરત સરવાણી.',
      'singer_3_name': 'હાર્મોનિયમ અને ઝાંઝ વાદક',
      'singer_3_role': 'મધુર સૂર અને ગતિ નિયંત્રણ',
      'singer_3_desc':
          'પરંપરાગત વાદ્યોના સમન્વયથી ગરબીના વાતાવરણને દિવ્ય બનાવતા કલાકારો.',

      // Home Section 04: Elders & Dignitaries Blessings
      'sec_opinions_tag': '૦૪ / વડીલો અને મહાનુભાવોના વિચાર',
      'sec_opinions_title': 'પ્રાચીન ગરબીના સંવર્ધન વિશે મહાનુભાવોનું મંતવ્ય',
      'opinion_1_quote':
          '“આજના ફાસ્ટ યુગમાં પણ પવનપુત્ર ગરબી મંડળે પ્રાચીન પરંપરાને અખંડ રાખીને આપણી સાચી ધરોહર સાચવી રાખી છે. રાજકોટ માટે આ ગૌરવની વાત છે.”',
      'opinion_1_author': 'શ્રી ડાહ્યાભાઈ (વડીલ માર્ગદર્શક અને ટ્રસ્ટી)',
      'opinion_2_quote':
          '“મા અંબેના પ્રાચીન છંદ અને રાસ જે શુદ્ધ ભાવ સાથે અહીં ગવાય છે તે સમગ્ર સૌરાષ્ટ્રની સાંસ્કૃતિક ગરિમા વધારે છે.”',
      'opinion_2_author': 'પંડિત જીગ્નેશભાઈ (લોકસંગીત સંશોધક)',
      'opinion_3_quote':
          '“ખેલૈયાઓની શિસ્ત, મંડળનું સમર્પણ અને માતાજીની આરતીનું પાવન દ્રશ્ય અહી આવીને જ અનુભવી શકાય છે.”',
      'opinion_3_author': 'શુભેચ્છક અને સાંસ્કૃતિક પ્રેમી',

      // Home Section 05: Year-Wise Archive
      'sec_02_tag': '૦૫ / વાર્ષિક સંગ્રહ',
      'sec_02_title': 'વર્ષ શોધો.\nસ્મૃતિઓ માણો.',
      'sec_02_desc':
          'વાર્ષિક નવરાત્રિ મહોત્સવના હાઇ-ડેફિનેશન ફોટોગ્રાફ્સ, વિડિઓઝ અને દસ્તાવેજોનો સંગ્રહ.',
      'sec_02_cta': 'બધા વર્ષો જુઓ →',
      'sec_02_media_type': 'ફોટોગ્રાફ્સ • વિડિઓઝ',

      // Home Section 06: Featured Videos & YouTube Live
      'sec_videos_tag': '૦૬ / વિડિઓ અને લાઈવ દર્શન',
      'sec_videos_title': 'ગરબીની રાતો જુઓ.\nપવિત્ર સૂર માણો.',
      'videos_live_badge': '● યુટ્યુબ લાઈવ',
      'videos_live_title': 'સત્તાવાર યુટ્યુબ ચેનલ — નવરાત્રિ લાઈવ પ્રસારણ',
      'videos_live_desc':
          'નવરાત્રિની દરેક રાતે ગરબીનું જીવંત પ્રસારણ અને અગાઉના વર્ષોના ઐતિહાસિક વિડિઓઝ.',
      'videos_live_cta': 'ચેનલ જુઓ →',
      'videos_featured': 'ખાસ વિડિઓ સંગ્રહ',

      // Home Section 07: Blog & Cultural Stories
      'sec_blog_tag': '૦૭ / લેખો અને સાંસ્કૃતિક વાર્તાઓ',
      'sec_blog_title': 'ગરબીનો ઇતિહાસ અને સાંસ્કૃતિક મહત્વ',
      'blog_read_more': 'સંપૂર્ણ લેખ વાંચો →',

      // Home Section 08: Cultural Invitation Banner
      'banner_motto':
          '“ગરબીની પવિત્ર જ્યોતને આવનારી પેઢીઓ સુધી અખંડ રાખવાનો નમ્ર પ્રયાસ.”',
      'banner_cta_contact': 'મંડળનો સંપર્ક કરો',

      // About Screen
      'about_tag': 'મંડળ પરિચય',
      'about_title': 'શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ',
      'about_desc':
          'રાજકોટમાં ઈ.સ. ૧૯૭૭ થી કાર્યરત, પ્રાચીન ગરબી અને મા અંબેની આરાધનાને સમર્પિત એક બિન-વ્યાવસાયિક સાંસ્કૃતિક સંસ્થા.',
      'about_history_title': '૧૯૭૭ થી અવિરત ધબકતી ગરબી પરંપરા',
      'about_history_desc':
          'રાજકોટના શ્રદ્ધાળુ વડીલો દ્વારા સ્થાપિત આ મંડળનો મુખ્ય ઉદ્દેશ્ય માતાજીની ઉપાસનાને શુદ્ધ લોકઢાળ, જીવંત સંગીત અને સામુદાયિક ભાવના સાથે ઉજવવાનો છે.',
      'about_values_title': 'મંડળના પાયાના સિદ્ધાંતો',
      'about_val_1':
          'કોઈપણ આધુનિક વિકૃતિ કે ડીજે સંગીત વગર માત્ર શુદ્ધ પ્રાચીન ગરબી.',
      'about_val_2':
          'સમાજના તમામ વર્ગો માટે પવિત્ર અને પારિવારિક વાતાવરણમાં મુક્ત પ્રવેશ.',
      'about_val_3':
          'દયારામ, પ્રેમાનંદ, વલ્લભ મેવાડા જેવા સંતકવિઓની રચનાઓનું જતન.',
      'about_val_4':
          'આવનારી પેઢીઓ માટે દરેક વર્ષની સ્મૃતિઓનું સુરક્ષિત ડિજિટલ દસ્તાવેજીકરણ.',

      // History Screen
      'history_tag': 'ઇતિહાસ અને સીમાચિહ્નો',
      'history_title': 'ભક્તિ અને સમર્પણની ભવ્ય યાત્રા.',
      'history_subtitle':
          'રાજકોટમાં સાડા ચાર દાયકાથી ગૂંજતી પ્રાચીન ગરબીની પાવન ગાથા.',
      'history_milestone_1977_title': 'સ્થાપના અને પ્રથમ ગરબો',
      'history_milestone_1977_desc':
          'રાજકોટમાં માટીના પવિત્ર ગરબા, તેલના દીવા અને મહોલ્લાના પરિવારોની શ્રદ્ધા સાથે પ્રારંભ.',
      'history_milestone_1990_title': 'જીવંત વાદ્ય વૃંદ અને મંચ વિસ્તાર',
      'history_milestone_1990_desc':
          'હાર્મોનિયમ અને તબલાના અનુભવી ઉસ્તાદો સાથે પ્રાચીન રાસનું વ્યવસ્થિત સંચાલન શરૂ થયું.',
      'history_milestone_2005_title': 'સૌરાષ્ટ્રભરમાં સાંસ્કૃતિક સ્વીકૃતિ',
      'history_milestone_2005_desc':
          'લોકસંગીતના વિદ્વાનો અને અગ્રણીઓ દ્વારા પ્રાચીન સંસ્કૃતિના સાચા રક્ષક તરીકે સન્માન.',
      'history_milestone_2018_title': 'છંદ અને દુહા સંવર્ધન અભિયાન',
      'history_milestone_2018_desc':
          'નવી પેઢીના ગાયકો દુર્લભ પ્રાચીન છંદો શીખે તે માટે વિશેષ માર્ગદર્શન અને સંગ્રહ.',
      'history_milestone_now_title': 'જીવંત ડિજિટલ સંગ્રહ સ્થાન',
      'history_milestone_now_desc':
          'વિશ્વભરના ગુજરાતીઓ માટે હાઇ-ડેફિનેશન ફોટો, વિડિઓ અને લેખો સાથે આ ડિજિટલ આર્કાઇવનું નિર્માણ.',

      // Archive Screen
      'archive_tag': 'વાર્ષિક સંગ્રહ',
      'archive_title': 'ગરબીના વર્ષો,\nસદા માટે સચવાયેલા.',
      'archive_desc':
          'કોઈપણ વર્ષ પસંદ કરી તેના સત્તાવાર ફોટોગ્રાફ્સ, વિડિઓઝ અને સ્મૃતિઓ નિહાળો.',
      'albums_tag': 'સત્તાવાર આલ્બમ્સ',
      'album_main_garbi': 'મુખ્ય પ્રાચીન ગરબી',
      'album_ras': 'પરંપરાગત રાસ અને દાંડિયા',
      'album_special': 'મહા આરતી અને દિવ્ય ક્ષણો',
      'official_media': 'સત્તાવાર મીડિયા સંગ્રહ',
      'view_album_btn': 'આલ્બમના ફોટા જુઓ',
      'archive_empty': 'આ સંગ્રહ માટે હાલ કોઈ તસવીરો કે આલ્બમ ઉપલબ્ધ નથી.',
      'archive_empty_title': 'કોઈ આલ્બમ મળ્યા નથી',
      'archive_empty_desc': 'આ વર્ષ માટેના નવા આલ્બમ અને વિડિઓ ટૂંક સમયમાં ઉમેરવામાં આવશે. કૃપા કરીને થોડી વાર પછી ફરી જુઓ.',

      // Gallery Screen
      'gallery_tag': 'ફોટોગ્રાફ્સ સંગ્રહ',
      'gallery_title': 'ઐતિહાસિક ફોટોગ્રાફ્સ',
      'gallery_desc':
          'નવરાત્રિની ભક્તિ, પરંપરાગત પોશાક અને ગરબીની રમઝટની અમૂલ્ય તસવીરો.',
      'filter_all': 'બધા ફોટોગ્રાફ્સ',
      'filter_day1': 'નોરતા ૧ થી ૩',
      'filter_day2': 'નોરતા ૪ થી ૬',
      'filter_day3': 'મહા આરતી અને દશેરા',
      'photo_viewer_title': 'સત્તાવાર આર્કાઇવ ફોટોગ્રાફ',
      'photo_viewer_desc': 'શ્રી પવનપુત્ર ગરબી મંડળ, રાજકોટ દ્વારા સંરક્ષિત.',

      // Videos Screen
      'videos_tag': 'વિડિઓ સંગ્રહ',
      'videos_title': 'ગરબીની રાતો જુઓ.\nઅમર સૂર-તાલ માણો.',
      'videos_desc':
          'પ્રાચીન રાસ, સંગીત અને ભક્તિભાવનું જીવંત હાઇ-ડેફિનેશન રેકોર્ડિંગ.',
      'video_1_title': 'પવનપુત્ર ગરબી — મહા આરતી અને પ્રાચીન છંદ',
      'video_2_title': 'પરંપરાગત ૨-તાલી અને ૩-તાલી રાસ રમઝટ',
      'video_3_title': 'હાર્મોનિયમ અને તબલા સાથે પ્રાચીન ગરબી ગાયન',
      'video_4_title': 'કુમકુમ પગલાં અને પવિત્ર દીપ પ્રદક્ષિણા',
      'video_5_title': 'સૌરાષ્ટ્રની પ્રખ્યાત હીંચ અને ભક્તિ સંગમ',
      'video_6_title': 'વડીલોના સંસ્મરણો અને ગરબીનો ઇતિહાસ',

      // Blog Screen
      'blog_tag': 'લેખો અને કથાઓ',
      'blog_title': 'સાંસ્કૃતિક કથાઓ અને લેખો',
      'blog_desc':
          'પ્રાચીન ગરબીનું આધ્યાત્મિક રહસ્ય, લોકસાહિત્ય અને પરંપરાગત વારસાનું ઊંડાણપૂર્વક ચિંતન.',
      'blog_1_title': 'પ્રાચીન ગરબી અને અર્વાચીન ગરબા વચ્ચેનો આધ્યાત્મિક ભેદ',
      'blog_1_snippet':
          'માટીના કુંભમાં પ્રગટતો દીવો બ્રહ્માંડ અને જગદંબાની જ્યોતનું પ્રતીક કેવી રીતે છે?',
      'blog_2_title':
          'ગરબી સાહિત્યમાં ભક્તકવિ દયારામ અને વલ્લભ મેવાડાનું પ્રદાન',
      'blog_2_snippet':
          'મધ્યકાલીન ભક્તિ સાહિત્ય દ્વારા ગુજરાતના લોકજીવનમાં ગરબી કેવી રીતે વણાઈ ગઈ?',
      'blog_3_title': 'રાજકોટ: નવરાત્રિની પ્રાચીન ગરબીઓનું ધબકતું કેન્દ્ર',
      'blog_3_snippet':
          'એક સદીથી વધુ સમયથી સૌરાષ્ટ્રના ચોકમાં સચવાયેલી પ્રાચીન પરંપરાઓની ઝાંખી.',

      // Contact Screen
      'contact_tag': 'સંપર્ક કરો',
      'contact_title': 'મંડળ સાથે સંપર્ક.',
      'contact_desc':
          'સંગ્રહ મીડિયા, નવરાત્રિ દર્શન અથવા મંડળ સહયોગ માટે અમારો સંપર્ક કરો.',
      'contact_info_title': 'મંડળ કાર્યાલય',
      'contact_address_label': 'સરનામું',
      'contact_address': 'પવનપુત્ર ચોક, રાજકોટ, ગુજરાત ૩૬૦૦૦૧, ભારત',
      'contact_email_label': 'ઈમેઇલ',
      'contact_email': 'info@pavanputragarbi.org',
      'contact_phone_label': 'હેલ્પલાઇન નંબર',
      'contact_phone': '+91 98250 12345 / +91 94280 67890',
      'contact_whatsapp_label': 'વોટ્સએપ હેલ્પલાઇન',
      'tooltip_call': 'હેલ્પલાઇન પર કૉલ કરો',
      'tooltip_whatsapp': 'વોટ્સએપ પર વાત કરો',
      'tooltip_email': 'ઈમેઇલ મોકલો',
      'tooltip_maps': 'ગૂગલ મેપ્સમાં સરનામું જુઓ',
      'contact_hours_label': 'નવરાત્રિ સમય',
      'contact_hours': 'દરરોજ: રાત્રે ૮:૦૦ થી ૧૨:૩૦ (નવરાત્રિ મહોત્સવ દરમિયાન)',
      'contact_form_title': 'ભાવપૂર્વક સંદેશ અથવા પૂછપરછ મોકલો',
      'form_name': 'તમારું પૂરું નામ',
      'form_phone': 'મોબાઇલ નંબર',
      'form_email': 'ઈમેઇલ એડ્રેસ',
      'form_message': 'તમારો સંદેશ / વિગત',
      'form_message_hint': 'તમારો સંદેશ, આશીર્વાદ અથવા સેવા પૂછપરછ લખો...',
      'form_submit': 'સંદેશ મોકલો',
      'form_success': 'આભાર! તમારો સંદેશ મંડળ સમિતિને સફળતાપૂર્વક મળી ગયો છે.',

      // Devotional Offerings & QR Payments
      'payment_title': 'ભાવપૂર્વક અર્પણ / ગરબી સેવા અને દાન',
      'payment_subtitle':
          'Google Pay, PhonePe, Paytm અથવા BHIM UPI દ્વારા સ્કેન કરો',
      'payment_badge': 'UPI વેરિફાઇડ • ૧૦૦% સીધી સેવા',
      'payment_beneficiary_label': 'પ્રમાણિત મંડળ લાભાર્થી',
      'payment_upi_label': 'સીધો UPI આઈડી',
      'payment_copy_btn': 'UPI કૉપિ',
      'payment_copied_toast': 'UPI આઈડી કૉપિ થયો',
      'payment_copied_desc': 'ક્લિપબોર્ડ પર કૉપિ થઈ ગયો છે.',
      'payment_accepted_apps': 'કોઈપણ UPI એપ દ્વારા સ્વીકાર્ય:',
      'payment_tap_enlarge': 'QR કોડ મોટો કરવા ક્લિક કરો',
      'payment_modal_title': 'સેવા અર્પણ QR કોડ',
      'payment_pledge':
          '૧૦૦% ભક્તિભાવપૂર્ણ યોગદાન સીધું શ્રી પવનપુત્ર ગરબી મંડળની પ્રવૃત્તિઓ, દૈનિક આરતી અને નવરાત્રિ મહોત્સવના આયોજન માટે જ વપરાય છે. કોઈ વચેટિયા નથી.',
      'payment_done_btn': 'પૂર્ણ',

      // Admin Module
      'admin_title': 'મંડળ સંચાલન પોર્ટલ',
      'admin_subtitle':
          'વાર્ષિક આર્કાઇવ્સ, મીડિયા અને સત્તાવાર જાહેરાતોનું સંચાલન.',
      'admin_email_label': 'એડમિન ઈમેઇલ',
      'admin_pass_label': 'પાસવર્ડ',
      'admin_login_btn': 'લૉગિન કરો',

      // Home Call to Action
      'home_cta_invocation': '|| જાગતી જોગમાયા ||',
      'home_cta_motto':
          'આપણી પ્રાચીન સંસ્કૃતિ, પરંપરા અને ભક્તિ સાથે જોડાઓ અને માં અંબાના આશીર્વાદ પ્રાપ્ત કરો.',
      'home_cta_btn_text': 'સંપર્ક કરો / સહભાગી બનો',

      // Footer (Preloaded in code, optionally overridden in Admin / Firestore)
      'footer_tagline':
          'રાજકોટમાં ૧૯૭૭થી પરંપરાગત ગુજરાતી લોકસંગીત, પ્રાચીન કાવ્ય અને ભક્તિમય સંસ્કૃતિનું અવિરત જતન.',
      'footer_location': 'પવનપુત્ર ચોક, ભક્તિનગર, રાજકોટ - ૩૬૦૦૦૨, ગુજરાત',
      'footer_motto': '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      'footer_links_title': 'ઝડપી નેવિગેશન',
      'footer_links2_title': 'સાંસ્કૃતિક સ્ત્રોત',
      'footer_social': 'જોડાઓ અને આશીર્વાદ મેળવો',
      'footer_copyright': '© ૧૯૭૭ - ૨૦૨૬ શ્રી પવનપુત્ર ગરબી મંડળ, રાજકોટ. સર્વાધિકાર સુરક્ષિત.',

      // Loader & Common
      'loading_switching_lang': 'ગુજરાતી ભાષા લોડ થઈ રહી છે...',
      'loading_wait': 'કૃપા કરી થોડી રાહ જુઓ...',
      'refresh_loading': 'માહિતી અપડેટ થઈ રહી છે...',
      'empty_state_title': 'હાલ કોઈ માહિતી ઉપલબ્ધ નથી',
      'empty_state_desc': 'મંડળ દ્વારા વિગતો અપલોડ થતાં જ અહીં દર્શાવાશે.',
      'retry_btn': 'ફરી પ્રયાસ કરો',
      'close_btn': 'બંધ કરો',
      'official_photo_label': 'સત્તાવાર મંડળ આર્કાઇવ',
    },
  };

  /// Get preloaded text directly from code dictionary
  static String getPreloaded(String key, [String langCode = 'gu']) {
    final map = _localizedValues[langCode];
    if (map != null && map.containsKey(key)) {
      final val = map[key];
      if (val != null && val.trim().isNotEmpty) {
        return val.trim();
      }
    }
    if (langCode != 'en') {
      final enVal = _localizedValues['en']?[key];
      if (enVal != null && enVal.trim().isNotEmpty) {
        return enVal.trim();
      }
    }
    return '';
  }

  String translate(String key) {
    final langCode = locale.languageCode;

    // 1. Dynamic override from AdminDataStore (CMS & Firestore)
    final dynamicOverride = AdminDataStore.instance.getTextOverride(langCode, key);
    if (dynamicOverride != null && dynamicOverride.trim().isNotEmpty) {
      return dynamicOverride.trim();
    }

    // 2. Predefined translation dictionary in code (Preloaded)
    final val = _localizedValues[langCode]?[key];
    if (val != null && val.trim().isNotEmpty) {
      return val.trim();
    }

    // 3. Dynamic Google MLKit / Cloud Translation integration when in Gujarati mode
    if (isGujarati) {
      final enVal = _localizedValues['en']?[key] ?? key;
      final cached = GoogleTranslationService.instance.getCached(enVal) ??
          GoogleTranslationService.instance.getCached(key);
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }

      // Schedule background translation so subsequent renders/screens have it
      GoogleTranslationService.instance.translateToGujarati(enVal);
      return enVal;
    }

    // 4. Default English mode (preserves cultural mixup)
    return _localizedValues['en']?[key] ?? key;
  }

  /// Translate arbitrary dynamic text (e.g. blog titles, photo names, live stream announcements)
  String translateDynamic(String text) {
    if (!isGujarati) return text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    // Check if key exists in predefined translation table
    final direct = translate(trimmed);
    if (direct != trimmed) return direct;

    // Check Google translation cache
    final cached = GoogleTranslationService.instance.getCached(trimmed);
    if (cached != null && cached.isNotEmpty) return cached;

    // Trigger on-the-fly Google ML Kit / Web Translation in background
    GoogleTranslationService.instance.translateToGujarati(trimmed);
    return text;
  }

  static List<String> getAllEnglishTexts() {
    final values = _localizedValues['en']?.values.toList() ?? [];
    return values;
  }

  static MyAppTranslations of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    return MyAppTranslations(locale);
  }
}

extension TranslationExtension on BuildContext {
  String tr(String key) => MyAppTranslations.of(this).translate(key);
  String trDynamic(String text) => MyAppTranslations.of(this).translateDynamic(text);
}
