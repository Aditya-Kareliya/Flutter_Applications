import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/google_translation_service.dart';
import '../../../../core/localization/my_app_translations.dart';
import '../../../../core/utils/youtube_url_helper.dart';

/// Activity log model for tracking all actions in the admin portal
class AdminActivityLog {
  final String id;
  final DateTime timestamp;
  final String action; // 'CREATE', 'UPDATE', 'DELETE', 'CONFIG'
  final String module;
  final String details;
  final String user;

  AdminActivityLog({required this.id, required this.timestamp, required this.action, required this.module, required this.details, this.user = 'admin'});

  Map<String, dynamic> toMap() {
    return {'id': id, 'timestamp': timestamp.toIso8601String(), 'action': action, 'module': module, 'details': details, 'user': user};
  }

  factory AdminActivityLog.fromMap(Map<String, dynamic> map) {
    return AdminActivityLog(
      id: map['id'] as String? ?? 'log-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      action: map['action'] as String? ?? 'UPDATE',
      module: map['module'] as String? ?? 'General',
      details: map['details'] as String? ?? '',
      user: map['user'] as String? ?? 'admin',
    );
  }
}

/// Site content field model for editable text across the website
class AdminContentField {
  final String key;
  final String label;
  final String section;
  String valueEn;
  String valueGu;
  final bool isMultiline;

  AdminContentField({required this.key, required this.label, required this.section, required this.valueEn, required this.valueGu, this.isMultiline = false});

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'section': section,
      'value_en': valueEn,
      'value_gu': valueGu,
      'valueEn': valueEn,
      'valueGu': valueGu,
      'is_multiline': isMultiline,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminContentField.fromMap(Map<String, dynamic> map) {
    return AdminContentField(
      key: map['key'] as String? ?? '',
      label: map['label'] as String? ?? '',
      section: map['section'] as String? ?? 'General',
      valueEn: map['value_en'] as String? ?? map['valueEn'] as String? ?? '',
      valueGu: map['value_gu'] as String? ?? map['valueGu'] as String? ?? '',
      isMultiline: map['is_multiline'] as bool? ?? map['isMultiline'] as bool? ?? false,
    );
  }

  AdminContentField copyWith({String? valueEn, String? valueGu}) {
    return AdminContentField(key: key, label: label, section: section, valueEn: valueEn ?? this.valueEn, valueGu: valueGu ?? this.valueGu, isMultiline: isMultiline);
  }
}

/// Committee Member / Trustee model for About page CRUD
class AdminCommitteeMember {
  final String id;
  final String nameEn;
  final String nameGu;
  final String designationEn;
  final String designationGu;
  final String phone;
  final String photoUrl;
  final int order;
  final bool isActive;

  const AdminCommitteeMember({
    required this.id,
    required this.nameEn,
    required this.nameGu,
    required this.designationEn,
    required this.designationGu,
    this.phone = '',
    this.photoUrl = 'assets/images/pavan_putra_logo.jpg',
    this.order = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_gu': nameGu,
      'designation_en': designationEn,
      'designation_gu': designationGu,
      'phone': phone,
      'photo_url': photoUrl,
      'order': order,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminCommitteeMember.fromMap(Map<String, dynamic> map) {
    return AdminCommitteeMember(
      id: map['id'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? map['nameEn'] as String? ?? '',
      nameGu: map['name_gu'] as String? ?? map['nameGu'] as String? ?? '',
      designationEn: map['designation_en'] as String? ?? map['designationEn'] as String? ?? '',
      designationGu: map['designation_gu'] as String? ?? map['designationGu'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photo_url'] as String? ?? map['photoUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? map['isActive'] as bool? ?? true,
    );
  }

  AdminCommitteeMember copyWith({
    String? id,
    String? nameEn,
    String? nameGu,
    String? designationEn,
    String? designationGu,
    String? phone,
    String? photoUrl,
    int? order,
    bool? isActive,
  }) {
    return AdminCommitteeMember(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameGu: nameGu ?? this.nameGu,
      designationEn: designationEn ?? this.designationEn,
      designationGu: designationGu ?? this.designationGu,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// History Milestone Timeline item for History page CRUD
class AdminHistoryMilestone {
  final String id;
  final String year;
  final String badgeEn;
  final String badgeGu;
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;
  final String iconName;
  final String imageUrl;
  final int order;

  AdminHistoryMilestone({
    required this.id,
    required this.year,
    required this.badgeEn,
    required this.badgeGu,
    required this.titleEn,
    required this.titleGu,
    required this.descEn,
    required this.descGu,
    this.iconName = 'local_fire_department_rounded',
    this.imageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.order = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'badge_en': badgeEn,
      'badge_gu': badgeGu,
      'title_en': titleEn,
      'title_gu': titleGu,
      'desc_en': descEn,
      'desc_gu': descGu,
      'icon_name': iconName,
      'image_url': imageUrl,
      'order': order,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminHistoryMilestone.fromMap(Map<String, dynamic> map) {
    return AdminHistoryMilestone(
      id: map['id'] as String? ?? '',
      year: map['year'] as String? ?? '',
      badgeEn: map['badge_en'] as String? ?? map['badgeEn'] as String? ?? 'MILESTONE',
      badgeGu: map['badge_gu'] as String? ?? map['badgeGu'] as String? ?? 'માઇલસ્ટોન',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      descEn: map['desc_en'] as String? ?? map['descEn'] as String? ?? '',
      descGu: map['desc_gu'] as String? ?? map['descGu'] as String? ?? '',
      iconName: map['icon_name'] as String? ?? map['iconName'] as String? ?? 'local_fire_department_rounded',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  AdminHistoryMilestone copyWith({
    String? id,
    String? year,
    String? badgeEn,
    String? badgeGu,
    String? titleEn,
    String? titleGu,
    String? descEn,
    String? descGu,
    String? iconName,
    String? imageUrl,
    int? order,
  }) {
    return AdminHistoryMilestone(
      id: id ?? this.id,
      year: year ?? this.year,
      badgeEn: badgeEn ?? this.badgeEn,
      badgeGu: badgeGu ?? this.badgeGu,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }
}

/// Home singer & musician card model for Home page CRUD
class AdminHomeSinger {
  final String id;
  final String nameEn;
  final String nameGu;
  final String roleEn;
  final String roleGu;
  final String descEn;
  final String descGu;
  final String imageUrl;
  final int order;

  AdminHomeSinger({
    required this.id,
    required this.nameEn,
    required this.nameGu,
    required this.roleEn,
    required this.roleGu,
    required this.descEn,
    required this.descGu,
    this.imageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.order = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_gu': nameGu,
      'role_en': roleEn,
      'role_gu': roleGu,
      'desc_en': descEn,
      'desc_gu': descGu,
      'image_url': imageUrl,
      'order': order,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminHomeSinger.fromMap(Map<String, dynamic> map) {
    return AdminHomeSinger(
      id: map['id'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? map['nameEn'] as String? ?? '',
      nameGu: map['name_gu'] as String? ?? map['nameGu'] as String? ?? '',
      roleEn: map['role_en'] as String? ?? map['roleEn'] as String? ?? '',
      roleGu: map['role_gu'] as String? ?? map['roleGu'] as String? ?? '',
      descEn: map['desc_en'] as String? ?? map['descEn'] as String? ?? '',
      descGu: map['desc_gu'] as String? ?? map['descGu'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  AdminHomeSinger copyWith({String? id, String? nameEn, String? nameGu, String? roleEn, String? roleGu, String? descEn, String? descGu, String? imageUrl, int? order}) {
    return AdminHomeSinger(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameGu: nameGu ?? this.nameGu,
      roleEn: roleEn ?? this.roleEn,
      roleGu: roleGu ?? this.roleGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
    );
  }
}

/// Hero Section complete management model
class AdminHeroData {
  final String sacredInvocationEn;
  final String sacredInvocationGu;
  final String tagBadgeEn;
  final String tagBadgeGu;
  final String titleEn;
  final String titleGu;
  final String mottoEn;
  final String mottoGu;
  final String descEn;
  final String descGu;
  final String ctaPrimaryTextEn;
  final String ctaPrimaryTextGu;
  final String ctaPrimaryRoute;
  final String ctaSecondaryTextEn;
  final String ctaSecondaryTextGu;
  final String ctaSecondaryRoute;
  final String bottomBadgeEn;
  final String bottomBadgeGu;
  final String imageUrl;

  const AdminHeroData({
    this.sacredInvocationEn = '',
    this.sacredInvocationGu = '',
    this.tagBadgeEn = '',
    this.tagBadgeGu = '',
    this.titleEn = '',
    this.titleGu = '',
    this.mottoEn = '',
    this.mottoGu = '',
    this.descEn = '',
    this.descGu = '',
    this.ctaPrimaryTextEn = '',
    this.ctaPrimaryTextGu = '',
    this.ctaPrimaryRoute = '/archive',
    this.ctaSecondaryTextEn = '',
    this.ctaSecondaryTextGu = '',
    this.ctaSecondaryRoute = '/about',
    this.bottomBadgeEn = '',
    this.bottomBadgeGu = '',
    this.imageUrl = '',
  });

  String getSacredInvocation(String lang) => lang == 'gu'
      ? (sacredInvocationGu.trim().isNotEmpty ? sacredInvocationGu.trim() : sacredInvocationEn.trim())
      : (sacredInvocationEn.trim().isNotEmpty ? sacredInvocationEn.trim() : sacredInvocationGu.trim());

  String getTagBadge(String lang) =>
      lang == 'gu' ? (tagBadgeGu.trim().isNotEmpty ? tagBadgeGu.trim() : tagBadgeEn.trim()) : (tagBadgeEn.trim().isNotEmpty ? tagBadgeEn.trim() : tagBadgeGu.trim());

  String getTitle(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String getMotto(String lang) => lang == 'gu' ? (mottoGu.trim().isNotEmpty ? mottoGu.trim() : mottoEn.trim()) : (mottoEn.trim().isNotEmpty ? mottoEn.trim() : mottoGu.trim());

  String getDesc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  String getCtaPrimaryText(String lang) => lang == 'gu'
      ? (ctaPrimaryTextGu.trim().isNotEmpty ? ctaPrimaryTextGu.trim() : ctaPrimaryTextEn.trim())
      : (ctaPrimaryTextEn.trim().isNotEmpty ? ctaPrimaryTextEn.trim() : ctaPrimaryTextGu.trim());

  String getCtaSecondaryText(String lang) => lang == 'gu'
      ? (ctaSecondaryTextGu.trim().isNotEmpty ? ctaSecondaryTextGu.trim() : ctaSecondaryTextEn.trim())
      : (ctaSecondaryTextEn.trim().isNotEmpty ? ctaSecondaryTextEn.trim() : ctaSecondaryTextGu.trim());

  String getBottomBadge(String lang) => lang == 'gu'
      ? (bottomBadgeGu.trim().isNotEmpty ? bottomBadgeGu.trim() : bottomBadgeEn.trim())
      : (bottomBadgeEn.trim().isNotEmpty ? bottomBadgeEn.trim() : bottomBadgeGu.trim());

  bool get hasSacredInvocation => sacredInvocationEn.trim().isNotEmpty || sacredInvocationGu.trim().isNotEmpty;

  bool get hasTagBadge => tagBadgeEn.trim().isNotEmpty || tagBadgeGu.trim().isNotEmpty;

  bool get hasTitle => titleEn.trim().isNotEmpty || titleGu.trim().isNotEmpty;

  bool get hasMotto => mottoEn.trim().isNotEmpty || mottoGu.trim().isNotEmpty;

  bool get hasDesc => descEn.trim().isNotEmpty || descGu.trim().isNotEmpty;

  bool get hasCtaPrimary => ctaPrimaryTextEn.trim().isNotEmpty || ctaPrimaryTextGu.trim().isNotEmpty;

  bool get hasCtaSecondary => ctaSecondaryTextEn.trim().isNotEmpty || ctaSecondaryTextGu.trim().isNotEmpty;

  bool get hasBottomBadge => bottomBadgeEn.trim().isNotEmpty || bottomBadgeGu.trim().isNotEmpty;

  bool get hasImage => imageUrl.trim().isNotEmpty;

  AdminHeroData copyWith({
    String? sacredInvocationEn,
    String? sacredInvocationGu,
    String? tagBadgeEn,
    String? tagBadgeGu,
    String? titleEn,
    String? titleGu,
    String? mottoEn,
    String? mottoGu,
    String? descEn,
    String? descGu,
    String? ctaPrimaryTextEn,
    String? ctaPrimaryTextGu,
    String? ctaPrimaryRoute,
    String? ctaSecondaryTextEn,
    String? ctaSecondaryTextGu,
    String? ctaSecondaryRoute,
    String? bottomBadgeEn,
    String? bottomBadgeGu,
    String? imageUrl,
  }) {
    return AdminHeroData(
      sacredInvocationEn: sacredInvocationEn ?? this.sacredInvocationEn,
      sacredInvocationGu: sacredInvocationGu ?? this.sacredInvocationGu,
      tagBadgeEn: tagBadgeEn ?? this.tagBadgeEn,
      tagBadgeGu: tagBadgeGu ?? this.tagBadgeGu,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      mottoEn: mottoEn ?? this.mottoEn,
      mottoGu: mottoGu ?? this.mottoGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      ctaPrimaryTextEn: ctaPrimaryTextEn ?? this.ctaPrimaryTextEn,
      ctaPrimaryTextGu: ctaPrimaryTextGu ?? this.ctaPrimaryTextGu,
      ctaPrimaryRoute: ctaPrimaryRoute ?? this.ctaPrimaryRoute,
      ctaSecondaryTextEn: ctaSecondaryTextEn ?? this.ctaSecondaryTextEn,
      ctaSecondaryTextGu: ctaSecondaryTextGu ?? this.ctaSecondaryTextGu,
      ctaSecondaryRoute: ctaSecondaryRoute ?? this.ctaSecondaryRoute,
      bottomBadgeEn: bottomBadgeEn ?? this.bottomBadgeEn,
      bottomBadgeGu: bottomBadgeGu ?? this.bottomBadgeGu,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Model for an individual metric highlight counter (Section 2)
class AdminHighlightStat {
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;
  final String iconKey; // 'book', 'music', 'flame', 'history'

  const AdminHighlightStat({this.titleEn = '', this.titleGu = '', this.descEn = '', this.descGu = '', this.iconKey = 'book'});

  String getTitle(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String getDesc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  bool get hasTitle => titleEn.trim().isNotEmpty || titleGu.trim().isNotEmpty;

  bool get hasDesc => descEn.trim().isNotEmpty || descGu.trim().isNotEmpty;

  bool get isActive => hasTitle || hasDesc;

  IconData get iconData {
    switch (iconKey) {
      case 'music':
        return Icons.music_note_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'history':
        return Icons.history_rounded;
      case 'book':
      default:
        return Icons.auto_stories_rounded;
    }
  }

  AdminHighlightStat copyWith({String? titleEn, String? titleGu, String? descEn, String? descGu, String? iconKey}) {
    return AdminHighlightStat(
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      iconKey: iconKey ?? this.iconKey,
    );
  }
}

/// Model for all 4 metric counters in Section 2 (Heritage Highlights)
class AdminStatsData {
  final AdminHighlightStat stat1;
  final AdminHighlightStat stat2;
  final AdminHighlightStat stat3;
  final AdminHighlightStat stat4;

  const AdminStatsData({
    this.stat1 = const AdminHighlightStat(iconKey: 'book'),
    this.stat2 = const AdminHighlightStat(iconKey: 'music'),
    this.stat3 = const AdminHighlightStat(iconKey: 'flame'),
    this.stat4 = const AdminHighlightStat(iconKey: 'history'),
  });

  List<AdminHighlightStat> get allStats => [stat1, stat2, stat3, stat4];

  List<AdminHighlightStat> get activeStats => allStats.where((s) => s.isActive).toList();

  bool get hasAnyStat => activeStats.isNotEmpty;

  AdminStatsData copyWith({AdminHighlightStat? stat1, AdminHighlightStat? stat2, AdminHighlightStat? stat3, AdminHighlightStat? stat4}) {
    return AdminStatsData(stat1: stat1 ?? this.stat1, stat2: stat2 ?? this.stat2, stat3: stat3 ?? this.stat3, stat4: stat4 ?? this.stat4);
  }
}

/// Model for dynamic about/pillar value cards on homepage (Section 3)
class AdminAboutCard {
  final String id;
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;
  final String iconKey; // 'shield', 'music', 'reverence', 'flower', 'flame', 'book', 'history'
  final int order;

  const AdminAboutCard({required this.id, this.titleEn = '', this.titleGu = '', this.descEn = '', this.descGu = '', this.iconKey = 'shield', this.order = 0});

  String getTitle(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String getDesc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  bool get hasTitle => titleEn.trim().isNotEmpty || titleGu.trim().isNotEmpty;

  bool get hasDesc => descEn.trim().isNotEmpty || descGu.trim().isNotEmpty;

  bool get isActive => hasTitle || hasDesc;

  IconData get iconData {
    switch (iconKey) {
      case 'music':
      case 'audiotrack':
        return Icons.audiotrack_rounded;
      case 'reverence':
      case 'sun':
      case 'brightness':
        return Icons.brightness_high_rounded;
      case 'flower':
      case 'lotus':
      case 'spa':
        return Icons.spa_rounded;
      case 'flame':
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'history':
      case 'clock':
        return Icons.history_rounded;
      case 'book':
        return Icons.auto_stories_rounded;
      case 'shield':
      default:
        return Icons.shield_outlined;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_gu': titleGu,
      'desc_en': descEn,
      'desc_gu': descGu,
      'icon_key': iconKey,
      'order': order,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminAboutCard.fromMap(Map<String, dynamic> map) {
    return AdminAboutCard(
      id: map['id'] as String? ?? 'card-${DateTime.now().millisecondsSinceEpoch}',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      descEn: map['desc_en'] as String? ?? map['descEn'] as String? ?? '',
      descGu: map['desc_gu'] as String? ?? map['descGu'] as String? ?? '',
      iconKey: map['icon_key'] as String? ?? map['iconKey'] as String? ?? 'shield',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  AdminAboutCard copyWith({String? id, String? titleEn, String? titleGu, String? descEn, String? descGu, String? iconKey, int? order}) {
    return AdminAboutCard(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      iconKey: iconKey ?? this.iconKey,
      order: order ?? this.order,
    );
  }
}

/// Model for the About Mandal header and announcements (Section 3)
class AdminAboutData {
  final String tagEn;
  final String tagGu;
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;
  final String aartiEn;
  final String aartiGu;

  const AdminAboutData({this.tagEn = '', this.tagGu = '', this.titleEn = '', this.titleGu = '', this.descEn = '', this.descGu = '', this.aartiEn = '', this.aartiGu = ''});

  String tag(String lang) => lang == 'gu' ? (tagGu.trim().isNotEmpty ? tagGu.trim() : tagEn.trim()) : (tagEn.trim().isNotEmpty ? tagEn.trim() : tagGu.trim());

  String title(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String desc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  String aarti(String lang) => lang == 'gu' ? (aartiGu.trim().isNotEmpty ? aartiGu.trim() : aartiEn.trim()) : (aartiEn.trim().isNotEmpty ? aartiEn.trim() : aartiGu.trim());

  bool get hasTag => tagEn.trim().isNotEmpty || tagGu.trim().isNotEmpty;

  bool get hasTitle => titleEn.trim().isNotEmpty || titleGu.trim().isNotEmpty;

  bool get hasDesc => descEn.trim().isNotEmpty || descGu.trim().isNotEmpty;

  bool get hasAarti => aartiEn.trim().isNotEmpty || aartiGu.trim().isNotEmpty;

  bool get isEmpty => !hasTag && !hasTitle && !hasDesc && !hasAarti;
}

/// Dynamic Cultural Principle / Value model for About page
class AdminAboutPrinciple {
  final String id;
  final String number;
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;
  final String iconKey;
  final int order;
  final bool isActive;

  const AdminAboutPrinciple({
    required this.id,
    this.number = '૦૧',
    this.titleEn = '',
    this.titleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.iconKey = 'verified',
    this.order = 0,
    this.isActive = true,
  });

  String getTitle(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String getDesc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  String getDisplayText(String lang) {
    final t = getTitle(lang);
    final d = getDesc(lang);
    if (d.isEmpty) return t;
    if (t.isEmpty) return d;
    return '$t — $d';
  }

  IconData get iconData {
    switch (iconKey) {
      case 'favorite':
      case 'heart':
        return Icons.favorite_rounded;
      case 'book':
      case 'poetry':
        return Icons.auto_stories_rounded;
      case 'history':
      case 'heritage':
        return Icons.history_edu_rounded;
      case 'flame':
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'music':
      case 'audio':
        return Icons.music_note_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'groups':
      case 'people':
        return Icons.people_outline_rounded;
      case 'verified':
      default:
        return Icons.verified_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'title_en': titleEn,
      'title_gu': titleGu,
      'desc_en': descEn,
      'desc_gu': descGu,
      'icon_key': iconKey,
      'order': order,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminAboutPrinciple.fromMap(Map<String, dynamic> map) {
    return AdminAboutPrinciple(
      id: map['id'] as String? ?? 'principle-${DateTime.now().millisecondsSinceEpoch}',
      number: map['number'] as String? ?? '૦૧',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      descEn: map['desc_en'] as String? ?? map['descEn'] as String? ?? '',
      descGu: map['desc_gu'] as String? ?? map['descGu'] as String? ?? '',
      iconKey: map['icon_key'] as String? ?? map['iconKey'] as String? ?? 'verified',
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? map['isActive'] as bool? ?? true,
    );
  }

  AdminAboutPrinciple copyWith({String? id, String? number, String? titleEn, String? titleGu, String? descEn, String? descGu, String? iconKey, int? order, bool? isActive}) {
    return AdminAboutPrinciple(
      id: id ?? this.id,
      number: number ?? this.number,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      iconKey: iconKey ?? this.iconKey,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Complete Data model for About Us Page
class AdminAboutPageData {
  final String tagBadgeEn;
  final String tagBadgeGu;
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;

  final String foundationTitleEn;
  final String foundationTitleGu;
  final String foundationDescEn;
  final String foundationDescGu;
  final String foundationMottoEn;
  final String foundationMottoGu;
  final String foundationImageUrl;

  final String valuesTagEn;
  final String valuesTagGu;
  final String valuesTitleEn;
  final String valuesTitleGu;

  final String committeeBadgeEn;
  final String committeeBadgeGu;
  final String committeeTitleEn;
  final String committeeTitleGu;
  final String committeeDescEn;
  final String committeeDescGu;

  final String ctaTitleEn;
  final String ctaTitleGu;
  final String ctaDescEn;
  final String ctaDescGu;
  final String ctaBtnTextEn;
  final String ctaBtnTextGu;
  final String ctaRoute;

  const AdminAboutPageData({
    this.tagBadgeEn = '',
    this.tagBadgeGu = '',
    this.titleEn = '',
    this.titleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.foundationTitleEn = '',
    this.foundationTitleGu = '',
    this.foundationDescEn = '',
    this.foundationDescGu = '',
    this.foundationMottoEn = '',
    this.foundationMottoGu = '',
    this.foundationImageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.valuesTagEn = '',
    this.valuesTagGu = '',
    this.valuesTitleEn = '',
    this.valuesTitleGu = '',
    this.committeeBadgeEn = '',
    this.committeeBadgeGu = '',
    this.committeeTitleEn = '',
    this.committeeTitleGu = '',
    this.committeeDescEn = '',
    this.committeeDescGu = '',
    this.ctaTitleEn = '',
    this.ctaTitleGu = '',
    this.ctaDescEn = '',
    this.ctaDescGu = '',
    this.ctaBtnTextEn = '',
    this.ctaBtnTextGu = '',
    this.ctaRoute = '/history',
  });

  String getTagBadge(String lang) =>
      lang == 'gu' ? (tagBadgeGu.trim().isNotEmpty ? tagBadgeGu.trim() : tagBadgeEn.trim()) : (tagBadgeEn.trim().isNotEmpty ? tagBadgeEn.trim() : tagBadgeGu.trim());

  String getTitle(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String getDesc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  String getFoundationTitle(String lang) => lang == 'gu'
      ? (foundationTitleGu.trim().isNotEmpty ? foundationTitleGu.trim() : foundationTitleEn.trim())
      : (foundationTitleEn.trim().isNotEmpty ? foundationTitleEn.trim() : foundationTitleGu.trim());

  String getFoundationDesc(String lang) => lang == 'gu'
      ? (foundationDescGu.trim().isNotEmpty ? foundationDescGu.trim() : foundationDescEn.trim())
      : (foundationDescEn.trim().isNotEmpty ? foundationDescEn.trim() : foundationDescGu.trim());

  String getFoundationMotto(String lang) => lang == 'gu'
      ? (foundationMottoGu.trim().isNotEmpty ? foundationMottoGu.trim() : foundationMottoEn.trim())
      : (foundationMottoEn.trim().isNotEmpty ? foundationMottoEn.trim() : foundationMottoGu.trim());

  String getValuesTag(String lang) =>
      lang == 'gu' ? (valuesTagGu.trim().isNotEmpty ? valuesTagGu.trim() : valuesTagEn.trim()) : (valuesTagEn.trim().isNotEmpty ? valuesTagEn.trim() : valuesTagGu.trim());

  String getValuesTitle(String lang) => lang == 'gu'
      ? (valuesTitleGu.trim().isNotEmpty ? valuesTitleGu.trim() : valuesTitleEn.trim())
      : (valuesTitleEn.trim().isNotEmpty ? valuesTitleEn.trim() : valuesTitleGu.trim());

  String getCommitteeBadge(String lang) => lang == 'gu'
      ? (committeeBadgeGu.trim().isNotEmpty ? committeeBadgeGu.trim() : committeeBadgeEn.trim())
      : (committeeBadgeEn.trim().isNotEmpty ? committeeBadgeEn.trim() : committeeBadgeGu.trim());

  String getCommitteeTitle(String lang) => lang == 'gu'
      ? (committeeTitleGu.trim().isNotEmpty ? committeeTitleGu.trim() : committeeTitleEn.trim())
      : (committeeTitleEn.trim().isNotEmpty ? committeeTitleEn.trim() : committeeTitleGu.trim());

  String getCommitteeDesc(String lang) => lang == 'gu'
      ? (committeeDescGu.trim().isNotEmpty ? committeeDescGu.trim() : committeeDescEn.trim())
      : (committeeDescEn.trim().isNotEmpty ? committeeDescEn.trim() : committeeDescGu.trim());

  String getCtaTitle(String lang) => lang == 'gu'
      ? (ctaTitleGu.trim().isNotEmpty ? conscience(ctaTitleGu, ctaTitleEn) : ctaTitleEn.trim())
      : (ctaTitleEn.trim().isNotEmpty ? ctaTitleEn.trim() : ctaTitleGu.trim());

  String getCtaDesc(String lang) =>
      lang == 'gu' ? (ctaDescGu.trim().isNotEmpty ? conscience(ctaDescGu, ctaDescEn) : ctaDescEn.trim()) : (ctaDescEn.trim().isNotEmpty ? ctaDescEn.trim() : ctaDescGu.trim());

  String getCtaBtnText(String lang) => lang == 'gu'
      ? (ctaBtnTextGu.trim().isNotEmpty ? conscience(ctaBtnTextGu, ctaBtnTextEn) : ctaBtnTextEn.trim())
      : (ctaBtnTextEn.trim().isNotEmpty ? ctaBtnTextEn.trim() : ctaBtnTextGu.trim());

  static String conscience(String gu, String en) => gu.trim().isNotEmpty ? gu.trim() : en.trim();
}

/// Home banner item for hero carousel CRUD
class AdminHomeBanner {
  final String id;
  final String badgeEn;
  final String badgeGu;
  final String titleEn;
  final String titleGu;
  final String subtitleEn;
  final String subtitleGu;
  final String imageUrl;
  final String ctaTextEn;
  final String ctaTextGu;
  final String ctaRoute;
  final int order;
  final bool isActive;

  AdminHomeBanner({
    required this.id,
    required this.badgeEn,
    required this.badgeGu,
    required this.titleEn,
    required this.titleGu,
    required this.subtitleEn,
    required this.subtitleGu,
    this.imageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.ctaTextEn = 'EXPLORE ARCHIVE',
    this.ctaTextGu = 'આર્કાઇવ જુઓ',
    this.ctaRoute = '/archive',
    this.order = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'badge_en': badgeEn,
      'badge_gu': badgeGu,
      'title_en': titleEn,
      'title_gu': titleGu,
      'subtitle_en': subtitleEn,
      'subtitle_gu': subtitleGu,
      'image_url': imageUrl,
      'cta_text_en': ctaTextEn,
      'cta_text_gu': ctaTextGu,
      'cta_route': ctaRoute,
      'order': order,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminHomeBanner.fromMap(Map<String, dynamic> map) {
    return AdminHomeBanner(
      id: map['id'] as String? ?? '',
      badgeEn: map['badge_en'] as String? ?? map['badgeEn'] as String? ?? 'HERITAGE',
      badgeGu: map['badge_gu'] as String? ?? map['badgeGu'] as String? ?? 'વારસો',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      subtitleEn: map['subtitle_en'] as String? ?? map['subtitleEn'] as String? ?? '',
      subtitleGu: map['subtitle_gu'] as String? ?? map['subtitleGu'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      ctaTextEn: map['cta_text_en'] as String? ?? map['ctaTextEn'] as String? ?? 'EXPLORE',
      ctaTextGu: map['cta_text_gu'] as String? ?? map['ctaTextGu'] as String? ?? 'જુઓ',
      ctaRoute: map['cta_route'] as String? ?? map['ctaRoute'] as String? ?? '/archive',
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? map['isActive'] as bool? ?? true,
    );
  }

  AdminHomeBanner copyWith({
    String? id,
    String? badgeEn,
    String? badgeGu,
    String? titleEn,
    String? titleGu,
    String? subtitleEn,
    String? subtitleGu,
    String? imageUrl,
    String? ctaTextEn,
    String? ctaTextGu,
    String? ctaRoute,
    int? order,
    bool? isActive,
  }) {
    return AdminHomeBanner(
      id: id ?? this.id,
      badgeEn: badgeEn ?? this.badgeEn,
      badgeGu: badgeGu ?? this.badgeGu,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleGu: subtitleGu ?? this.subtitleGu,
      imageUrl: imageUrl ?? this.imageUrl,
      ctaTextEn: ctaTextEn ?? this.ctaTextEn,
      ctaTextGu: ctaTextGu ?? this.ctaTextGu,
      ctaRoute: ctaRoute ?? this.ctaRoute,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Model for Sacred Foundations / Pillars of Garbi (Section 4)
class AdminHomePillar {
  final String id;
  final String number; // '૦૧', '૦૨', '૦૩'
  final String titleEn;
  final String titleGu;
  final String descEn;
  final String descGu;
  final String iconKey; // 'group', 'book', 'flame', 'music', 'shield', 'flower'
  final int order;
  final bool isActive;

  const AdminHomePillar({
    required this.id,
    this.number = '૦૧',
    this.titleEn = '',
    this.titleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.iconKey = 'group',
    this.order = 0,
    this.isActive = true,
  });

  String getTitle(String lang) => lang == 'gu' ? (titleGu.trim().isNotEmpty ? titleGu.trim() : titleEn.trim()) : (titleEn.trim().isNotEmpty ? titleEn.trim() : titleGu.trim());

  String getDesc(String lang) => lang == 'gu' ? (descGu.trim().isNotEmpty ? descGu.trim() : descEn.trim()) : (descEn.trim().isNotEmpty ? descEn.trim() : descGu.trim());

  bool get hasTitle => titleEn.trim().isNotEmpty || titleGu.trim().isNotEmpty;

  bool get hasDesc => descEn.trim().isNotEmpty || descGu.trim().isNotEmpty;

  IconData get iconData {
    switch (iconKey) {
      case 'book':
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'flame':
      case 'fire':
      case 'aarti':
        return Icons.whatshot_rounded;
      case 'music':
      case 'audiotrack':
        return Icons.music_note_rounded;
      case 'shield':
        return Icons.shield_outlined;
      case 'flower':
      case 'lotus':
        return Icons.spa_rounded;
      case 'group':
      case 'people':
      default:
        return Icons.group_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'title_en': titleEn,
      'title_gu': titleGu,
      'desc_en': descEn,
      'desc_gu': descGu,
      'icon_key': iconKey,
      'order': order,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminHomePillar.fromMap(Map<String, dynamic> map) {
    return AdminHomePillar(
      id: map['id'] as String? ?? 'pillar-${DateTime.now().millisecondsSinceEpoch}',
      number: map['number'] as String? ?? '૦૧',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      descEn: map['desc_en'] as String? ?? map['descEn'] as String? ?? '',
      descGu: map['desc_gu'] as String? ?? map['descGu'] as String? ?? '',
      iconKey: map['icon_key'] as String? ?? map['iconKey'] as String? ?? 'group',
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? map['isActive'] as bool? ?? true,
    );
  }

  AdminHomePillar copyWith({String? id, String? number, String? titleEn, String? titleGu, String? descEn, String? descGu, String? iconKey, int? order, bool? isActive}) {
    return AdminHomePillar(
      id: id ?? this.id,
      number: number ?? this.number,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      descEn: descEn ?? this.descEn,
      descGu: descGu ?? this.descGu,
      iconKey: iconKey ?? this.iconKey,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Model for Elders & Dignitaries Blessings (Section 6)
class AdminHomeBlessing {
  final String id;
  final String quoteEn;
  final String quoteGu;
  final String authorEn;
  final String authorGu;
  final String designationEn;
  final String designationGu;
  final String photoUrl;
  final int order;
  final bool isActive;

  const AdminHomeBlessing({
    required this.id,
    this.quoteEn = '',
    this.quoteGu = '',
    this.authorEn = '',
    this.authorGu = '',
    this.designationEn = '',
    this.designationGu = '',
    this.photoUrl = 'assets/images/pavan_putra_logo.jpg',
    this.order = 0,
    this.isActive = true,
  });

  String getQuote(String lang) => lang == 'gu' ? (quoteGu.trim().isNotEmpty ? quoteGu.trim() : quoteEn.trim()) : (quoteEn.trim().isNotEmpty ? quoteEn.trim() : quoteGu.trim());

  String getAuthor(String lang) =>
      lang == 'gu' ? (authorGu.trim().isNotEmpty ? authorGu.trim() : authorEn.trim()) : (authorEn.trim().isNotEmpty ? authorEn.trim() : authorGu.trim());

  String getDesignation(String lang) => lang == 'gu'
      ? (designationGu.trim().isNotEmpty ? designationGu.trim() : designationEn.trim())
      : (designationEn.trim().isNotEmpty ? designationEn.trim() : designationGu.trim());

  bool get hasQuote => quoteEn.trim().isNotEmpty || quoteGu.trim().isNotEmpty;

  bool get hasAuthor => authorEn.trim().isNotEmpty || authorGu.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote_en': quoteEn,
      'quote_gu': quoteGu,
      'author_en': authorEn,
      'author_gu': authorGu,
      'designation_en': designationEn,
      'designation_gu': designationGu,
      'photo_url': photoUrl,
      'order': order,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminHomeBlessing.fromMap(Map<String, dynamic> map) {
    return AdminHomeBlessing(
      id: map['id'] as String? ?? 'blessing-${DateTime.now().millisecondsSinceEpoch}',
      quoteEn: map['quote_en'] as String? ?? map['quoteEn'] as String? ?? '',
      quoteGu: map['quote_gu'] as String? ?? map['quoteGu'] as String? ?? '',
      authorEn: map['author_en'] as String? ?? map['authorEn'] as String? ?? '',
      authorGu: map['author_gu'] as String? ?? map['authorGu'] as String? ?? '',
      designationEn: map['designation_en'] as String? ?? map['designationEn'] as String? ?? '',
      designationGu: map['designation_gu'] as String? ?? map['designationGu'] as String? ?? '',
      photoUrl: map['photo_url'] as String? ?? map['photoUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? map['isActive'] as bool? ?? true,
    );
  }

  AdminHomeBlessing copyWith({
    String? id,
    String? quoteEn,
    String? quoteGu,
    String? authorEn,
    String? authorGu,
    String? designationEn,
    String? designationGu,
    String? photoUrl,
    int? order,
    bool? isActive,
  }) {
    return AdminHomeBlessing(
      id: id ?? this.id,
      quoteEn: quoteEn ?? this.quoteEn,
      quoteGu: quoteGu ?? this.quoteGu,
      authorEn: authorEn ?? this.authorEn,
      authorGu: authorGu ?? this.authorGu,
      designationEn: designationEn ?? this.designationEn,
      designationGu: designationGu ?? this.designationGu,
      photoUrl: photoUrl ?? this.photoUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Model for Cultural Call To Action Banner (Section 7)
class AdminHomeCtaData {
  final String invocationEn;
  final String invocationGu;
  final String mottoEn;
  final String mottoGu;
  final String btnTextEn;
  final String btnTextGu;
  final String btnRoute;

  const AdminHomeCtaData({
    this.invocationEn = '|| Jagti Jogmaya ||',
    this.invocationGu = '|| જાગતી જોગમાયા ||',
    this.mottoEn = 'Connect with our sacred tradition and feel the divine presence of Maa Ambe.',
    this.mottoGu = 'આપણી પ્રાચીન સંસ્કૃતિ, પરંપરા અને ભક્તિ સાથે જોડાઓ અને માં અંબાના આશીર્વાદ પ્રાપ્ત કરો.',
    this.btnTextEn = 'Connect With Us',
    this.btnTextGu = 'સંપર્ક કરો / સહભાગી બનો',
    this.btnRoute = '/contact',
  });

  String invocation(String lang) =>
      lang == 'gu' ? (invocationGu.trim().isNotEmpty ? invocationGu.trim() : invocationEn.trim()) : (invocationEn.trim().isNotEmpty ? invocationEn.trim() : invocationGu.trim());

  String motto(String lang) => lang == 'gu' ? (mottoGu.trim().isNotEmpty ? mottoGu.trim() : mottoEn.trim()) : (mottoEn.trim().isNotEmpty ? mottoEn.trim() : mottoGu.trim());

  String btnText(String lang) =>
      lang == 'gu' ? (btnTextGu.trim().isNotEmpty ? btnTextGu.trim() : btnTextEn.trim()) : (btnTextEn.trim().isNotEmpty ? btnTextEn.trim() : btnTextGu.trim());

  String getInvocation(String lang) => invocation(lang);

  String getMotto(String lang) => motto(lang);

  String getBtnText(String lang) => btnText(lang);

  bool get isEmpty =>
      invocationEn.trim().isEmpty && invocationGu.trim().isEmpty && mottoEn.trim().isEmpty && mottoGu.trim().isEmpty && btnTextEn.trim().isEmpty && btnTextGu.trim().isEmpty;
}

class AdminGarbiYear {
  final String id;
  final int year;
  final String titleEn;
  final String titleGu;
  final String description;
  final bool isPublished;
  final int albumCount;

  AdminGarbiYear({required this.id, required this.year, required this.titleEn, required this.titleGu, required this.description, this.isPublished = true, this.albumCount = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'title_en': titleEn,
      'title_gu': titleGu,
      'titleEn': titleEn,
      'titleGu': titleGu,
      'description': description,
      'is_published': isPublished,
      'isPublished': isPublished,
      'album_count': albumCount,
      'albumCount': albumCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminGarbiYear.fromMap(Map<String, dynamic> map) {
    return AdminGarbiYear(
      id: map['id'] as String? ?? '',
      year: (map['year'] as num?)?.toInt() ?? 2025,
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isPublished: map['is_published'] as bool? ?? map['isPublished'] as bool? ?? true,
      albumCount: (map['album_count'] as num?)?.toInt() ?? (map['albumCount'] as num?)?.toInt() ?? 0,
    );
  }

  AdminGarbiYear copyWith({String? id, int? year, String? titleEn, String? titleGu, String? description, bool? isPublished, int? albumCount}) {
    return AdminGarbiYear(
      id: id ?? this.id,
      year: year ?? this.year,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      description: description ?? this.description,
      isPublished: isPublished ?? this.isPublished,
      albumCount: albumCount ?? this.albumCount,
    );
  }
}

class AdminAlbum {
  final String id;
  final String year;
  final String name;
  final String dayTag;
  final String description;
  final String coverImageUrl;
  final int photoCount;

  AdminAlbum({
    required this.id,
    required this.year,
    required this.name,
    required this.dayTag,
    required this.description,
    this.coverImageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.photoCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'name': name,
      'day_tag': dayTag,
      'dayTag': dayTag,
      'description': description,
      'cover_image_url': coverImageUrl,
      'photo_count': photoCount,
      'photoCount': photoCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminAlbum.fromMap(Map<String, dynamic> map) {
    return AdminAlbum(
      id: map['id'] as String? ?? '',
      year: map['year'] as String? ?? '2025',
      name: map['name'] as String? ?? '',
      dayTag: map['day_tag'] as String? ?? map['dayTag'] as String? ?? 'Day 1',
      description: map['description'] as String? ?? '',
      coverImageUrl: map['cover_image_url'] as String? ?? map['coverImageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      photoCount: (map['photo_count'] as num?)?.toInt() ?? (map['photoCount'] as num?)?.toInt() ?? 0,
    );
  }

  AdminAlbum copyWith({String? id, String? year, String? name, String? dayTag, String? description, String? coverImageUrl, int? photoCount}) {
    return AdminAlbum(
      id: id ?? this.id,
      year: year ?? this.year,
      name: name ?? this.name,
      dayTag: dayTag ?? this.dayTag,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}

class AdminPhoto {
  final String id;
  final String year;
  final String albumId;
  final String day;
  final String titleEn;
  final String titleGu;
  final String imageUrl;
  final String caption;
  final bool isFeatured;

  AdminPhoto({
    required this.id,
    required this.year,
    required this.albumId,
    required this.day,
    required this.titleEn,
    required this.titleGu,
    this.imageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.caption = '',
    this.isFeatured = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'album_id': albumId,
      'albumId': albumId,
      'day': day,
      'title_en': titleEn,
      'title_gu': titleGu,
      'titleEn': titleEn,
      'titleGu': titleGu,
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'is_featured': isFeatured,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminPhoto.fromMap(Map<String, dynamic> map) {
    return AdminPhoto(
      id: map['id'] as String? ?? '',
      year: map['year'] as String? ?? '2025',
      albumId: map['album_id'] as String? ?? map['albumId'] as String? ?? '',
      day: map['day'] as String? ?? 'Day 1',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      caption: map['caption'] as String? ?? '',
      isFeatured: map['is_featured'] as bool? ?? map['isFeatured'] as bool? ?? true,
    );
  }

  AdminPhoto copyWith({String? id, String? year, String? albumId, String? day, String? titleEn, String? titleGu, String? imageUrl, String? caption, bool? isFeatured}) {
    return AdminPhoto(
      id: id ?? this.id,
      year: year ?? this.year,
      albumId: albumId ?? this.albumId,
      day: day ?? this.day,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class AdminVideo {
  final String id;
  final String youtubeVideoId;
  final String title;
  final String titleGu;
  final String tag;
  final String duration;
  final String youtubeUrl;
  final String year;
  final String thumbnailUrl;
  final bool isFeatured;
  final bool isPublished;
  final String sourceChannel;

  AdminVideo({
    required this.id,
    String? youtubeVideoId,
    required this.title,
    this.titleGu = '',
    required this.tag,
    required this.duration,
    required this.youtubeUrl,
    required this.year,
    String? thumbnailUrl,
    this.isFeatured = true,
    this.isPublished = true,
    this.sourceChannel = 'Ratnadeep Sound',
  }) : youtubeVideoId = youtubeVideoId?.isNotEmpty == true ? youtubeVideoId! : (YoutubeUrlHelper.extractVideoId(youtubeUrl) ?? ''),
       thumbnailUrl = (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
           ? thumbnailUrl
           : ((youtubeVideoId != null && youtubeVideoId.isNotEmpty)
                 ? YoutubeUrlHelper.buildThumbnailUrl(youtubeVideoId)
                 : (YoutubeUrlHelper.extractVideoId(youtubeUrl) != null ? YoutubeUrlHelper.buildThumbnailUrl(YoutubeUrlHelper.extractVideoId(youtubeUrl)!) : ''));

  Map<String, dynamic> toMap() {
    final canonId = youtubeVideoId.isNotEmpty ? youtubeVideoId : (YoutubeUrlHelper.extractVideoId(youtubeUrl) ?? '');
    final thumb = thumbnailUrl.isNotEmpty ? thumbnailUrl : (canonId.isNotEmpty ? YoutubeUrlHelper.buildThumbnailUrl(canonId) : '');

    return {
      'id': id,
      'youtube_video_id': canonId,
      'youtubeVideoId': canonId,
      'title': title,
      'title_en': title,
      'title_gu': titleGu,
      'tag': tag,
      'category': tag,
      'duration': duration,
      'youtube_url': youtubeUrl,
      'youtubeUrl': youtubeUrl,
      'year': year,
      'thumbnail_url': thumb,
      'thumbnailUrl': thumb,
      'is_featured': isFeatured,
      'isFeatured': isFeatured,
      'is_published': isPublished,
      'isPublished': isPublished,
      'source_channel': sourceChannel,
      'sourceChannel': sourceChannel,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminVideo.fromMap(Map<String, dynamic> map) {
    final rawUrl = map['youtube_url'] as String? ?? map['youtubeUrl'] as String? ?? '';
    final extractedId = map['youtube_video_id'] as String? ?? map['youtubeVideoId'] as String? ?? YoutubeUrlHelper.extractVideoId(rawUrl) ?? '';
    final thumb = map['thumbnail_url'] as String? ?? map['thumbnailUrl'] as String? ?? (extractedId.isNotEmpty ? YoutubeUrlHelper.buildThumbnailUrl(extractedId) : '');

    return AdminVideo(
      id: map['id'] as String? ?? '',
      youtubeVideoId: extractedId,
      title: map['title'] as String? ?? map['title_en'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? '',
      tag: map['tag'] as String? ?? map['category'] as String? ?? 'Garbi',
      duration: map['duration'] as String? ?? '',
      youtubeUrl: rawUrl,
      year: map['year'] as String? ?? '2024',
      thumbnailUrl: thumb,
      isFeatured: map['is_featured'] as bool? ?? map['isFeatured'] as bool? ?? true,
      isPublished: map['is_published'] as bool? ?? map['isPublished'] as bool? ?? true,
      sourceChannel: map['source_channel'] as String? ?? map['sourceChannel'] as String? ?? 'Ratnadeep Sound',
    );
  }

  AdminVideo copyWith({
    String? id,
    String? youtubeVideoId,
    String? title,
    String? titleGu,
    String? tag,
    String? duration,
    String? youtubeUrl,
    String? year,
    String? thumbnailUrl,
    bool? isFeatured,
    bool? isPublished,
    String? sourceChannel,
  }) {
    return AdminVideo(
      id: id ?? this.id,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      title: title ?? this.title,
      titleGu: titleGu ?? this.titleGu,
      tag: tag ?? this.tag,
      duration: duration ?? this.duration,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      year: year ?? this.year,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      sourceChannel: sourceChannel ?? this.sourceChannel,
    );
  }
}

class AdminLiveStreamSettings {
  final bool isLive;
  final String title;
  final String streamUrl;
  final String announcement;
  final String scheduleTime;

  const AdminLiveStreamSettings({this.isLive = false, this.title = '', this.streamUrl = '', this.announcement = '', this.scheduleTime = ''});

  Map<String, dynamic> toMap() {
    return {
      'is_live': isLive,
      'isLive': isLive,
      'title': title,
      'stream_url': streamUrl,
      'streamUrl': streamUrl,
      'announcement': announcement,
      'schedule_time': scheduleTime,
      'scheduleTime': scheduleTime,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminLiveStreamSettings.fromMap(Map<String, dynamic> map) {
    return AdminLiveStreamSettings(
      isLive: map['is_live'] as bool? ?? map['isLive'] as bool? ?? false,
      title: map['title'] as String? ?? '',
      streamUrl: map['stream_url'] as String? ?? map['streamUrl'] as String? ?? '',
      announcement: map['announcement'] as String? ?? '',
      scheduleTime: map['schedule_time'] as String? ?? map['scheduleTime'] as String? ?? '',
    );
  }

  AdminLiveStreamSettings copyWith({bool? isLive, String? title, String? streamUrl, String? announcement, String? scheduleTime}) {
    return AdminLiveStreamSettings(
      isLive: isLive ?? this.isLive,
      title: title ?? this.title,
      streamUrl: streamUrl ?? this.streamUrl,
      announcement: announcement ?? this.announcement,
      scheduleTime: scheduleTime ?? this.scheduleTime,
    );
  }
}

class AdminBlog {
  final String id;
  final String slug;
  final String title;
  final String titleGu;
  final String category;
  final String date;
  final String readTime;
  final String snippet;
  final String snippetGu;
  final String content;
  final String imageUrl;
  final bool isPublished;

  AdminBlog({
    required this.id,
    required this.slug,
    required this.title,
    this.titleGu = '',
    required this.category,
    required this.date,
    required this.readTime,
    required this.snippet,
    this.snippetGu = '',
    required this.content,
    this.imageUrl = 'assets/images/pavan_putra_logo.jpg',
    this.isPublished = true,
  });

  String getTitle(String lang) => (lang == 'gu' && titleGu.isNotEmpty) ? titleGu : title;

  String getSnippet(String lang) => (lang == 'gu' && snippetGu.isNotEmpty) ? snippetGu : snippet;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'title_en': title,
      'title_gu': titleGu,
      'category': category,
      'date': date,
      'read_time': readTime,
      'snippet': snippet,
      'snippet_en': snippet,
      'snippet_gu': snippetGu,
      'content': content,
      'image_url': imageUrl,
      'is_published': isPublished,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminBlog.fromMap(Map<String, dynamic> map) {
    return AdminBlog(
      id: map['id'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      title: map['title'] as String? ?? map['title_en'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? '',
      category: map['category'] as String? ?? 'Heritage',
      date: map['date'] as String? ?? '',
      readTime: map['read_time'] as String? ?? map['readTime'] as String? ?? '5 min',
      snippet: map['snippet'] as String? ?? map['snippet_en'] as String? ?? '',
      snippetGu: map['snippet_gu'] as String? ?? '',
      content: map['content'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
      isPublished: map['is_published'] as bool? ?? map['isPublished'] as bool? ?? true,
    );
  }

  AdminBlog copyWith({
    String? id,
    String? slug,
    String? title,
    String? titleGu,
    String? category,
    String? date,
    String? readTime,
    String? snippet,
    String? snippetGu,
    String? content,
    String? imageUrl,
    bool? isPublished,
  }) {
    return AdminBlog(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      titleGu: titleGu ?? this.titleGu,
      category: category ?? this.category,
      date: date ?? this.date,
      readTime: readTime ?? this.readTime,
      snippet: snippet ?? this.snippet,
      snippetGu: snippetGu ?? this.snippetGu,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

class AdminEnquiry {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String message;
  final String date;
  final String status;

  AdminEnquiry({required this.id, required this.name, required this.phone, required this.email, required this.message, required this.date, this.status = 'New'});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email, 'message': message, 'date': date, 'status': status, 'updated_at': DateTime.now().toIso8601String()};
  }

  factory AdminEnquiry.fromMap(Map<String, dynamic> map) {
    return AdminEnquiry(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      message: map['message'] as String? ?? '',
      date: map['date'] as String? ?? '',
      status: map['status'] as String? ?? 'New',
    );
  }

  AdminEnquiry copyWith({String? id, String? name, String? phone, String? email, String? message, String? date, String? status}) {
    return AdminEnquiry(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      message: message ?? this.message,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}

class AdminSettings {
  final String mandalNameEn;
  final String mandalNameGu;
  final String contactPhone;
  final String contactEmail;
  final String address;
  final String dailyAartiTime;
  final String youtubeChannel;
  final String instagramHandle;
  final String facebookUrl;
  final String whatsappNumber;
  final String logoImageUrl;
  String get logoUrl => logoImageUrl;

  const AdminSettings({
    this.mandalNameEn = '',
    this.mandalNameGu = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.address = '',
    this.dailyAartiTime = '',
    this.youtubeChannel = '',
    this.instagramHandle = '',
    this.facebookUrl = 'https://facebook.com/PavanPutraGarbiRajkot',
    this.whatsappNumber = '+919876543210',
    this.logoImageUrl = 'assets/images/pavan_putra_logo.jpg',
  });

  Map<String, dynamic> toMap() {
    return {
      'mandal_name_en': mandalNameEn,
      'mandal_name_gu': mandalNameGu,
      'mandalNameEn': mandalNameEn,
      'mandalNameGu': mandalNameGu,
      'contact_phone': contactPhone,
      'contactPhone': contactPhone,
      'contact_email': contactEmail,
      'contactEmail': contactEmail,
      'address': address,
      'daily_aarti_time': dailyAartiTime,
      'dailyAartiTime': dailyAartiTime,
      'youtube_channel': youtubeChannel,
      'youtubeChannel': youtubeChannel,
      'instagram_handle': instagramHandle,
      'instagramHandle': instagramHandle,
      'facebook_url': facebookUrl,
      'whatsapp_number': whatsappNumber,
      'logo_image_url': logoImageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminSettings.fromMap(Map<String, dynamic> map) {
    return AdminSettings(
      mandalNameEn: map['mandal_name_en'] as String? ?? map['mandalNameEn'] as String? ?? 'Pavan Putra Garbi Mandal',
      mandalNameGu: map['mandal_name_gu'] as String? ?? map['mandalNameGu'] as String? ?? 'શ્રી પવનપુત્ર ગરબી મંડળ',
      contactPhone: map['contact_phone'] as String? ?? map['contactPhone'] as String? ?? '',
      contactEmail: map['contact_email'] as String? ?? map['contactEmail'] as String? ?? '',
      address: map['address'] as String? ?? '',
      dailyAartiTime: map['daily_aarti_time'] as String? ?? map['dailyAartiTime'] as String? ?? '',
      youtubeChannel: map['youtube_channel'] as String? ?? map['youtubeChannel'] as String? ?? '',
      instagramHandle: map['instagram_handle'] as String? ?? map['instagramHandle'] as String? ?? '',
      facebookUrl: map['facebook_url'] as String? ?? map['facebookUrl'] as String? ?? 'https://facebook.com/PavanPutraGarbiRajkot',
      whatsappNumber: map['whatsapp_number'] as String? ?? map['whatsappNumber'] as String? ?? '+919876543210',
      logoImageUrl: map['logo_image_url'] as String? ?? map['logoImageUrl'] as String? ?? 'assets/images/pavan_putra_logo.jpg',
    );
  }

  AdminSettings copyWith({
    String? mandalNameEn,
    String? mandalNameGu,
    String? contactPhone,
    String? contactEmail,
    String? address,
    String? dailyAartiTime,
    String? youtubeChannel,
    String? instagramHandle,
    String? facebookUrl,
    String? whatsappNumber,
    String? logoImageUrl,
  }) {
    return AdminSettings(
      mandalNameEn: mandalNameEn ?? this.mandalNameEn,
      mandalNameGu: mandalNameGu ?? this.mandalNameGu,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      address: address ?? this.address,
      dailyAartiTime: dailyAartiTime ?? this.dailyAartiTime,
      youtubeChannel: youtubeChannel ?? this.youtubeChannel,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      logoImageUrl: logoImageUrl ?? this.logoImageUrl,
    );
  }
}

/// Model for dynamic website footer quick navigation links
class AdminFooterLink {
  final String id;
  final String titleEn;
  final String titleGu;
  final String url;
  final String column; // 'col1' (Explore Archive) or 'col2' (About Mandal)
  final int order;
  final bool isEnabled;
  final bool isExternal;

  const AdminFooterLink({
    required this.id,
    required this.titleEn,
    required this.titleGu,
    required this.url,
    this.column = 'col1',
    this.order = 1,
    this.isEnabled = true,
    this.isExternal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_gu': titleGu,
      'url': url,
      'column': column,
      'order': order,
      'is_enabled': isEnabled,
      'is_external': isExternal,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminFooterLink.fromMap(Map<String, dynamic> map) {
    return AdminFooterLink(
      id: map['id'] as String? ?? 'flink-${DateTime.now().millisecondsSinceEpoch}',
      titleEn: map['title_en'] as String? ?? map['titleEn'] as String? ?? '',
      titleGu: map['title_gu'] as String? ?? map['titleGu'] as String? ?? '',
      url: map['url'] as String? ?? '/',
      column: map['column'] as String? ?? 'col1',
      order: (map['order'] as num?)?.toInt() ?? 1,
      isEnabled: map['is_enabled'] as bool? ?? map['isEnabled'] as bool? ?? true,
      isExternal: map['is_external'] as bool? ?? map['isExternal'] as bool? ?? false,
    );
  }

  AdminFooterLink copyWith({
    String? id,
    String? titleEn,
    String? titleGu,
    String? url,
    String? column,
    int? order,
    bool? isEnabled,
    bool? isExternal,
  }) {
    return AdminFooterLink(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleGu: titleGu ?? this.titleGu,
      url: url ?? this.url,
      column: column ?? this.column,
      order: order ?? this.order,
      isEnabled: isEnabled ?? this.isEnabled,
      isExternal: isExternal ?? this.isExternal,
    );
  }
}

/// Model for dynamic official social channel buttons in website footer
class AdminFooterSocialLink {
  final String id;
  final String platform;
  final String url;
  final String iconKey;
  final int order;
  final bool isEnabled;

  const AdminFooterSocialLink({
    required this.id,
    required this.platform,
    required this.url,
    this.iconKey = 'link',
    this.order = 1,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'url': url,
      'icon_key': iconKey,
      'order': order,
      'is_enabled': isEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminFooterSocialLink.fromMap(Map<String, dynamic> map) {
    return AdminFooterSocialLink(
      id: map['id'] as String? ?? 'fsoc-${DateTime.now().millisecondsSinceEpoch}',
      platform: map['platform'] as String? ?? 'Social',
      url: map['url'] as String? ?? '',
      iconKey: map['icon_key'] as String? ?? map['iconKey'] as String? ?? 'link',
      order: (map['order'] as num?)?.toInt() ?? 1,
      isEnabled: map['is_enabled'] as bool? ?? map['isEnabled'] as bool? ?? true,
    );
  }

  AdminFooterSocialLink copyWith({
    String? id,
    String? platform,
    String? url,
    String? iconKey,
    int? order,
    bool? isEnabled,
  }) {
    return AdminFooterSocialLink(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      iconKey: iconKey ?? this.iconKey,
      order: order ?? this.order,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class AdminDataStore extends ChangeNotifier {
  static final AdminDataStore instance = AdminDataStore._internal();

  AdminDataStore._internal() {
    _populatePreloadedDefaults();
  }

  final List<AdminCommitteeMember> _committeeMembers = [];
  final List<AdminAboutPrinciple> _aboutPrinciples = [];
  final List<AdminHistoryMilestone> _historyMilestones = [];
  final List<AdminHomeSinger> _homeSingers = [];
  final List<AdminHomeBanner> _homeBanners = [];
  final List<AdminAboutCard> _aboutCards = [];
  final List<AdminHomePillar> _pillars = [];
  final List<AdminHomeBlessing> _blessings = [];

  final List<AdminGarbiYear> _years = [];
  final List<AdminAlbum> _albums = [];
  final List<AdminPhoto> _photos = [];
  final List<AdminVideo> _videos = [];
  final List<AdminBlog> _blogs = [];
  final List<AdminEnquiry> _enquiries = [];
  final List<AdminActivityLog> _activityLogs = [];
  final List<AdminFooterLink> _footerLinks = [];
  final List<AdminFooterSocialLink> _footerSocialLinks = [];
  final Map<String, AdminContentField> _siteContentMap = {};

  AdminLiveStreamSettings _liveStreamSettings = const AdminLiveStreamSettings();

  AdminSettings _settings = const AdminSettings();

  bool _isFirestoreConnected = false;

  bool get isFirestoreConnected => _isFirestoreConnected;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  // Getters
  List<AdminCommitteeMember> get committeeMembers => List.unmodifiable(_committeeMembers);

  List<AdminAboutPrinciple> get aboutPrinciples => List.unmodifiable(_aboutPrinciples);

  List<AdminHistoryMilestone> get historyMilestones => List.unmodifiable(_historyMilestones);

  List<AdminHomeSinger> get homeSingers => List.unmodifiable(_homeSingers);

  List<AdminHomeBanner> get homeBanners => List.unmodifiable(_homeBanners);

  List<AdminAboutCard> get aboutCards => List.unmodifiable(_aboutCards);

  List<AdminHomePillar> get pillars => List.unmodifiable(_pillars);

  List<AdminHomeBlessing> get blessings => List.unmodifiable(_blessings);

  List<AdminGarbiYear> get years => List.unmodifiable(_years);

  List<AdminAlbum> get albums => List.unmodifiable(_albums);

  List<AdminPhoto> get photos => List.unmodifiable(_photos);

  List<AdminVideo> get videos => List.unmodifiable(_videos);

  List<AdminVideo> get publishedVideos => List.unmodifiable(_videos.where((v) => v.isPublished).toList());

  AdminLiveStreamSettings get liveStreamSettings => _liveStreamSettings;

  List<AdminBlog> get blogs => List.unmodifiable(_blogs);

  List<AdminEnquiry> get enquiries => List.unmodifiable(_enquiries);

  List<AdminActivityLog> get activityLogs => List.unmodifiable(_activityLogs);

  List<AdminContentField> get siteContentFields => List.unmodifiable(_siteContentMap.values.toList());

  AdminSettings get settings => _settings;

  List<AdminFooterLink> get footerLinks => List.unmodifiable(_footerLinks);

  List<AdminFooterSocialLink> get footerSocialLinks => List.unmodifiable(_footerSocialLinks);

  /// Retrieves content value with automatic fallback to preloaded code dictionary
  String getContentVal(String key, String lang) {
    final f = _siteContentMap[key];
    if (f != null) {
      final val = lang == 'gu' ? f.valueGu.trim() : f.valueEn.trim();
      if (val.isNotEmpty) return val;
    }
    return MyAppTranslations.getPreloaded(key, lang);
  }

  AdminHeroData get heroData {
    String getVal(String key, String lang) => getContentVal(key, lang);

    String img = '';
    if (_siteContentMap.containsKey('hero_image_url')) {
      img = getVal('hero_image_url', 'en');
    } else if (_homeBanners.isNotEmpty) {
      img = _homeBanners.first.imageUrl.trim();
    }
    if (img.isEmpty) {
      img = 'assets/images/pavan_putra_logo.jpg';
    }

    return AdminHeroData(
      sacredInvocationEn: getVal('sacred_invocation', 'en'),
      sacredInvocationGu: getVal('sacred_invocation', 'gu'),
      tagBadgeEn: getVal('hero_tag', 'en'),
      tagBadgeGu: getVal('hero_tag', 'gu'),
      titleEn: getVal('hero_title', 'en'),
      titleGu: getVal('hero_title', 'gu'),
      mottoEn: getVal('hero_gujarati_motto', 'en'),
      mottoGu: getVal('hero_gujarati_motto', 'gu'),
      descEn: getVal('hero_description', 'en'),
      descGu: getVal('hero_description', 'gu'),
      ctaPrimaryTextEn: getVal('hero_cta_archive', 'en'),
      ctaPrimaryTextGu: getVal('hero_cta_archive', 'gu'),
      ctaPrimaryRoute: getVal('hero_cta_archive_route', 'en').isEmpty ? '/archive' : getVal('hero_cta_archive_route', 'en'),
      ctaSecondaryTextEn: getVal('hero_cta_about', 'en'),
      ctaSecondaryTextGu: getVal('hero_cta_about', 'gu'),
      ctaSecondaryRoute: getVal('hero_cta_about_route', 'en').isEmpty ? '/about' : getVal('hero_cta_about_route', 'en'),
      bottomBadgeEn: getVal('hero_official_badge', 'en'),
      bottomBadgeGu: getVal('hero_official_badge', 'gu'),
      imageUrl: img,
    );
  }

  AdminStatsData get statsData {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return AdminStatsData(
      stat1: AdminHighlightStat(
        titleEn: getVal('stat_years_title', 'en'),
        titleGu: getVal('stat_years_title', 'gu'),
        descEn: getVal('stat_years_desc', 'en'),
        descGu: getVal('stat_years_desc', 'gu'),
        iconKey: 'book',
      ),
      stat2: AdminHighlightStat(
        titleEn: getVal('stat_music_title', 'en'),
        titleGu: getVal('stat_music_title', 'gu'),
        descEn: getVal('stat_music_desc', 'en'),
        descGu: getVal('stat_music_desc', 'gu'),
        iconKey: 'music',
      ),
      stat3: AdminHighlightStat(
        titleEn: getVal('stat_devotion_title', 'en'),
        titleGu: getVal('stat_devotion_title', 'gu'),
        descEn: getVal('stat_devotion_desc', 'en'),
        descGu: getVal('stat_devotion_desc', 'gu'),
        iconKey: 'flame',
      ),
      stat4: AdminHighlightStat(
        titleEn: getVal('stat_archive_title', 'en'),
        titleGu: getVal('stat_archive_title', 'gu'),
        descEn: getVal('stat_archive_desc', 'en'),
        descGu: getVal('stat_archive_desc', 'gu'),
        iconKey: 'history',
      ),
    );
  }

  AdminAboutData get aboutData {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return AdminAboutData(
      tagEn: getVal('sec_01_tag', 'en'),
      tagGu: getVal('sec_01_tag', 'gu'),
      titleEn: getVal('sec_01_title', 'en'),
      titleGu: getVal('sec_01_title', 'gu'),
      descEn: getVal('sec_01_desc', 'en'),
      descGu: getVal('sec_01_desc', 'gu'),
      aartiEn: getVal('daily_aarti_announcement', 'en'),
      aartiGu: getVal('daily_aarti_announcement', 'gu'),
    );
  }

  AdminAboutPageData get aboutPageData {
    String getVal(String key, String lang) => getContentVal(key, lang);

    String img = getVal('about_foundation_image', 'en');
    if (img.isEmpty) img = 'assets/images/pavan_putra_logo.jpg';

    String tagEn = getVal('about_tag', 'en');
    String tagGu = getVal('about_tag', 'gu');
    if (tagEn.isEmpty) tagEn = getVal('sec_01_tag', 'en');
    if (tagGu.isEmpty) tagGu = getVal('sec_01_tag', 'gu');

    String titleEn = getVal('about_title', 'en');
    String titleGu = getVal('about_title', 'gu');
    if (titleEn.isEmpty) titleEn = getVal('sec_01_title', 'en');
    if (titleGu.isEmpty) titleGu = getVal('sec_01_title', 'gu');

    String descEn = getVal('about_desc', 'en');
    String descGu = getVal('about_desc', 'gu');
    if (descEn.isEmpty) descEn = getVal('sec_01_desc', 'en');
    if (descGu.isEmpty) descGu = getVal('sec_01_desc', 'gu');

    return AdminAboutPageData(
      tagBadgeEn: tagEn,
      tagBadgeGu: tagGu,
      titleEn: titleEn,
      titleGu: titleGu,
      descEn: descEn,
      descGu: descGu,
      foundationTitleEn: getVal('about_history_title', 'en'),
      foundationTitleGu: getVal('about_history_title', 'gu'),
      foundationDescEn: getVal('about_history_desc', 'en'),
      foundationDescGu: getVal('about_history_desc', 'gu'),
      foundationMottoEn: getVal('about_foundation_motto', 'en'),
      foundationMottoGu: getVal('about_foundation_motto', 'gu'),
      foundationImageUrl: img,
      valuesTagEn: getVal('about_values_tag', 'en'),
      valuesTagGu: getVal('about_values_tag', 'gu'),
      valuesTitleEn: getVal('about_values_title', 'en'),
      valuesTitleGu: getVal('about_values_title', 'gu'),
      committeeBadgeEn: getVal('about_committee_badge', 'en'),
      committeeBadgeGu: getVal('about_committee_badge', 'gu'),
      committeeTitleEn: getVal('about_committee_title', 'en'),
      committeeTitleGu: getVal('about_committee_title', 'gu'),
      committeeDescEn: getVal('about_committee_desc', 'en'),
      committeeDescGu: getVal('about_committee_desc', 'gu'),
      ctaTitleEn: getVal('about_cta_title', 'en'),
      ctaTitleGu: getVal('about_cta_title', 'gu'),
      ctaDescEn: getVal('about_cta_desc', 'en'),
      ctaDescGu: getVal('about_cta_desc', 'gu'),
      ctaBtnTextEn: getVal('about_cta_btn_text', 'en'),
      ctaBtnTextGu: getVal('about_cta_btn_text', 'gu'),
      ctaRoute: getVal('about_cta_route', 'en').isEmpty ? '/history' : getVal('about_cta_route', 'en'),
    );
  }

  Map<String, String> get homePillarsHeader {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return {
      'tagEn': getVal('sec_pillars_tag', 'en'),
      'tagGu': getVal('sec_pillars_tag', 'gu'),
      'titleEn': getVal('sec_pillars_title', 'en'),
      'titleGu': getVal('sec_pillars_title', 'gu'),
    };
  }

  Map<String, String> get homeSingersHeader {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return {
      'tagEn': getVal('sec_singers_tag', 'en'),
      'tagGu': getVal('sec_singers_tag', 'gu'),
      'titleEn': getVal('sec_singers_title', 'en'),
      'titleGu': getVal('sec_singers_title', 'gu'),
      'descEn': getVal('sec_singers_desc', 'en'),
      'descGu': getVal('sec_singers_desc', 'gu'),
    };
  }

  Map<String, String> get homeBlessingsHeader {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return {
      'tagEn': getVal('sec_opinions_tag', 'en'),
      'tagGu': getVal('sec_opinions_tag', 'gu'),
      'titleEn': getVal('sec_opinions_title', 'en'),
      'titleGu': getVal('sec_opinions_title', 'gu'),
    };
  }

  Map<String, String> get homeArticlesHeader {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return {
      'tagEn': getVal('sec_blog_tag', 'en'),
      'tagGu': getVal('sec_blog_tag', 'gu'),
      'titleEn': getVal('sec_blog_title', 'en'),
      'titleGu': getVal('sec_blog_title', 'gu'),
    };
  }

  AdminHomeCtaData get homeCtaData {
    String getVal(String key, String lang) => getContentVal(key, lang);

    return AdminHomeCtaData(
      invocationEn: getVal('home_cta_invocation', 'en'),
      invocationGu: getVal('home_cta_invocation', 'gu'),
      mottoEn: getVal('home_cta_motto', 'en'),
      mottoGu: getVal('home_cta_motto', 'gu'),
      btnTextEn: getVal('home_cta_btn_text', 'en'),
      btnTextGu: getVal('home_cta_btn_text', 'gu'),
      btnRoute: getVal('home_cta_btn_route', 'en').isEmpty ? '/contact' : getVal('home_cta_btn_route', 'en'),
    );
  }

  String? getTextOverride(String langCode, String key) {
    final field = _siteContentMap[key];
    if (field != null) {
      final val = langCode == 'gu' ? field.valueGu.trim() : field.valueEn.trim();
      if (val.isNotEmpty) return val;
      final preloaded = MyAppTranslations.getPreloaded(key, langCode);
      if (preloaded.isNotEmpty) return preloaded;
    }
    if (key == 'app_title') {
      final title = langCode == 'gu' ? _settings.mandalNameGu.trim() : _settings.mandalNameEn.trim();
      if (title.isNotEmpty) return title;
    }
    if (key == 'contact_phone' && _settings.contactPhone.isNotEmpty) return _settings.contactPhone;
    if (key == 'contact_email' && _settings.contactEmail.isNotEmpty) return _settings.contactEmail;
    if (key == 'contact_address' && _settings.address.isNotEmpty) return _settings.address;
    if ((key == 'contact_aarti_time' || key == 'contact_hours') && _settings.dailyAartiTime.isNotEmpty) {
      return _settings.dailyAartiTime;
    }
    if (key == 'footer_location' && _settings.address.isNotEmpty) return _settings.address;
    return null;
  }

  void logActivity(String action, String module, String details) {
    final log = AdminActivityLog(id: 'log-${DateTime.now().millisecondsSinceEpoch}', timestamp: DateTime.now(), action: action, module: module, details: details, user: 'admin');
    _activityLogs.insert(0, log);
    _writeToFirestore('activity_logs', log.id, log.toMap());
  }

  void clearActivityLogs() {
    _activityLogs.clear();
    logActivity('CONFIG', 'Audit Logs', 'Cleared activity log history');
    notifyListeners();
  }

  /// Populates all data structures with preloaded code fallbacks immediately upon instantiating
  void _populatePreloadedDefaults() {
    _settings = const AdminSettings(
      mandalNameEn: 'Pavan Putra Garbi Mandal',
      mandalNameGu: 'શ્રી પવનપુત્ર ગરબી મંડળ',
      contactPhone: '+91 98765 43210 / +91 94280 12345',
      contactEmail: 'contact@pavanputragarbi.org',
      address: 'પવનપુત્ર ચોક, ભક્તિનગર, રાજકોટ - ૩૬૦૦૦૨, ગુજરાત',
      dailyAartiTime: 'રાત્રે ૮:૩૦ કલાકે / 8:30 PM Daily',
      youtubeChannel: 'https://youtube.com/@PavanPutraGarbiRajkot',
      instagramHandle: '@pavanputra_garbi_rajkot',
      facebookUrl: 'https://facebook.com/PavanPutraGarbiRajkot',
      whatsappNumber: '+919876543210',
    );

    final officialSiteContent = [
      AdminContentField(
        key: 'hero_tag',
        label: 'Hero Eyebrow Tag',
        section: 'Home Hero Section',
        valueEn: 'RAJKOT / SAURASHTRA / FOLK HERITAGE',
        valueGu: 'રાજકોટ / સૌરાષ્ટ્ર / લોક સંસ્કૃતિ',
      ),
      AdminContentField(
        key: 'hero_title',
        label: 'Hero Main Headline',
        section: 'Home Hero Section',
        valueEn: 'The Living Legacy of\nPrachin Garbi.',
        valueGu: 'પ્રાચીન ગરબીનો અમર વારસો,\nભક્તિ અને સૂરની સાધના.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'hero_gujarati_motto',
        label: 'Hero Devotional Motto',
        section: 'Home Hero Section',
        valueEn: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
        valueGu: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      ),
      AdminContentField(
        key: 'hero_description',
        label: 'Hero Introduction Paragraph',
        section: 'Home Hero Section',
        valueEn:
            'Since 1977 in Rajkot, Pavan Putra Garbi Mandal has preserved the pure, sacred spirit of authentic Gujarati Garbi — celebrating the divine feminine power of Maa Ambe through acoustic folk rhythm, classical poetry, and community devotion.',
        valueGu:
            'ઈ.સ. ૧૯૭૭ થી રાજકોટમાં મા અંબેની અખંડ ભક્તિ સાથે ધબકતું શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ — પ્રાચીન રાસ, જીવંત વાદ્ય-સંગીત, છંદ અને પરંપરાગત સંસ્કૃતિનું પવિત્ર મંચ.',
        isMultiline: true,
      ),
      AdminContentField(key: 'hero_cta_archive', label: 'Hero Primary CTA Button Label', section: 'Home Hero Section', valueEn: 'EXPLORE ARCHIVE', valueGu: 'વાર્ષિક સંગ્રહ જુઓ'),
      AdminContentField(key: 'hero_cta_archive_route', label: 'Hero Primary CTA Destination Route', section: 'Home Hero Section', valueEn: '/archive', valueGu: '/archive'),
      AdminContentField(key: 'hero_cta_about', label: 'Hero Secondary CTA Button Label', section: 'Home Hero Section', valueEn: 'OUR HERITAGE', valueGu: 'મંડળ વિશે જાણો'),
      AdminContentField(key: 'hero_cta_about_route', label: 'Hero Secondary CTA Destination Route', section: 'Home Hero Section', valueEn: '/about', valueGu: '/about'),
      AdminContentField(
        key: 'hero_official_badge',
        label: 'Hero Official Archival Badge',
        section: 'Home Hero Section',
        valueEn: 'OFFICIAL CULTURAL HERITAGE ARCHIVE',
        valueGu: 'સત્તાવાર સાંસ્કૃતિક સંગ્રહ',
      ),
      AdminContentField(
        key: 'hero_image_url',
        label: 'Hero Emblem Graphic URL',
        section: 'Home Hero Section',
        valueEn: 'assets/images/pavan_putra_logo.jpg',
        valueGu: 'assets/images/pavan_putra_logo.jpg',
      ),
      AdminContentField(key: 'stat_years_title', label: 'Stat 1: Heritage Years Title', section: 'Heritage Highlights', valueEn: '45+ Years', valueGu: '૪૫+ વર્ષ'),
      AdminContentField(key: 'stat_years_desc', label: 'Stat 1: Heritage Years Description', section: 'Heritage Highlights', valueEn: 'Continuous heritage in Rajkot', valueGu: 'રાજકોટમાં અખંડ પરંપરા'),
      AdminContentField(key: 'stat_music_title', label: 'Stat 2: Music Heritage Title', section: 'Heritage Highlights', valueEn: '100% Prachin', valueGu: '૧૦૦% પ્રાચીન'),
      AdminContentField(key: 'stat_music_desc', label: 'Stat 2: Music Heritage Description', section: 'Heritage Highlights', valueEn: 'Acoustic live folk instruments', valueGu: 'જીવંત સૂર અને લોકવાદ્યો'),
      AdminContentField(key: 'stat_devotion_title', label: 'Stat 3: Devotion Title', section: 'Heritage Highlights', valueEn: 'Maa Jagti Jogmaya', valueGu: 'જગતી જોગમાયા'),
      AdminContentField(key: 'stat_devotion_desc', label: 'Stat 3: Devotion Description', section: 'Heritage Highlights', valueEn: 'Sacred deepam & daily Maha Aarti', valueGu: 'અખંડ દીપ અને મહા આરતી'),
      AdminContentField(key: 'stat_archive_title', label: 'Stat 4: Archive Title', section: 'Heritage Highlights', valueEn: 'Digital Archive', valueGu: 'ડિજિટલ સંગ્રહ'),
      AdminContentField(key: 'stat_archive_desc', label: 'Stat 4: Archive Description', section: 'Heritage Highlights', valueEn: 'Decades of photos & recordings', valueGu: 'દાયકાઓની દુર્લભ સ્મૃતિઓ'),
      AdminContentField(key: 'sec_01_tag', label: 'About Section Eyebrow Tag', section: 'About The Mandal', valueEn: '01 / THE MANDAL', valueGu: '૦૧ / ગરબી મંડળ પરિચય'),
      AdminContentField(key: 'sec_01_title', label: 'About Section Headline', section: 'About The Mandal', valueEn: 'Preserving the Pure Essence\nof Traditional Garbi.', valueGu: 'આધુનિકતા વચ્ચે સચવાયેલ\nશુદ્ધ પ્રાચીન ગરબીની ધરોહર.', isMultiline: true),
      AdminContentField(key: 'sec_01_desc', label: 'About Section Description', section: 'About The Mandal', valueEn: 'In an era of commercial sound systems and modernized music, Pavan Putra Garbi Mandal stands resolute in safeguarding the authenticity of Prachin Garbi. Every step, rhythm, and verse echoes the timeless devotion of Saurashtra.', valueGu: 'કોઈપણ વ્યાવસાયિક સંગીત કે ડીજે વિના, મા અંબેના સાન્નિધ્યમાં પ્રાચીન ગરબા, છંદ, દુહા અને સ્તુતિના પવિત્ર સૂર રેલાવીને રાજકોટમાં સંસ્કૃતિનું જતન કરતું અગ્રણી મંડળ.', isMultiline: true),
      AdminContentField(key: 'daily_aarti_announcement', label: 'Daily Maha Aarti Announcement', section: 'Aarti & Schedule', valueEn: 'Daily Maha Aarti at 8:30 PM with 108 Sacred Oil Lamps', valueGu: 'દરરોજ રાત્રે ૮:૩૦ કલાકે ૧૦૮ દીવડાઓ સાથે ભવ્ય મહા આરતી'),
      AdminContentField(
        key: 'contact_address',
        label: 'Venue Address',
        section: 'Venue & Contacts',
        valueEn: 'Pavan Putra Chowk, Bhaktinagar, Rajkot - 360002, Gujarat',
        valueGu: 'પવનપુત્ર ચોક, ભક્તિનગર, રાજકોટ - ૩૬૦૦૦૨, ગુજરાત',
      ),
      AdminContentField(
        key: 'contact_phone',
        label: 'Contact Phone Numbers',
        section: 'Venue & Contacts',
        valueEn: '+91 98765 43210 / +91 94280 12345',
        valueGu: '+91 98765 43210 / +91 94280 12345',
      ),
      AdminContentField(
        key: 'contact_email',
        label: 'Contact Email Address',
        section: 'Venue & Contacts',
        valueEn: 'contact@pavanputragarbi.org',
        valueGu: 'contact@pavanputragarbi.org',
      ),
      AdminContentField(key: 'contact_aarti_time', label: 'Daily Aarti Schedule', section: 'Venue & Contacts', valueEn: '8:30 PM Daily', valueGu: 'રાત્રે ૮:૩૦ કલાકે'),
      AdminContentField(
        key: 'footer_tagline',
        label: 'Footer Tagline',
        section: 'Branding & Header',
        valueEn: 'Preserving authentic Gujarati folk music, poetry, and cultural traditions in Rajkot since 1977.',
        valueGu: 'રાજકોટમાં ૧૯૭૭થી પરંપરાગત ગુજરાતી લોકસંગીત, પ્રાચીન કાવ્ય અને ભક્તિમય સંસ્કૃતિનું અવિરત જતન.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'footer_motto',
        label: 'Footer Devotional Motto',
        section: 'Branding & Header',
        valueEn: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
        valueGu: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      ),
      AdminContentField(
        key: 'sec_pillars_tag',
        label: 'Pillars Section Eyebrow Tag',
        section: 'Sacred Foundations',
        valueEn: '02 / SACRED FOUNDATIONS',
        valueGu: '૦૨ / પ્રાચીન ગરબીના આધારસ્તંભ',
      ),
      AdminContentField(
        key: 'sec_pillars_title',
        label: 'Pillars Section Headline',
        section: 'Sacred Foundations',
        valueEn: 'Poetry, Rhythm & Divine Grace',
        valueGu: 'સૂર, સાહિત્ય અને સાધનાનો ત્રિવેણી સંગમ',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'sec_singers_tag',
        label: 'Singers Section Eyebrow Tag',
        section: 'Folk Artists Troupe',
        valueEn: '03 / SOULS OF THE MUSIC',
        valueGu: '૦૩ / સૂર સાધકો અને વાદ્ય વૃંદ',
      ),
      AdminContentField(
        key: 'sec_singers_title',
        label: 'Singers Section Headline',
        section: 'Folk Artists Troupe',
        valueEn: 'Revered Folk Vocalists & Musicians',
        valueGu: 'જેમના કંઠેથી ગૂંજે છે ભક્તિના અમર બોલ',
      ),
      AdminContentField(
        key: 'sec_singers_desc',
        label: 'Singers Section Subtitle',
        section: 'Folk Artists Troupe',
        valueEn: 'The soulful identity of Prachin Garbi lives in its live musicians. Without synthesizers or recorded tracks, their voices invoke deep spiritual emotion across all nine sacred nights.',
        valueGu: 'પ્રાચીન ગરબીનો આત્મા તેના જીવંત ગાયકો અને વાદકોમાં વસે છે. કોઈપણ કૃત્રિમ સંગીત વિના શુદ્ધ સૂર-તાલથી શ્રોતાઓને ભાવવિભોર કરે છે.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'sec_opinions_tag',
        label: 'Blessings Section Eyebrow Tag',
        section: 'Elders Blessings',
        valueEn: '04 / WORDS OF RESPECT & GUIDANCE',
        valueGu: '૦૪ / વડીલો અને મહાનુભાવોના વિચાર',
      ),
      AdminContentField(
        key: 'sec_opinions_title',
        label: 'Blessings Section Headline',
        section: 'Elders Blessings',
        valueEn: 'Reflections from Elders & Cultural Guardians',
        valueGu: 'પ્રાચીન ગરબીના સંવર્ધન વિશે મહાનુભાવોનું મંતવ્ય',
      ),
      AdminContentField(
        key: 'sec_blog_tag',
        label: 'Articles Section Eyebrow Tag',
        section: 'Cultural Stories & Articles',
        valueEn: '07 / CULTURAL STORIES & ARTICLES',
        valueGu: '૦૭ / લેખો અને સાંસ્કૃતિક વાતો',
      ),
      AdminContentField(
        key: 'sec_blog_title',
        label: 'Articles Section Headline',
        section: 'Cultural Stories & Articles',
        valueEn: 'Heritage, Meaning & Reflections',
        valueGu: 'ગરબીનો ઇતિહાસ અને સાંસ્કૃતિક મહત્વ',
      ),
      AdminContentField(
        key: 'home_cta_invocation',
        label: 'CTA Top Sacred Chant',
        section: 'Call To Action Banner',
        valueEn: '|| Jagti Jogmaya ||',
        valueGu: '|| જાગતી જોગમાયા ||',
      ),
      AdminContentField(
        key: 'home_cta_motto',
        label: 'CTA Motto Headline',
        section: 'Call To Action Banner',
        valueEn: 'Connect with our sacred tradition and feel the divine presence of Maa Ambe.',
        valueGu: 'આપણી પ્રાચીન સંસ્કૃતિ, પરંપરા અને ભક્તિ સાથે જોડાઓ અને માં અંબાના આશીર્વાદ પ્રાપ્ત કરો.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'home_cta_btn_text',
        label: 'CTA Action Button Label',
        section: 'Call To Action Banner',
        valueEn: 'Connect With Us',
        valueGu: 'સંપર્ક કરો / સહભાગી બનો',
      ),
      AdminContentField(key: 'home_cta_btn_route', label: 'CTA Action Button Route', section: 'Call To Action Banner', valueEn: '/contact', valueGu: '/contact'),
      AdminContentField(key: 'about_tag', label: 'Header Eyebrow Badge Tag', section: 'About Page', valueEn: 'ABOUT THE MANDAL', valueGu: 'મંડળ પરિચય'),
      AdminContentField(
        key: 'about_title',
        label: 'Main Page Headline',
        section: 'About Page',
        valueEn: 'Shree Pavan Putra Prachin Garbi Mandal',
        valueGu: 'શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'about_desc',
        label: 'Introduction Paragraph',
        section: 'About Page',
        valueEn: 'A devoted cultural institution in Rajkot, Gujarat, steadfastly committed to the preservation and authentic celebration of Prachin Garbi since 1977.',
        valueGu: 'રાજકોટમાં ઈ.સ. ૧૯૭૭ થી કાર્યરત, પ્રાચીન ગરબી અને મા અંબેની આરાધનાને સમર્પિત એક બિન-વ્યાવસાયિક સાંસ્કૃતિક સંસ્થા.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'about_history_title',
        label: 'Foundation Card Headline',
        section: 'About Page',
        valueEn: 'Preserving Sacred Traditions since 1977',
        valueGu: '૧૯૭૭ થી અવિરત ધબકતી ગરબી પરંપરા',
      ),
      AdminContentField(
        key: 'about_history_desc',
        label: 'Foundation Sacred History Body',
        section: 'About Page',
        valueEn:
            'Founded by devoted community elders in Rajkot, the Mandal was born out of a profound commitment: to worship Maa Jagti Jogmaya through classical Saurashtra Garbi, retaining natural live instrumentation, spiritual lyricism, and communal harmony without commercial compromises.',
        valueGu: 'રાજકોટના શ્રદ્ધાળુ વડીલો દ્વારા સ્થાપિત આ મંડળનો મુખ્ય ઉદ્દેશ્ય માતાજીની ઉપાસનાને શુદ્ધ લોકઢાળ, જીવંત સંગીત અને સામુદાયિક ભાવના સાથે ઉજવવાનો છે.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'about_foundation_motto',
        label: 'Foundation Devotional Motto',
        section: 'About Page',
        valueEn: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
        valueGu: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
      ),
      AdminContentField(
        key: 'about_foundation_image',
        label: 'Foundation Historical Emblem / Photo',
        section: 'About Page',
        valueEn: 'assets/images/pavan_putra_logo.jpg',
        valueGu: 'assets/images/pavan_putra_logo.jpg',
      ),
      AdminContentField(key: 'about_values_tag', label: 'Principles Eyebrow Badge', section: 'About Page', valueEn: 'CORE PILLARS', valueGu: 'પાયાના આધારસ્તંભ'),
      AdminContentField(
        key: 'about_values_title',
        label: 'Principles Section Title',
        section: 'About Page',
        valueEn: 'Core Principles of the Mandal',
        valueGu: 'મંડળના પાયાના સિદ્ધાંતો',
      ),
      AdminContentField(
        key: 'about_committee_badge',
        label: 'Committee Eyebrow Badge',
        section: 'About Page',
        valueEn: 'TRUSTEES & ORGANIZING COMMITTEE',
        valueGu: 'ટ્રસ્ટી મંડળ અને સમિતિ',
      ),
      AdminContentField(
        key: 'about_committee_title',
        label: 'Committee Section Title',
        section: 'About Page',
        valueEn: 'Devoted Trustees & Committee Leadership',
        valueGu: 'સેવાભાવી ટ્રસ્ટી અને સમિતિ સભ્યો',
      ),
      AdminContentField(
        key: 'about_committee_desc',
        label: 'Committee Section Description',
        section: 'About Page',
        valueEn: 'Dedicated guardians upholding the sacred Gujarati acoustic traditions and community seva in Rajkot.',
        valueGu: 'રાજકોટમાં પ્રાચીન ગરબીની ભવ્ય પરંપરા અને સંસ્કૃતિને જીવંત રાખતા મા અંબેના અનન્ય સેવકો.',
        isMultiline: true,
      ),
      AdminContentField(
        key: 'about_cta_title',
        label: 'History Callout Headline',
        section: 'About Page',
        valueEn: 'A History of Devotion & Cultural Fortitude',
        valueGu: 'ભક્તિ અને સાંસ્કૃતિક ગૌરવનો ભવ્ય ઇતિહાસ',
      ),
      AdminContentField(
        key: 'about_cta_desc',
        label: 'History Callout Subtitle',
        section: 'About Page',
        valueEn: 'Discover four decades of unwavering dedication to Maa Ambe in Rajkot.',
        valueGu: 'રાજકોટમાં સાડા ત્રણ દાયકાથી અવિરત ચાલી રહેલી પવિત્ર યાત્રાનો સંપૂર્ણ ઇતિહાસ જાણો.',
      ),
      AdminContentField(key: 'about_cta_btn_text', label: 'History Callout Button Label', section: 'About Page', valueEn: 'EXPLORE HISTORY', valueGu: 'ઇતિહાસ જુઓ'),
      AdminContentField(key: 'about_cta_route', label: 'History Callout Destination Route', section: 'About Page', valueEn: '/history', valueGu: '/history'),
    ];

    for (final f in officialSiteContent) {
      _siteContentMap[f.key] = f;
    }

    _aboutCards.addAll([
      const AdminAboutCard(
        id: 'card-1',
        titleEn: 'Pure Cultural Sanity',
        titleGu: 'સાંસ્કૃતિક શુદ્ધતા',
        descEn: 'Strictly traditional Raas, Be-Taali, Tran-Taali, and Hinch performed in reverence.',
        descGu: 'માત્ર શુદ્ધ પ્રાચીન રાસ, બે તાલી, ત્રણ તાલી અને પરંપરાગત સૌરાષ્ટ્ર હીંચ.',
        iconKey: 'shield',
        order: 1,
      ),
      const AdminAboutCard(
        id: 'card-2',
        titleEn: 'Acoustic Folk Orchestra',
        titleGu: 'જીવંત વાદ્ય સંગીત',
        descEn: 'Harmonium, Tabla, Pakhawaj, Dholak, and Brass Cymbals played live by masters.',
        descGu: 'હાર્મોનિયમ, તબલા, પખવાજ, ઢોલક અને ઝાંઝના મૂળભૂત પ્રાચીન સૂર.',
        iconKey: 'music',
        order: 2,
      ),
      const AdminAboutCard(
        id: 'card-3',
        titleEn: 'Sacred Reverence',
        titleGu: 'સાત્વિક ઉપાસના',
        descEn: 'Centered around the sacred clay Garbo with an eternal oil flame honoring Mataji.',
        descGu: 'માટીના કુંભમાં અખંડ જ્યોત સાક્ષી રાખીને માતાજીની શ્રદ્ધાપૂર્વક આરાધના.',
        iconKey: 'fire',
        order: 3,
      ),
    ]);

    _pillars.addAll([
      const AdminHomePillar(
        id: 'pillar-1',
        titleEn: 'Prachin Raas & Footsteps',
        titleGu: 'પ્રાચીન રાસ અને કલા',
        descEn: 'Graceful, disciplined synchronized footsteps by devoted participants in authentic traditional Gujarati attire.',
        descGu: 'ગુજરાતના પરંપરાગત વસ્ત્રોમાં શિસ્તબદ્ધ અને લયબદ્ધ પગલાં સાથે માતાજીની પરિક્રમા કરતો રાસ.',
        iconKey: 'sparkles',
        order: 1,
      ),
      const AdminHomePillar(
        id: 'pillar-2',
        titleEn: 'Chhand, Duha & Saint-Poets',
        titleGu: 'છંદ, દુહા અને કવિઓની રચનાઓ',
        descEn: 'Soulful vocal renditions of devotional verses composed by medieval Gujarati masters like Dayaram, Premanand, and Vallabh Mevada.',
        descGu: 'ભક્તકવિ દયારામ, પ્રેમાનંદ અને વલ્લભ મેવાડાના અમર ભક્તિપદોનું ભાવપૂર્વક ગાન.',
        iconKey: 'book',
        order: 2,
      ),
      const AdminHomePillar(
        id: 'pillar-3',
        titleEn: 'Maha Aarti & Deepotsav',
        titleGu: 'મહા આરતી અને દીપોત્સવ',
        descEn: 'Grand daily night Aarti with hundreds of burning oil lamps, creating an unmatched atmosphere of divinity and peace.',
        descGu: 'દરરોજ રાત્રે થતી અલૌકિક મહા આરતી, જ્યાં સેંકડો દીવડાઓથી માતાજીનું પ્રાંગણ ઝળહળી ઊઠે છે.',
        iconKey: 'flame',
        order: 3,
      ),
    ]);

    _blessings.addAll([
      const AdminHomeBlessing(
        id: 'blessing-1',
        quoteEn: '“In an era where original folk forms are often diluted, Pavan Putra Garbi Mandal has guarded our sacred heritage with unwavering reverence. It is a pride for Rajkot.”',
        quoteGu: '“આજના ફાસ્ટ યુગમાં પણ પવનપુત્ર ગરબી મંડળે પ્રાચીન પરંપરાને અખંડ રાખીને આપણી સાચી ધરોહર સાચવી રાખી છે. રાજકોટ માટે આ ગૌરવની વાત છે.”',
        authorEn: 'Shree Dahyabhai (Mandal Elder & Trustee)',
        authorGu: 'શ્રી ડાહ્યાભાઈ (વડીલ માર્ગદર્શક અને ટ્રસ્ટી)',
        order: 1,
      ),
      const AdminHomeBlessing(
        id: 'blessing-2',
        quoteEn: '“The devotion and purity with which ancient Chhands and Raas are sung here reminds every Gujarati of our sacred roots. This is where tradition truly breathes.”',
        quoteGu: '“મા અંબેના પ્રાચીન છંદ અને રાસ જે શુદ્ધ ભાવ સાથે અહીં ગવાય છે તે સમગ્ર સૌરાષ્ટ્રની સાંસ્કૃતિક ગરિમા વધારે છે.”',
        authorEn: 'Pandit Jigneshbhai (Folk Music Scholar)',
        authorGu: 'પંડિત જીગ્નેશભાઈ (લોકસંગીત સંશોધક)',
        order: 2,
      ),
      const AdminHomeBlessing(
        id: 'blessing-3',
        quoteEn: '“The discipline of the participants, the warmth of the community, and the sanctity of the Mataji Aarti make this an exemplary cultural institution.”',
        quoteGu: '“ખેલૈયાઓની શિસ્ત, મંડળનું સમર્પણ અને માતાજીની આરતીનું પાવન દ્રશ્ય અહી આવીને જ અનુભવી શકાય છે.”',
        authorEn: 'Community Patron & Heritage Advocate',
        authorGu: 'શુભેચ્છક અને સાંસ્કૃતિક પ્રેમી',
        order: 3,
      ),
    ]);

    _homeSingers.addAll([
      AdminHomeSinger(
        id: 'singer-1',
        nameEn: 'Devotional Vocalists',
        nameGu: 'ભક્તિમય ગાયક વૃંદ',
        roleEn: 'Traditional Folk Chorus & Lead Chhand',
        roleGu: 'મુખ્ય છંદ અને પ્રાચીન ગરબી ગાયન',
        descEn: 'Rendering ancient stutis, duhas, and devotional Garbis passed down through generations.',
        descGu: 'પેઢી દર પેઢી ઉતરી આવેલી પ્રાચીન સ્તુતિઓ અને માતાજીના છંદોનું જીવંત ગાન.',
        order: 1,
      ),
      AdminHomeSinger(
        id: 'singer-2',
        nameEn: 'Tabla & Pakhawaj Masters',
        nameGu: 'તબલા અને પખવાજ વાદક',
        roleEn: 'Rhythm & Taal Harmony',
        roleGu: 'તાલ અને લય સાધના',
        descEn: 'Guiding the pace from slow, graceful two-taali to high-energy Saurashtra hinch.',
        descGu: 'ધીમી બે તાલીથી લઈને જોમવંતી સૌરાષ્ટ્ર હીંચ સુધી તાલની અવિરત સરવાણી.',
        order: 2,
      ),
      AdminHomeSinger(
        id: 'singer-3',
        nameEn: 'Harmonium & Jhanj Players',
        nameGu: 'હાર્મોનિયમ અને ઝાંઝ વાદક',
        roleEn: 'Acoustic Melody & Tempo',
        roleGu: 'મધુર સૂર અને ગતિ નિયંત્રણ',
        descEn: 'Weaving the musical tapestry that anchors every traditional Garbi night.',
        descGu: 'પરંપરાગત વાદ્યોના સમન્વયથી ગરબીના વાતાવરણને દિવ્ય બનાવતા કલાકારો.',
        order: 3,
      ),
    ]);

    _footerLinks.addAll(const [
      AdminFooterLink(id: 'fl-1', titleEn: 'Home', titleGu: 'હોમ', url: '/', column: 'col1', order: 1),
      AdminFooterLink(id: 'fl-2', titleEn: 'About Us', titleGu: 'પરિચય', url: '/about', column: 'col1', order: 2),
      AdminFooterLink(id: 'fl-3', titleEn: 'History', titleGu: 'ઇતિહાસ', url: '/history', column: 'col1', order: 3),
      AdminFooterLink(id: 'fl-4', titleEn: 'Year Archive', titleGu: 'સંગ્રહ', url: '/archive', column: 'col1', order: 4),
      AdminFooterLink(id: 'fl-5', titleEn: 'Gallery', titleGu: 'ગેલેરી', url: '/gallery', column: 'col2', order: 1),
      AdminFooterLink(id: 'fl-6', titleEn: 'Videos & Live', titleGu: 'વિડિઓઝ', url: '/videos', column: 'col2', order: 2),
      AdminFooterLink(id: 'fl-7', titleEn: 'Cultural Stories', titleGu: 'લેખો', url: '/blog', column: 'col2', order: 3),
      AdminFooterLink(id: 'fl-8', titleEn: 'Contact Mandal', titleGu: 'સંપર્ક', url: '/contact', column: 'col2', order: 4),
    ]);

    _footerSocialLinks.addAll(const [
      AdminFooterSocialLink(id: 'fsl-yt', platform: 'YouTube', url: 'https://youtube.com/@PavanputraGarbiRajkot', iconKey: 'youtube', isEnabled: true),
      AdminFooterSocialLink(id: 'fsl-ig', platform: 'Instagram', url: 'https://www.instagram.com/pavanputragarbimandal/', iconKey: 'instagram', isEnabled: true),
      AdminFooterSocialLink(id: 'fsl-fb', platform: 'Facebook', url: 'https://facebook.com/PavanPutraGarbiRajkot', iconKey: 'facebook', isEnabled: true),
    ]);
  }

  // --- Cloud Firestore Integration ---

  Future<void> _fetchSettings(FirebaseFirestore db) async {
    try {
      final settingsDoc = await db.collection('settings').doc('mandal_settings').get();
      if (settingsDoc.exists && settingsDoc.data() != null && settingsDoc.data()!.isNotEmpty) {
        _settings = AdminSettings.fromMap(settingsDoc.data()!);
      }
      if (_settings.mandalNameEn.isEmpty) {
        const officialSettings = AdminSettings(
          mandalNameEn: 'Pavan Putra Garbi Mandal',
          mandalNameGu: 'શ્રી પવનપુત્ર ગરબી મંડળ',
          contactPhone: '+91 98765 43210 / +91 94280 12345',
          contactEmail: 'contact@pavanputragarbi.org',
          address: 'પવનપુત્ર ચોક, ભક્તિનગર, રાજકોટ - ૩૬૦૦૦૨, ગુજરાત',
          dailyAartiTime: 'રાત્રે ૮:૩૦ કલાકે / 8:30 PM Daily',
          youtubeChannel: 'https://youtube.com/@PavanPutraGarbiRajkot',
          instagramHandle: '@pavanputra_garbi_rajkot',
          facebookUrl: 'https://facebook.com/PavanPutraGarbiRajkot',
          whatsappNumber: '+919876543210',
          logoImageUrl: 'assets/images/pavan_putra_logo.jpg',
        );
        _settings = officialSettings;
      }
    } catch (e) {
      debugPrint('Settings fetch notice: $e');
    }
  }

  Future<void> _fetchSiteContent(FirebaseFirestore db) async {
    try {
      final contentSnap = await db.collection('site_content').get();
      for (final doc in contentSnap.docs) {
        final f = AdminContentField.fromMap(doc.data());
        _siteContentMap[f.key] = f;
      }
      final officialSiteContent = [
        AdminContentField(
          key: 'hero_tag',
          label: 'Hero Eyebrow Tag',
          section: 'Home Hero Section',
          valueEn: 'RAJKOT / SAURASHTRA / FOLK HERITAGE',
          valueGu: 'રાજકોટ / સૌરાષ્ટ્ર / લોક વારસો',
        ),
        AdminContentField(
          key: 'hero_title',
          label: 'Hero Main Headline',
          section: 'Home Hero Section',
          valueEn: 'The Living Legacy of\nPrachin Garbi.',
          valueGu: 'પ્રાચીન ગરબીની\nજીવંત પરંપરા.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'hero_gujarati_motto',
          label: 'Hero Devotional Motto',
          section: 'Home Hero Section',
          valueEn: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
          valueGu: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
        ),
        AdminContentField(
          key: 'hero_description',
          label: 'Hero Introduction Paragraph',
          section: 'Home Hero Section',
          valueEn:
              'Since 1989 in Rajkot, Shree Pavan Putra Prachin Garbi Mandal has preserved the pure, sacred spirit of authentic Gujarati Garbi — celebrating the divine feminine power of Maa Mogal through acoustic folk rhythm, classical poetry, and community devotion.',
          valueGu:
              '૧૯૮૯થી રાજકોટમાં, શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ દ્વારા અસલ ગુજરાતી ગરબીની પવિત્ર અને શુદ્ધ પરંપરાને જીવંત રાખવામાં આવી છે. આ મંડળ પ્રાચીન લોક સંગીતના સૂર, શાસ્ત્રીય કવિતાઓ અને સામૂહિક ભક્તિભાવના માધ્યમથી મા મોગલની દિવ્ય શક્તિની આરાધના કરે છે.',
          isMultiline: true,
        ),
        AdminContentField(key: 'hero_cta_archive', label: 'Hero Primary CTA Button Label', section: 'Home Hero Section', valueEn: 'EXPLORE ARCHIVE', valueGu: 'આર્કાઇવ જુઓ'),
        AdminContentField(key: 'hero_cta_archive_route', label: 'Hero Primary CTA Destination Route', section: 'Home Hero Section', valueEn: '/archive', valueGu: '/archive'),
        AdminContentField(key: 'hero_cta_about', label: 'Hero Secondary CTA Button Label', section: 'Home Hero Section', valueEn: 'OUR HERITAGE', valueGu: 'અમારો વારસો'),
        AdminContentField(key: 'hero_cta_about_route', label: 'Hero Secondary CTA Destination Route', section: 'Home Hero Section', valueEn: '/about', valueGu: '/about'),
        AdminContentField(
          key: 'hero_official_badge',
          label: 'Hero Official Archival Badge',
          section: 'Home Hero Section',
          valueEn: 'OFFICIAL CULTURAL HERITAGE ARCHIVE',
          valueGu: 'સત્તાવાર સાંસ્કૃતિક વારસો આર્કાઇવ',
        ),
        AdminContentField(
          key: 'hero_image_url',
          label: 'Hero Emblem Graphic URL',
          section: 'Home Hero Section',
          valueEn: 'assets/images/pavan_putra_logo.jpg',
          valueGu: 'assets/images/pavan_putra_logo.jpg',
        ),
        AdminContentField(key: 'stat_years_title', label: 'Stat 1: Heritage Years Title', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_years_desc', label: 'Stat 1: Heritage Years Description', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_music_title', label: 'Stat 2: Music Heritage Title', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_music_desc', label: 'Stat 2: Music Heritage Description', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_devotion_title', label: 'Stat 3: Devotion Title', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_devotion_desc', label: 'Stat 3: Devotion Description', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_archive_title', label: 'Stat 4: Archive Title', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'stat_archive_desc', label: 'Stat 4: Archive Description', section: 'Heritage Highlights', valueEn: '', valueGu: ''),
        AdminContentField(key: 'sec_01_tag', label: 'About Section Eyebrow Tag', section: 'About The Mandal', valueEn: '', valueGu: ''),
        AdminContentField(key: 'sec_01_title', label: 'About Section Headline', section: 'About The Mandal', valueEn: '', valueGu: '', isMultiline: true),
        AdminContentField(key: 'sec_01_desc', label: 'About Section Description', section: 'About The Mandal', valueEn: '', valueGu: '', isMultiline: true),
        AdminContentField(key: 'daily_aarti_announcement', label: 'Daily Maha Aarti Announcement', section: 'Aarti & Schedule', valueEn: '', valueGu: ''),
        AdminContentField(
          key: 'contact_address',
          label: 'Venue Address',
          section: 'Venue & Contacts',
          valueEn: 'Pavan Putra Chowk, Bhaktinagar, Rajkot - 360002, Gujarat',
          valueGu: 'પવનપુત્ર ચોક, ભક્તિનગર, રાજકોટ - ૩૬૦૦૦૨, ગુજરાત',
        ),
        AdminContentField(
          key: 'contact_phone',
          label: 'Contact Phone Numbers',
          section: 'Venue & Contacts',
          valueEn: '+91 98765 43210 / +91 94280 12345',
          valueGu: '+91 98765 43210 / +91 94280 12345',
        ),
        AdminContentField(
          key: 'contact_email',
          label: 'Contact Email Address',
          section: 'Venue & Contacts',
          valueEn: 'contact@pavanputragarbi.org',
          valueGu: 'contact@pavanputragarbi.org',
        ),
        AdminContentField(key: 'contact_aarti_time', label: 'Daily Aarti Schedule', section: 'Venue & Contacts', valueEn: '8:30 PM Daily', valueGu: 'રાત્રે ૮:૩૦ કલાકે'),
        AdminContentField(
          key: 'footer_tagline',
          label: 'Footer Tagline',
          section: 'Branding & Header',
          valueEn: 'Preserving authentic Gujarati folk music, poetry, and cultural traditions in Rajkot since 1977.',
          valueGu: 'રાજકોટમાં ૧૯૭૭થી પરંપરાગત ગુજરાતી લોકસંગીત, પ્રાચીન કાવ્ય અને ભક્તિમય સંસ્કૃતિનું અવિરત જતન.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'footer_motto',
          label: 'Footer Devotional Motto',
          section: 'Branding & Header',
          valueEn: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
          valueGu: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
        ),
        AdminContentField(
          key: 'sec_pillars_tag',
          label: 'Pillars Section Eyebrow Tag',
          section: 'Sacred Foundations',
          valueEn: '02 / SACRED FOUNDATIONS',
          valueGu: '૦૨ / પવિત્ર સ્તંભો',
        ),
        AdminContentField(
          key: 'sec_pillars_title',
          label: 'Pillars Section Headline',
          section: 'Sacred Foundations',
          valueEn: 'Poetry, Rhythm & Divine Grace',
          valueGu: 'કાવ્ય, લય અને દિવ્ય કૃપા',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'sec_singers_tag',
          label: 'Singers Section Eyebrow Tag',
          section: 'Folk Artists Troupe',
          valueEn: 'LIVE ORCHESTRA & FOLK VOCALISTS',
          valueGu: 'જીવંત વાદ્યવૃંદ અને લોકગાયકો',
        ),
        AdminContentField(
          key: 'sec_singers_title',
          label: 'Singers Section Headline',
          section: 'Folk Artists Troupe',
          valueEn: 'Soulful Devotional Melodies',
          valueGu: 'ભાવપૂર્ણ ભક્તિના સૂર',
        ),
        AdminContentField(
          key: 'sec_singers_desc',
          label: 'Singers Section Subtitle',
          section: 'Folk Artists Troupe',
          valueEn: 'Accompanied by traditional acoustic instruments like Dhol, Tabla, Shehnai, and Harmonium without modern synthetic tracks.',
          valueGu: 'ઢોલ, તબલા, શરણાઈ અને હાર્મોનિયમ જેવા પ્રાચીન વાદ્યોના જીવંત સંગાથે પવિત્ર ગરબીઓનું ગાન.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'sec_opinions_tag',
          label: 'Blessings Section Eyebrow Tag',
          section: 'Elders Blessings',
          valueEn: 'WORDS OF BLESSINGS & GRACE',
          valueGu: 'આશીર્વાદ અને શુભકામનાઓ',
        ),
        AdminContentField(
          key: 'sec_opinions_title',
          label: 'Blessings Section Headline',
          section: 'Elders Blessings',
          valueEn: 'Elders & Dignitaries Reflections',
          valueGu: 'વડીલો અને સંત-મહાનુભાવોના અભિપ્રાય',
        ),
        AdminContentField(
          key: 'sec_blog_tag',
          label: 'Articles Section Eyebrow Tag',
          section: 'Cultural Stories & Articles',
          valueEn: '07 / CULTURAL STORIES & ARTICLES',
          valueGu: '૦૭ / સાંસ્કૃતિક વાતો અને લેખો',
        ),
        AdminContentField(
          key: 'sec_blog_title',
          label: 'Articles Section Headline',
          section: 'Cultural Stories & Articles',
          valueEn: 'Heritage, Meaning & Reflections',
          valueGu: 'વારસો, ગૌરવ અને આધ્યાત્મિક ચિંતન',
        ),
        AdminContentField(
          key: 'home_cta_invocation',
          label: 'CTA Top Sacred Chant',
          section: 'Call To Action Banner',
          valueEn: '|| Jagti Jogmaya ||',
          valueGu: '|| જાગતી જોગમાયા ||',
        ),
        AdminContentField(
          key: 'home_cta_motto',
          label: 'CTA Motto Headline',
          section: 'Call To Action Banner',
          valueEn: 'Connect with our sacred tradition and feel the divine presence of Maa Ambe.',
          valueGu: 'આપણી પ્રાચીન સંસ્કૃતિ, પરંપરા અને ભક્તિ સાથે જોડાઓ અને માં અંબાના આશીર્વાદ પ્રાપ્ત કરો.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'home_cta_btn_text',
          label: 'CTA Action Button Label',
          section: 'Call To Action Banner',
          valueEn: 'Connect With Us',
          valueGu: 'સંપર્ક કરો / સહભાગી બનો',
        ),
        AdminContentField(key: 'home_cta_btn_route', label: 'CTA Action Button Route', section: 'Call To Action Banner', valueEn: '/contact', valueGu: '/contact'),
        // About Us Page Fields
        AdminContentField(key: 'about_tag', label: 'Header Eyebrow Badge Tag', section: 'About Page', valueEn: 'ABOUT THE MANDAL', valueGu: 'મંડળ પરિચય'),
        AdminContentField(
          key: 'about_title',
          label: 'Main Page Headline',
          section: 'About Page',
          valueEn: 'Shree Pavan Putra Prachin Garbi Mandal',
          valueGu: 'શ્રી પવનપુત્ર પ્રાચીન ગરબી મંડળ',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'about_desc',
          label: 'Introduction Paragraph',
          section: 'About Page',
          valueEn: 'A devoted cultural institution in Rajkot, Gujarat, steadfastly committed to the preservation and authentic celebration of Prachin Garbi since 1989.',
          valueGu: '૧૯૮૯થી રાજકોટમાં અસલ ગુજરાતી પ્રાચીન ગરબીની પવિત્ર અને શુદ્ધ પરંપરાને જીવંત રાખતું ભાવિક સાંસ્કૃતિક મંડળ.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'about_history_title',
          label: 'Foundation Card Headline',
          section: 'About Page',
          valueEn: 'Preserving Sacred Traditions since 1989',
          valueGu: '૧૯૮૯થી અવિરત ધબકતી પવિત્ર ગરબી પરંપરા',
        ),
        AdminContentField(
          key: 'about_history_desc',
          label: 'Foundation Sacred History Body',
          section: 'About Page',
          valueEn:
              'Founded by devoted community elders in Rajkot, the Mandal was born out of a profound commitment: to worship Maa Jagti Jogmaya through classical Saurashtra Garbi, retaining natural live instrumentation, spiritual lyricism, and communal harmony without commercial compromises.',
          valueGu: 'રાજકોટના ભક્તિનગર ચોકમાં મા અંબા અને મા મોગલની અખંડ જ્યોત સામે, કોઈપણ કૃત્રિમ સાઉન્ડ વગર કેવળ પરંપરાગત સૂર અને સાધનાભાવથી આ ગરબીની સ્થાપના કરવામાં આવી હતી.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'about_foundation_motto',
          label: 'Foundation Devotional Motto',
          section: 'About Page',
          valueEn: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
          valueGu: '|| જાગતી જોગમાયા|| પરંપરા • ભક્તિ • સૂર',
        ),
        AdminContentField(
          key: 'about_foundation_image',
          label: 'Foundation Historical Emblem / Photo',
          section: 'About Page',
          valueEn: 'assets/images/pavan_putra_logo.jpg',
          valueGu: 'assets/images/pavan_putra_logo.jpg',
        ),
        AdminContentField(key: 'about_values_tag', label: 'Principles Eyebrow Badge', section: 'About Page', valueEn: 'CORE PILLARS', valueGu: 'પાયાના આધારસ્તંભ'),
        AdminContentField(
          key: 'about_values_title',
          label: 'Principles Section Title',
          section: 'About Page',
          valueEn: 'Core Principles of the Mandal',
          valueGu: 'મંડળના પાયાના સિદ્ધાંતો',
        ),
        AdminContentField(
          key: 'about_committee_badge',
          label: 'Committee Eyebrow Badge',
          section: 'About Page',
          valueEn: 'TRUSTEES & ORGANIZING COMMITTEE',
          valueGu: 'ટ્રસ્ટી મંડળ અને સમિતિ',
        ),
        AdminContentField(
          key: 'about_committee_title',
          label: 'Committee Section Title',
          section: 'About Page',
          valueEn: 'Devoted Trustees & Committee Leadership',
          valueGu: 'સેવાભાવી ટ્રસ્ટી અને સમિતિ સભ્યો',
        ),
        AdminContentField(
          key: 'about_committee_desc',
          label: 'Committee Section Description',
          section: 'About Page',
          valueEn: 'Dedicated guardians upholding the sacred Gujarati acoustic traditions and community seva in Rajkot.',
          valueGu: 'રાજકોટમાં પ્રાચીન ગરબીની ભવ્ય પરંપરા અને સંસ્કૃતિને જીવંત રાખતા મા અંબેના અનન્ય સેવકો.',
          isMultiline: true,
        ),
        AdminContentField(
          key: 'about_cta_title',
          label: 'History Callout Headline',
          section: 'About Page',
          valueEn: 'A History of Devotion & Cultural Fortitude',
          valueGu: 'ભક્તિ અને સાંસ્કૃતિક ગૌરવનો ભવ્ય ઇતિહાસ',
        ),
        AdminContentField(
          key: 'about_cta_desc',
          label: 'History Callout Subtitle',
          section: 'About Page',
          valueEn: 'Discover four decades of unwavering dedication to Maa Ambe in Rajkot.',
          valueGu: 'રાજકોટમાં સાડા ત્રણ દાયકાથી અવિરત ચાલી રહેલી પવિત્ર યાત્રાનો સંપૂર્ણ ઇતિહાસ જાણો.',
        ),
        AdminContentField(key: 'about_cta_btn_text', label: 'History Callout Button Label', section: 'About Page', valueEn: 'EXPLORE HISTORY', valueGu: 'ઇતિહાસ જુઓ'),
        AdminContentField(key: 'about_cta_route', label: 'History Callout Destination Route', section: 'About Page', valueEn: '/history', valueGu: '/history'),
      ];
      for (final f in officialSiteContent) {
        if (!_siteContentMap.containsKey(f.key)) {
          _siteContentMap[f.key] = f;
        }
      }
    } catch (e) {
      debugPrint('Site content fetch notice: $e');
    }
  }

  Future<void> _fetchHomeBanners(FirebaseFirestore db) async {
    try {
      final hbSnap = await db.collection('home_banners').get();
      if (hbSnap.docs.isNotEmpty) {
        _homeBanners.clear();
        for (final doc in hbSnap.docs) {
          _homeBanners.add(AdminHomeBanner.fromMap(doc.data()));
        }
        _homeBanners.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Home banners fetch notice: $e');
    }
  }

  Future<void> _fetchHomeAboutCards(FirebaseFirestore db) async {
    try {
      final acSnap = await db.collection('home_about_cards').get();
      if (acSnap.docs.isNotEmpty) {
        _aboutCards.clear();
        for (final doc in acSnap.docs) {
          _aboutCards.add(AdminAboutCard.fromMap(doc.data()));
        }
        _aboutCards.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('About cards fetch notice: $e');
    }
  }

  Future<void> _fetchPillars(FirebaseFirestore db) async {
    try {
      final pillarsSnap = await db.collection('home_pillars').get();
      if (pillarsSnap.docs.isNotEmpty) {
        _pillars.clear();
        for (final doc in pillarsSnap.docs) {
          _pillars.add(AdminHomePillar.fromMap(doc.data()));
        }
        _pillars.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Pillars fetch notice: $e');
    }
  }

  Future<void> _fetchHomeSingers(FirebaseFirestore db) async {
    try {
      final hsSnap = await db.collection('home_singers').get();
      if (hsSnap.docs.isNotEmpty) {
        _homeSingers.clear();
        for (final doc in hsSnap.docs) {
          _homeSingers.add(AdminHomeSinger.fromMap(doc.data()));
        }
        _homeSingers.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Singers fetch notice: $e');
    }
  }

  Future<void> _fetchBlessings(FirebaseFirestore db) async {
    try {
      final blessingsSnap = await db.collection('home_blessings').get();
      if (blessingsSnap.docs.isNotEmpty) {
        _blessings.clear();
        for (final doc in blessingsSnap.docs) {
          _blessings.add(AdminHomeBlessing.fromMap(doc.data()));
        }
        _blessings.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Blessings fetch notice: $e');
    }
  }

  Future<void> _fetchFooter(FirebaseFirestore db) async {
    try {
      final results = await Future.wait([
        db.collection('footer_links').get(),
        db.collection('footer_social_links').get(),
      ]);
      final fLinksSnap = results[0];
      if (fLinksSnap.docs.isNotEmpty) {
        _footerLinks.clear();
        for (final doc in fLinksSnap.docs) {
          _footerLinks.add(AdminFooterLink.fromMap(doc.data()));
        }
        _footerLinks.sort((a, b) => a.order.compareTo(b.order));
      }
      final fSocSnap = results[1];
      if (fSocSnap.docs.isNotEmpty) {
        _footerSocialLinks.clear();
        for (final doc in fSocSnap.docs) {
          _footerSocialLinks.add(AdminFooterSocialLink.fromMap(doc.data()));
        }
        _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Footer fetch notice: $e');
    }
  }

  Future<void> _fetchLiveStream(FirebaseFirestore db) async {
    try {
      final liveDoc = await db.collection('live_stream').doc('current').get();
      if (liveDoc.exists && liveDoc.data() != null && liveDoc.data()!.isNotEmpty) {
        _liveStreamSettings = AdminLiveStreamSettings.fromMap(liveDoc.data()!);
      }
    } catch (e) {
      debugPrint('Live stream fetch notice: $e');
    }
  }

  Future<void> _fetchGarbiYears(FirebaseFirestore db) async {
    try {
      final yearsSnap = await db.collection('garbi_years').get();
      if (yearsSnap.docs.isNotEmpty) {
        _years.clear();
        for (final doc in yearsSnap.docs) {
          _years.add(AdminGarbiYear.fromMap(doc.data()));
        }
        _years.sort((a, b) => b.year.compareTo(a.year));
      }
    } catch (e) {
      debugPrint('Years fetch notice: $e');
    }
  }

  Future<void> _fetchAlbums(FirebaseFirestore db) async {
    try {
      final albumsSnap = await db.collection('albums').get();
      if (albumsSnap.docs.isNotEmpty) {
        _albums.clear();
        for (final doc in albumsSnap.docs) {
          _albums.add(AdminAlbum.fromMap(doc.data()));
        }
      }
    } catch (e) {
      debugPrint('Albums fetch notice: $e');
    }
  }

  Future<void> _fetchHomeVideosPreview(FirebaseFirestore db) async {
    try {
      // Query published videos with limit 6 for Home Screen preview
      final videosSnap = await db.collection('videos').where('isPublished', isEqualTo: true).limit(6).get();
      if (videosSnap.docs.isNotEmpty) {
        _videos.clear();
        for (final doc in videosSnap.docs) {
          _videos.add(AdminVideo.fromMap(doc.data()));
        }
      }
    } catch (e) {
      debugPrint('Home videos preview notice: $e');
    }
  }

  Future<void> _fetchHomeBlogsPreview(FirebaseFirestore db) async {
    try {
      // Limit 3 for Home Screen preview
      final blogsSnap = await db.collection('blogs').limit(3).get();
      if (blogsSnap.docs.isNotEmpty) {
        _blogs.clear();
        for (final doc in blogsSnap.docs) {
          _blogs.add(AdminBlog.fromMap(doc.data()));
        }
      }
    } catch (e) {
      debugPrint('Home blogs preview notice: $e');
    }
  }

  bool _hasLocalCache = false;
  bool get hasLocalCache => _hasLocalCache;

  String _lastLocalUpdatedAt = '';
  String get lastLocalUpdatedAt => _lastLocalUpdatedAt;
  static const String _kSyncMetadataKey = 'ppg_last_synced_timestamp';

  /// Rapidly loads all cached Firestore data from local storage (SharedPreferences) in <5ms.
  /// Used for instantaneous second-time app opening without waiting for Firebase.
  Future<bool> loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastLocalUpdatedAt = prefs.getString(_kSyncMetadataKey) ?? '';

      // 1. Settings
      final settingsJson = prefs.getString('ppg_cache_settings');
      if (settingsJson != null && settingsJson.isNotEmpty) {
        final map = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = AdminSettings.fromMap(map);
      }

      // 2. Site Content
      final contentJson = prefs.getString('ppg_cache_site_content');
      if (contentJson != null && contentJson.isNotEmpty) {
        final list = jsonDecode(contentJson) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final f = AdminContentField.fromMap(item);
            _siteContentMap[f.key] = f;
          }
        }
      }

      // 3. Home Banners
      final bannersJson = prefs.getString('ppg_cache_home_banners');
      if (bannersJson != null && bannersJson.isNotEmpty) {
        final list = jsonDecode(bannersJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _homeBanners.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _homeBanners.add(AdminHomeBanner.fromMap(item));
            }
          }
          _homeBanners.sort((a, b) => a.order.compareTo(b.order));
        }
      }

      // 4. Home About Cards
      final cardsJson = prefs.getString('ppg_cache_home_about_cards');
      if (cardsJson != null && cardsJson.isNotEmpty) {
        final list = jsonDecode(cardsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _aboutCards.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _aboutCards.add(AdminAboutCard.fromMap(item));
            }
          }
          _aboutCards.sort((a, b) => a.order.compareTo(b.order));
        }
      }

      // 5. Pillars
      final pillarsJson = prefs.getString('ppg_cache_home_pillars');
      if (pillarsJson != null && pillarsJson.isNotEmpty) {
        final list = jsonDecode(pillarsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _pillars.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _pillars.add(AdminHomePillar.fromMap(item));
            }
          }
        }
      }

      // 6. Singers
      final singersJson = prefs.getString('ppg_cache_home_singers');
      if (singersJson != null && singersJson.isNotEmpty) {
        final list = jsonDecode(singersJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _homeSingers.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _homeSingers.add(AdminHomeSinger.fromMap(item));
            }
          }
        }
      }

      // 7. Blessings
      final blessingsJson = prefs.getString('ppg_cache_home_blessings');
      if (blessingsJson != null && blessingsJson.isNotEmpty) {
        final list = jsonDecode(blessingsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _blessings.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _blessings.add(AdminHomeBlessing.fromMap(item));
            }
          }
        }
      }

      // 8. Footer Social Links
      final footerJson = prefs.getString('ppg_cache_footer_social_links');
      if (footerJson != null && footerJson.isNotEmpty) {
        final list = jsonDecode(footerJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _footerSocialLinks.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _footerSocialLinks.add(AdminFooterSocialLink.fromMap(item));
            }
          }
        }
      }

      // 9. Live Stream
      final liveJson = prefs.getString('ppg_cache_live_stream');
      if (liveJson != null && liveJson.isNotEmpty) {
        final map = jsonDecode(liveJson) as Map<String, dynamic>;
        _liveStreamSettings = AdminLiveStreamSettings.fromMap(map);
      }

      // 10. Garbi Years
      final yearsJson = prefs.getString('ppg_cache_garbi_years');
      if (yearsJson != null && yearsJson.isNotEmpty) {
        final list = jsonDecode(yearsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _years.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _years.add(AdminGarbiYear.fromMap(item));
            }
          }
        }
      }

      // 11. Albums
      final albumsJson = prefs.getString('ppg_cache_albums');
      if (albumsJson != null && albumsJson.isNotEmpty) {
        final list = jsonDecode(albumsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _albums.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _albums.add(AdminAlbum.fromMap(item));
            }
          }
        }
      }

      // 12. Videos
      final videosJson = prefs.getString('ppg_cache_videos');
      if (videosJson != null && videosJson.isNotEmpty) {
        final list = jsonDecode(videosJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _videos.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _videos.add(AdminVideo.fromMap(item));
            }
          }
        }
      }

      // 13. Blogs
      final blogsJson = prefs.getString('ppg_cache_blogs');
      if (blogsJson != null && blogsJson.isNotEmpty) {
        final list = jsonDecode(blogsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _blogs.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _blogs.add(AdminBlog.fromMap(item));
            }
          }
        }
      }

      // 14. Committee Members
      final cmJson = prefs.getString('ppg_cache_committee_members');
      if (cmJson != null && cmJson.isNotEmpty) {
        final list = jsonDecode(cmJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _committeeMembers.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _committeeMembers.add(AdminCommitteeMember.fromMap(item));
            }
          }
          _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
        }
      }

      // 15. About Principles
      final prJson = prefs.getString('ppg_cache_about_principles');
      if (prJson != null && prJson.isNotEmpty) {
        final list = jsonDecode(prJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _aboutPrinciples.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _aboutPrinciples.add(AdminAboutPrinciple.fromMap(item));
            }
          }
          _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
        }
      }

      // 16. History Milestones
      final hmJson = prefs.getString('ppg_cache_history_milestones');
      if (hmJson != null && hmJson.isNotEmpty) {
        final list = jsonDecode(hmJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _historyMilestones.clear();
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              _historyMilestones.add(AdminHistoryMilestone.fromMap(item));
            }
          }
          _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
        }
      }

      if (_settings.mandalNameEn.isNotEmpty || _siteContentMap.isNotEmpty || _homeBanners.isNotEmpty) {
        _hasLocalCache = true;
        _isInitialized = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Local storage restore notice: $e');
    }
    return false;
  }

  /// Checks if remote Firestore data has changed since our last cached sync.
  /// Uses a single lightweight document read.
  /// Returns false if nothing has changed (0 further queries needed!).
  /// Returns true if changes exist or cold launch.
  Future<bool> checkForRemoteChanges() async {
    final db = _firestore;
    if (db == null) return false;
    try {
      final metaDoc = await db.collection('settings').doc('sync_metadata').get();
      String remoteTimestamp = '';
      if (metaDoc.exists && metaDoc.data() != null) {
        remoteTimestamp = metaDoc.data()!['last_updated_at'] as String? ?? '';
      }

      // Fallback to mandal_settings if sync_metadata is not yet present
      if (remoteTimestamp.isEmpty) {
        final settingsDoc = await db.collection('settings').doc('mandal_settings').get();
        if (settingsDoc.exists && settingsDoc.data() != null) {
          remoteTimestamp = settingsDoc.data()!['updated_at'] as String? ?? '';
        }
      }

      if (remoteTimestamp.isNotEmpty && _lastLocalUpdatedAt.isNotEmpty) {
        if (remoteTimestamp == _lastLocalUpdatedAt) {
          debugPrint('Remote data unchanged ($remoteTimestamp). Skipping redundant Firestore queries.');
          return false;
        }
      }

      _lastLocalUpdatedAt = remoteTimestamp.isNotEmpty ? remoteTimestamp : DateTime.now().toIso8601String();
      return true;
    } catch (e) {
      debugPrint('Check for remote changes notice: $e');
      return false;
    }
  }

  /// Saves critical first-viewport data into device local storage
  Future<void> _saveEssentialToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_lastLocalUpdatedAt.isEmpty) {
        _lastLocalUpdatedAt = DateTime.now().toIso8601String();
      }
      await Future.wait([
        prefs.setString('ppg_cache_settings', jsonEncode(_settings.toMap())),
        prefs.setString('ppg_cache_site_content', jsonEncode(_siteContentMap.values.map((f) => f.toMap()).toList())),
        prefs.setString('ppg_cache_home_banners', jsonEncode(_homeBanners.map((b) => b.toMap()).toList())),
        prefs.setString('ppg_cache_home_about_cards', jsonEncode(_aboutCards.map((c) => c.toMap()).toList())),
        prefs.setString(_kSyncMetadataKey, _lastLocalUpdatedAt),
      ]);
      _hasLocalCache = true;
    } catch (e) {
      debugPrint('Failed to save essential data to local storage: $e');
    }
  }

  /// Saves secondary background-loaded data into device local storage
  Future<void> _saveBackgroundToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('ppg_cache_home_pillars', jsonEncode(_pillars.map((p) => p.toMap()).toList())),
        prefs.setString('ppg_cache_home_singers', jsonEncode(_homeSingers.map((s) => s.toMap()).toList())),
        prefs.setString('ppg_cache_home_blessings', jsonEncode(_blessings.map((b) => b.toMap()).toList())),
        prefs.setString('ppg_cache_footer_social_links', jsonEncode(_footerSocialLinks.map((f) => f.toMap()).toList())),
        prefs.setString('ppg_cache_live_stream', jsonEncode(_liveStreamSettings.toMap())),
        prefs.setString('ppg_cache_garbi_years', jsonEncode(_years.map((y) => y.toMap()).toList())),
        prefs.setString('ppg_cache_albums', jsonEncode(_albums.map((a) => a.toMap()).toList())),
        prefs.setString('ppg_cache_videos', jsonEncode(_videos.map((v) => v.toMap()).toList())),
        prefs.setString('ppg_cache_blogs', jsonEncode(_blogs.map((b) => b.toMap()).toList())),
        prefs.setString('ppg_cache_committee_members', jsonEncode(_committeeMembers.map((c) => c.toMap()).toList())),
        prefs.setString('ppg_cache_about_principles', jsonEncode(_aboutPrinciples.map((p) => p.toMap()).toList())),
        prefs.setString('ppg_cache_history_milestones', jsonEncode(_historyMilestones.map((h) => h.toMap()).toList())),
      ]);
    } catch (e) {
      debugPrint('Failed to save background data to local storage: $e');
    }
  }

  /// Priority 1: Initialize ONLY the critical first-viewport data concurrently (~150-250ms)
  Future<void> initializeEssentialFirstViewport({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // If local cache is present and we are not forcing refresh, check if remote data changed
    if (_hasLocalCache && !forceRefresh) {
      final hasChanges = await checkForRemoteChanges();
      if (!hasChanges) {
        // Nothing changed! Everything is already fresh in memory & local storage.
        _isFirestoreConnected = true;
        _isInitialized = true;
        notifyListeners();
        return;
      }
    }

    try {
      await Future.wait([
        _fetchSettings(db),
        _fetchSiteContent(db),
        _fetchHomeAboutCards(db),
        _fetchHomeBanners(db),
      ]);
      _isFirestoreConnected = true;
      unawaited(_saveEssentialToLocalStorage());
    } catch (e) {
      debugPrint('Essential first-viewport fetch notice: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  bool _isBackgroundLoadingStarted = false;

  /// Priority 2: Staged gentle background loading (throttled micro-batches, no network congestion)
  Future<void> startGentleBackgroundLoading({bool forceRefresh = false}) async {
    if (_isBackgroundLoadingStarted) return;
    _isBackgroundLoadingStarted = true;
    final db = _firestore;
    if (db == null) return;

    // If we have local cache and forceRefresh is false, all background items are ALREADY in memory!
    // Simply attach real-time listeners for live events and skip re-fetching all collections over the network!
    if (_hasLocalCache && !forceRefresh) {
      _listenToRealtimeUpdates(db);
      return;
    }

    try {
      // Stage A: Home Mid-Fold (pillars, singers, blessings)
      await Future.wait([
        _fetchPillars(db),
        _fetchHomeSingers(db),
        _fetchBlessings(db),
      ]);
      notifyListeners();

      // Gentle pause to yield CPU & keep 60fps
      await Future.delayed(const Duration(milliseconds: 60));

      // Stage B: Home Lower-Fold & Footer
      await Future.wait([
        _fetchFooter(db),
        _fetchLiveStream(db),
      ]);
      notifyListeners();

      // Gentle pause to yield CPU
      await Future.delayed(const Duration(milliseconds: 60));

      // Stage C: Home Previews with limits (years, top 6 videos, top 3 blogs, albums)
      await Future.wait([
        _fetchGarbiYears(db),
        _fetchHomeVideosPreview(db),
        _fetchHomeBlogsPreview(db),
        _fetchAlbums(db),
      ]);
      notifyListeners();

      unawaited(_saveBackgroundToLocalStorage());
      _listenToRealtimeUpdates(db);
    } catch (e) {
      debugPrint('Gentle background loading notice: $e');
    }
  }

  /// Standard entry point: fast first viewport + gentle background loading
  Future<void> initializeFromFirestore() async {
    await initializeEssentialFirstViewport(forceRefresh: true);
    unawaited(startGentleBackgroundLoading(forceRefresh: true));
  }

  // --- On-Demand Screen-Level Loaders ---

  bool _isGalleryLoaded = false;
  Future<void> ensureGalleryLoaded([String? year, String? album]) async {
    final db = _firestore;
    if (db == null || _isGalleryLoaded) return;
    try {
      final snap = await db.collection('photos').get();
      if (snap.docs.isNotEmpty) {
        _photos.clear();
        for (final doc in snap.docs) {
          _photos.add(AdminPhoto.fromMap(doc.data()));
        }
        _isGalleryLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gallery on-demand load notice: $e');
    }
  }

  bool _isAboutDetailsLoaded = false;
  Future<void> ensureAboutPageLoaded() async {
    final db = _firestore;
    if (db == null || _isAboutDetailsLoaded) return;
    try {
      final results = await Future.wait([
        db.collection('committee_members').get(),
        db.collection('about_principles').get(),
      ]);
      final cmSnap = results[0];
      _committeeMembers.clear();
      for (final doc in cmSnap.docs) {
        _committeeMembers.add(AdminCommitteeMember.fromMap(doc.data()));
      }
      _committeeMembers.sort((a, b) => a.order.compareTo(b.order));

      final prSnap = results[1];
      _aboutPrinciples.clear();
      for (final doc in prSnap.docs) {
        _aboutPrinciples.add(AdminAboutPrinciple.fromMap(doc.data()));
      }
      _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
      _isAboutDetailsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('About page on-demand load notice: $e');
    }
  }

  bool _isHistoryLoaded = false;
  Future<void> ensureHistoryLoaded() async {
    final db = _firestore;
    if (db == null || _isHistoryLoaded) return;
    try {
      final hmSnap = await db.collection('history_milestones').get();
      if (hmSnap.docs.isNotEmpty) {
        _historyMilestones.clear();
        for (final doc in hmSnap.docs) {
          _historyMilestones.add(AdminHistoryMilestone.fromMap(doc.data()));
        }
        _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
        _isHistoryLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('History on-demand load notice: $e');
    }
  }

  bool _isFullVideosLoaded = false;
  Future<void> ensureVideosLoaded() async {
    final db = _firestore;
    if (db == null || _isFullVideosLoaded) return;
    try {
      final snap = await db.collection('videos').get();
      if (snap.docs.isNotEmpty) {
        _videos.clear();
        for (final doc in snap.docs) {
          _videos.add(AdminVideo.fromMap(doc.data()));
        }
        _isFullVideosLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Videos on-demand load notice: $e');
    }
  }

  bool _isFullBlogsLoaded = false;
  Future<void> ensureBlogsLoaded() async {
    final db = _firestore;
    if (db == null || _isFullBlogsLoaded) return;
    try {
      final snap = await db.collection('blogs').get();
      if (snap.docs.isNotEmpty) {
        _blogs.clear();
        for (final doc in snap.docs) {
          _blogs.add(AdminBlog.fromMap(doc.data()));
        }
        _isFullBlogsLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Blogs on-demand load notice: $e');
    }
  }

  bool _isAdminDataLoaded = false;
  Future<void> ensureAdminDataLoaded() async {
    final db = _firestore;
    if (db == null || _isAdminDataLoaded) return;
    try {
      final results = await Future.wait([
        db.collection('enquiries').get(),
        db.collection('activity_logs').get(),
        ensureGalleryLoaded(),
        ensureVideosLoaded(),
        ensureBlogsLoaded(),
        ensureAboutPageLoaded(),
        ensureHistoryLoaded(),
      ]);
      final enqSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      _enquiries.clear();
      for (final doc in enqSnap.docs) {
        _enquiries.add(AdminEnquiry.fromMap(doc.data()));
      }
      final logsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
      _activityLogs.clear();
      for (final doc in logsSnap.docs) {
        _activityLogs.add(AdminActivityLog.fromMap(doc.data()));
      }
      _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isAdminDataLoaded = true;
      _listenToAdminRealtimeUpdates(db);
      notifyListeners();
    } catch (e) {
      debugPrint('Admin data load notice: $e');
    }
  }

  bool _adminListenersAttached = false;
  void _listenToAdminRealtimeUpdates(FirebaseFirestore db) {
    if (_adminListenersAttached) return;
    _adminListenersAttached = true;

    db.collection('enquiries').snapshots().listen((snap) {
      _enquiries.clear();
      for (final doc in snap.docs) {
        _enquiries.add(AdminEnquiry.fromMap(doc.data()));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Enquiries stream notice: $e'));

    db.collection('activity_logs').snapshots().listen((snap) {
      _activityLogs.clear();
      for (final doc in snap.docs) {
        _activityLogs.add(AdminActivityLog.fromMap(doc.data()));
      }
      _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    }, onError: (e) => debugPrint('Logs stream notice: $e'));
  }

  bool _listenersAttached = false;

  void _listenToRealtimeUpdates(FirebaseFirestore db) {
    if (_listenersAttached) return;
    _listenersAttached = true;

    db.collection('settings').doc('mandal_settings').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _settings = AdminSettings.fromMap(doc.data()!);
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Settings stream notice: $e'));

    db.collection('committee_members').snapshots().listen((snap) {
      _committeeMembers.clear();
      for (final doc in snap.docs) {
        _committeeMembers.add(AdminCommitteeMember.fromMap(doc.data()));
      }
      _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Committee stream notice: $e'));

    db.collection('about_principles').snapshots().listen((snap) {
      _aboutPrinciples.clear();
      for (final doc in snap.docs) {
        _aboutPrinciples.add(AdminAboutPrinciple.fromMap(doc.data()));
      }
      _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('About principles stream notice: $e'));

    db.collection('history_milestones').snapshots().listen((snap) {
      _historyMilestones.clear();
      for (final doc in snap.docs) {
        _historyMilestones.add(AdminHistoryMilestone.fromMap(doc.data()));
      }
      _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('History stream notice: $e'));

    db.collection('home_singers').snapshots().listen((snap) {
      _homeSingers.clear();
      for (final doc in snap.docs) {
        _homeSingers.add(AdminHomeSinger.fromMap(doc.data()));
      }
      _homeSingers.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Singers stream notice: $e'));

    db.collection('home_banners').snapshots().listen((snap) {
      _homeBanners.clear();
      for (final doc in snap.docs) {
        _homeBanners.add(AdminHomeBanner.fromMap(doc.data()));
      }
      _homeBanners.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Banners stream notice: $e'));

    db.collection('site_content').snapshots().listen((snap) {
      for (final doc in snap.docs) {
        final f = AdminContentField.fromMap(doc.data());
        _siteContentMap[f.key] = f;
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Site content stream notice: $e'));

    db.collection('home_about_cards').snapshots().listen((snap) {
      _aboutCards.clear();
      for (final doc in snap.docs) {
        _aboutCards.add(AdminAboutCard.fromMap(doc.data()));
      }
      _aboutCards.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('About cards stream notice: $e'));

    db.collection('home_pillars').snapshots().listen((snap) {
      _pillars.clear();
      for (final doc in snap.docs) {
        _pillars.add(AdminHomePillar.fromMap(doc.data()));
      }
      _pillars.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Pillars stream notice: $e'));

    db.collection('home_blessings').snapshots().listen((snap) {
      _blessings.clear();
      for (final doc in snap.docs) {
        _blessings.add(AdminHomeBlessing.fromMap(doc.data()));
      }
      _blessings.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Blessings stream notice: $e'));

    db.collection('garbi_years').snapshots().listen((snap) {
      _years.clear();
      for (final doc in snap.docs) {
        _years.add(AdminGarbiYear.fromMap(doc.data()));
      }
      _years.sort((a, b) => b.year.compareTo(a.year));
      notifyListeners();
    }, onError: (e) => debugPrint('Years stream notice: $e'));

    db.collection('albums').snapshots().listen((snap) {
      _albums.clear();
      for (final doc in snap.docs) {
        _albums.add(AdminAlbum.fromMap(doc.data()));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Albums stream notice: $e'));

    db.collection('photos').snapshots().listen((snap) {
      _photos.clear();
      for (final doc in snap.docs) {
        _photos.add(AdminPhoto.fromMap(doc.data()));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Photos stream notice: $e'));

    db.collection('videos').snapshots().listen((snap) {
      _videos.clear();
      for (final doc in snap.docs) {
        _videos.add(AdminVideo.fromMap(doc.data()));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Videos stream notice: $e'));

    db.collection('live_stream').doc('current').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _liveStreamSettings = AdminLiveStreamSettings.fromMap(doc.data()!);
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Live stream notice: $e'));

    db.collection('blogs').snapshots().listen((snap) {
      _blogs.clear();
      for (final doc in snap.docs) {
        _blogs.add(AdminBlog.fromMap(doc.data()));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Blogs stream notice: $e'));

    db.collection('enquiries').snapshots().listen((snap) {
      _enquiries.clear();
      for (final doc in snap.docs) {
        _enquiries.add(AdminEnquiry.fromMap(doc.data()));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Enquiries stream notice: $e'));

    db.collection('activity_logs').snapshots().listen((snap) {
      _activityLogs.clear();
      for (final doc in snap.docs) {
        _activityLogs.add(AdminActivityLog.fromMap(doc.data()));
      }
      _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    }, onError: (e) => debugPrint('Logs stream notice: $e'));

    db.collection('footer_links').snapshots().listen((snap) {
      _footerLinks.clear();
      for (final doc in snap.docs) {
        _footerLinks.add(AdminFooterLink.fromMap(doc.data()));
      }
      _footerLinks.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Footer links stream notice: $e'));

    db.collection('footer_social_links').snapshots().listen((snap) {
      _footerSocialLinks.clear();
      for (final doc in snap.docs) {
        _footerSocialLinks.add(AdminFooterSocialLink.fromMap(doc.data()));
      }
      _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Footer social links stream notice: $e'));
  }

  Future<void> _touchSyncMetadata(FirebaseFirestore db) async {
    try {
      final now = DateTime.now().toIso8601String();
      _lastLocalUpdatedAt = now;
      await db.collection('settings').doc('sync_metadata').set({
        'last_updated_at': now,
      }, SetOptions(merge: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSyncMetadataKey, now);
    } catch (_) {}
  }

  Future<void> _writeToFirestore(String collection, String docId, Map<String, dynamic> data) async {
    final db = _firestore;
    if (db == null) return;
    try {
      await db.collection(collection).doc(docId).set(data, SetOptions(merge: true));
      _isFirestoreConnected = true;
      if (collection != 'activity_logs' && docId != 'sync_metadata') {
        unawaited(_touchSyncMetadata(db));
      }
    } catch (e) {
      debugPrint('Firestore write notice ($collection/$docId): $e');
    }
  }

  Future<void> _deleteFromFirestore(String collection, String docId) async {
    final db = _firestore;
    if (db == null) return;
    try {
      await db.collection(collection).doc(docId).delete();
      unawaited(_touchSyncMetadata(db));
    } catch (e) {
      debugPrint('Firestore delete notice ($collection/$docId): $e');
    }
  }

  Future<void> syncAllToFirestore() async {
    final db = _firestore;
    if (db == null) return;
    try {
      // Permanently remove unused site_pages collection from Firestore
      try {
        final pagesDocs = await db.collection('site_pages').get();
        for (final doc in pagesDocs.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      for (final cm in _committeeMembers) {
        await _writeToFirestore('committee_members', cm.id, cm.toMap());
      }
      for (final pr in _aboutPrinciples) {
        await _writeToFirestore('about_principles', pr.id, pr.toMap());
      }
      for (final hm in _historyMilestones) {
        await _writeToFirestore('history_milestones', hm.id, hm.toMap());
      }
      for (final hs in _homeSingers) {
        await _writeToFirestore('home_singers', hs.id, hs.toMap());
      }
      for (final hb in _homeBanners) {
        await _writeToFirestore('home_banners', hb.id, hb.toMap());
      }
      for (final f in _siteContentMap.values) {
        await _writeToFirestore('site_content', f.key, f.toMap());
      }
      for (final y in _years) {
        await _writeToFirestore('garbi_years', y.id, y.toMap());
      }
      for (final a in _albums) {
        await _writeToFirestore('albums', a.id, a.toMap());
      }
      for (final p in _photos) {
        await _writeToFirestore('photos', p.id, p.toMap());
      }
      for (final v in _videos) {
        await _writeToFirestore('videos', v.id, v.toMap());
      }
      await _writeToFirestore('live_stream', 'current', _liveStreamSettings.toMap());
      for (final b in _blogs) {
        await _writeToFirestore('blogs', b.id, b.toMap());
      }
      for (final e in _enquiries) {
        await _writeToFirestore('enquiries', e.id, e.toMap());
      }
      await _writeToFirestore('settings', 'mandal_settings', _settings.toMap());
      for (final l in _activityLogs) {
        await _writeToFirestore('activity_logs', l.id, l.toMap());
      }
      for (final ac in _aboutCards) {
        await _writeToFirestore('home_about_cards', ac.id, ac.toMap());
      }
      for (final p in _pillars) {
        await _writeToFirestore('home_pillars', p.id, p.toMap());
      }
      for (final bl in _blessings) {
        await _writeToFirestore('home_blessings', bl.id, bl.toMap());
      }

      logActivity('CONFIG', 'Website Sync', 'Saved and synchronized all website content and updates');
      notifyListeners();
    } catch (e) {
      debugPrint('Sync all to Firestore error: $e');
    }
  }




  Future<void> restoreDatabaseDefaults() async {
    _committeeMembers.clear();
    _aboutPrinciples.clear();
    _historyMilestones.clear();
    _homeSingers.clear();
    _homeBanners.clear();
    _years.clear();
    _albums.clear();
    _photos.clear();
    _videos.clear();
    _blogs.clear();
    _siteContentMap.clear();

    await syncAllToFirestore();
    logActivity('CONFIG', 'Default Content Restored', 'Restored default mandal website content and settings');
    notifyListeners();
  }

  // --- CRUD: Committee Members ---
  void addCommitteeMember(AdminCommitteeMember member) {
    _committeeMembers.add(member);
    _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'Committee', 'Added member: ${member.nameEn} (${member.designationEn})');
    _writeToFirestore('committee_members', member.id, member.toMap());
    notifyListeners();
  }

  void updateCommitteeMember(AdminCommitteeMember member) {
    final idx = _committeeMembers.indexWhere((c) => c.id == member.id);
    if (idx != -1) {
      _committeeMembers[idx] = member;
      _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
      logActivity('UPDATE', 'Committee', 'Updated member: ${member.nameEn}');
      _writeToFirestore('committee_members', member.id, member.toMap());
      notifyListeners();
    }
  }

  void deleteCommitteeMember(String id) {
    final item = _committeeMembers.firstWhere(
      (c) => c.id == id,
      orElse: () => const AdminCommitteeMember(id: '', nameEn: '', nameGu: '', designationEn: '', designationGu: ''),
    );
    _committeeMembers.removeWhere((c) => c.id == id);
    logActivity('DELETE', 'Committee', 'Deleted member: ${item.nameEn}');
    _deleteFromFirestore('committee_members', id);
    notifyListeners();
  }

  // --- CRUD: About Principles ---
  void addAboutPrinciple(AdminAboutPrinciple principle) {
    _aboutPrinciples.add(principle);
    _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'About Principles', 'Added principle: ${principle.titleEn}');
    _writeToFirestore('about_principles', principle.id, principle.toMap());
    notifyListeners();
  }

  void updateAboutPrinciple(AdminAboutPrinciple principle) {
    final idx = _aboutPrinciples.indexWhere((p) => p.id == principle.id);
    if (idx != -1) {
      _aboutPrinciples[idx] = principle;
      _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
      logActivity('UPDATE', 'About Principles', 'Updated principle: ${principle.titleEn}');
      _writeToFirestore('about_principles', principle.id, principle.toMap());
      notifyListeners();
    }
  }

  void deleteAboutPrinciple(String id) {
    final item = _aboutPrinciples.firstWhere((p) => p.id == id, orElse: () => AdminAboutPrinciple(id: id));
    _aboutPrinciples.removeWhere((p) => p.id == id);
    logActivity('DELETE', 'About Principles', 'Deleted principle: ${item.titleEn}');
    _deleteFromFirestore('about_principles', id);
    notifyListeners();
  }

  Future<void> saveAboutPageContent(AdminAboutPageData about) async {
    setSiteContentValue('about_tag', label: 'Header Eyebrow Badge Tag', section: 'About Page', valueEn: about.tagBadgeEn, valueGu: about.tagBadgeGu);
    setSiteContentValue('about_title', label: 'Main Page Headline', section: 'About Page', valueEn: about.titleEn, valueGu: about.titleGu, isMultiline: true);
    setSiteContentValue('about_desc', label: 'Introduction Paragraph', section: 'About Page', valueEn: about.descEn, valueGu: about.descGu, isMultiline: true);

    setSiteContentValue('about_history_title', label: 'Foundation Card Headline', section: 'About Page', valueEn: about.foundationTitleEn, valueGu: about.foundationTitleGu);
    setSiteContentValue(
      'about_history_desc',
      label: 'Foundation Sacred History Body',
      section: 'About Page',
      valueEn: about.foundationDescEn,
      valueGu: about.foundationDescGu,
      isMultiline: true,
    );
    setSiteContentValue('about_foundation_motto', label: 'Foundation Devotional Motto', section: 'About Page', valueEn: about.foundationMottoEn, valueGu: about.foundationMottoGu);
    setSiteContentValue(
      'about_foundation_image',
      label: 'Foundation Historical Emblem / Photo',
      section: 'About Page',
      valueEn: about.foundationImageUrl,
      valueGu: about.foundationImageUrl,
    );

    setSiteContentValue('about_values_tag', label: 'Principles Eyebrow Badge', section: 'About Page', valueEn: about.valuesTagEn, valueGu: about.valuesTagGu);
    setSiteContentValue('about_values_title', label: 'Principles Section Title', section: 'About Page', valueEn: about.valuesTitleEn, valueGu: about.valuesTitleGu);

    setSiteContentValue('about_committee_badge', label: 'Committee Eyebrow Badge', section: 'About Page', valueEn: about.committeeBadgeEn, valueGu: about.committeeBadgeGu);
    setSiteContentValue('about_committee_title', label: 'Committee Section Title', section: 'About Page', valueEn: about.committeeTitleEn, valueGu: about.committeeTitleGu);
    setSiteContentValue(
      'about_committee_desc',
      label: 'Committee Section Description',
      section: 'About Page',
      valueEn: about.committeeDescEn,
      valueGu: about.committeeDescGu,
      isMultiline: true,
    );

    setSiteContentValue('about_cta_title', label: 'History Callout Headline', section: 'About Page', valueEn: about.ctaTitleEn, valueGu: about.ctaTitleGu);
    setSiteContentValue('about_cta_desc', label: 'History Callout Subtitle', section: 'About Page', valueEn: about.ctaDescEn, valueGu: about.ctaDescGu);
    setSiteContentValue('about_cta_btn_text', label: 'History Callout Button Label', section: 'About Page', valueEn: about.ctaBtnTextEn, valueGu: about.ctaBtnTextGu);
    setSiteContentValue('about_cta_route', label: 'History Callout Destination Route', section: 'About Page', valueEn: about.ctaRoute, valueGu: about.ctaRoute);

    logActivity('UPDATE', 'About Page', 'Saved and published About Page content to website');
    notifyListeners();
  }

  // --- CRUD: History Milestones ---
  void addHistoryMilestone(AdminHistoryMilestone milestone) {
    _historyMilestones.add(milestone);
    _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'History', 'Added timeline milestone: ${milestone.year} (${milestone.titleEn})');
    _writeToFirestore('history_milestones', milestone.id, milestone.toMap());
    notifyListeners();
  }

  void updateHistoryMilestone(AdminHistoryMilestone milestone) {
    final idx = _historyMilestones.indexWhere((h) => h.id == milestone.id);
    if (idx != -1) {
      _historyMilestones[idx] = milestone;
      _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
      logActivity('UPDATE', 'History', 'Updated milestone: ${milestone.titleEn}');
      _writeToFirestore('history_milestones', milestone.id, milestone.toMap());
      notifyListeners();
    }
  }

  void deleteHistoryMilestone(String id) {
    final item = _historyMilestones.firstWhere(
      (h) => h.id == id,
      orElse: () => AdminHistoryMilestone(id: '', year: '', badgeEn: '', badgeGu: '', titleEn: '', titleGu: '', descEn: '', descGu: ''),
    );
    _historyMilestones.removeWhere((h) => h.id == id);
    logActivity('DELETE', 'History', 'Deleted milestone: ${item.year}');
    _deleteFromFirestore('history_milestones', id);
    notifyListeners();
  }

  // --- CRUD: Home Singers ---
  void addHomeSinger(AdminHomeSinger singer) {
    _homeSingers.add(singer);
    _homeSingers.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'Home Artists', 'Added vocalist/musician: ${singer.nameEn}');
    _writeToFirestore('home_singers', singer.id, singer.toMap());
    notifyListeners();
  }

  void updateHomeSinger(AdminHomeSinger singer) {
    final idx = _homeSingers.indexWhere((s) => s.id == singer.id);
    if (idx != -1) {
      _homeSingers[idx] = singer;
      _homeSingers.sort((a, b) => a.order.compareTo(b.order));
      logActivity('UPDATE', 'Home Artists', 'Updated artist: ${singer.nameEn}');
      _writeToFirestore('home_singers', singer.id, singer.toMap());
      notifyListeners();
    }
  }

  void deleteHomeSinger(String id) {
    final item = _homeSingers.firstWhere(
      (s) => s.id == id,
      orElse: () => AdminHomeSinger(id: '', nameEn: '', nameGu: '', roleEn: '', roleGu: '', descEn: '', descGu: ''),
    );
    _homeSingers.removeWhere((s) => s.id == id);
    logActivity('DELETE', 'Home Artists', 'Deleted artist: ${item.nameEn}');
    _deleteFromFirestore('home_singers', id);
    notifyListeners();
  }

  // --- CRUD: Home Banners ---
  void addHomeBanner(AdminHomeBanner banner) {
    _homeBanners.add(banner);
    _homeBanners.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'Home Banners', 'Added banner: "${banner.titleEn}"');
    _writeToFirestore('home_banners', banner.id, banner.toMap());
    notifyListeners();
  }

  void updateHomeBanner(AdminHomeBanner banner) {
    final idx = _homeBanners.indexWhere((b) => b.id == banner.id);
    if (idx != -1) {
      _homeBanners[idx] = banner;
      _homeBanners.sort((a, b) => a.order.compareTo(b.order));
      logActivity('UPDATE', 'Home Banners', 'Updated banner: "${banner.titleEn}"');
      _writeToFirestore('home_banners', banner.id, banner.toMap());
      notifyListeners();
    }
  }

  void deleteHomeBanner(String id) {
    final item = _homeBanners.firstWhere(
      (b) => b.id == id,
      orElse: () => AdminHomeBanner(id: '', badgeEn: '', badgeGu: '', titleEn: '', titleGu: '', subtitleEn: '', subtitleGu: ''),
    );
    _homeBanners.removeWhere((b) => b.id == id);
    logActivity('DELETE', 'Home Banners', 'Deleted banner: "${item.titleEn}"');
    _deleteFromFirestore('home_banners', id);
    notifyListeners();
  }

  // --- CRUD: Site Content ---
  void updateSiteContentField(String key, {String? valueEn, String? valueGu}) async {
    final existing = _siteContentMap[key];
    if (existing != null) {
      final finalEn = valueEn ?? existing.valueEn;
      var finalGu = valueGu ?? existing.valueGu;
      if ((valueGu == null || valueGu.trim().isEmpty) && finalEn.trim().isNotEmpty) {
        try {
          finalGu = await GoogleTranslationService.instance.translateToGujarati(finalEn);
        } catch (_) {}
      }
      _siteContentMap[key] = existing.copyWith(valueEn: finalEn, valueGu: finalGu);
      logActivity('UPDATE', 'Site Content', 'Updated text for "${existing.label}" ($key)');
      _writeToFirestore('site_content', key, _siteContentMap[key]!.toMap());
      notifyListeners();
    }
  }

  void addCustomContentField(AdminContentField field) async {
    var finalField = field;
    if (finalField.valueGu.trim().isEmpty && finalField.valueEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalField.valueEn);
        finalField = finalField.copyWith(valueGu: trans);
      } catch (_) {}
    }
    _siteContentMap[finalField.key] = finalField;
    logActivity('CREATE', 'Site Content', 'Added text key: ${finalField.key}');
    _writeToFirestore('site_content', finalField.key, finalField.toMap());
    notifyListeners();
  }

  void deleteCustomContentField(String key) {
    final removed = _siteContentMap.remove(key);
    if (removed != null) {
      logActivity('DELETE', 'Site Content', 'Deleted text key: $key');
      _deleteFromFirestore('site_content', key);
      notifyListeners();
    }
  }

  void setSiteContentValue(String key, {required String label, required String section, required String valueEn, required String valueGu, bool isMultiline = false}) {
    final existing = _siteContentMap[key];
    final field = existing != null
        ? existing.copyWith(valueEn: valueEn, valueGu: valueGu)
        : AdminContentField(key: key, label: label, section: section, valueEn: valueEn, valueGu: valueGu, isMultiline: isMultiline);
    _siteContentMap[key] = field;
    _writeToFirestore('site_content', key, field.toMap());
  }

  Future<void> saveHeroSection(AdminHeroData hero) async {
    setSiteContentValue('sacred_invocation', label: 'Sacred Invocation Motto', section: 'Branding & Header', valueEn: hero.sacredInvocationEn, valueGu: hero.sacredInvocationGu);
    setSiteContentValue('hero_tag', label: 'Hero Eyebrow Tag', section: 'Home Hero Section', valueEn: hero.tagBadgeEn, valueGu: hero.tagBadgeGu);
    setSiteContentValue('hero_title', label: 'Hero Main Headline', section: 'Home Hero Section', valueEn: hero.titleEn, valueGu: hero.titleGu, isMultiline: true);
    setSiteContentValue('hero_gujarati_motto', label: 'Hero Devotional Motto', section: 'Home Hero Section', valueEn: hero.mottoEn, valueGu: hero.mottoGu);
    setSiteContentValue('hero_description', label: 'Hero Introduction Paragraph', section: 'Home Hero Section', valueEn: hero.descEn, valueGu: hero.descGu, isMultiline: true);
    setSiteContentValue('hero_cta_archive', label: 'Primary CTA Button Label', section: 'Home Hero Section', valueEn: hero.ctaPrimaryTextEn, valueGu: hero.ctaPrimaryTextGu);
    setSiteContentValue('hero_cta_archive_route', label: 'Primary CTA Button Route', section: 'Home Hero Section', valueEn: hero.ctaPrimaryRoute, valueGu: hero.ctaPrimaryRoute);
    setSiteContentValue('hero_cta_about', label: 'Secondary CTA Button Label', section: 'Home Hero Section', valueEn: hero.ctaSecondaryTextEn, valueGu: hero.ctaSecondaryTextGu);
    setSiteContentValue(
      'hero_cta_about_route',
      label: 'Secondary CTA Button Route',
      section: 'Home Hero Section',
      valueEn: hero.ctaSecondaryRoute,
      valueGu: hero.ctaSecondaryRoute,
    );
    setSiteContentValue('hero_official_badge', label: 'Hero Bottom Official Badge', section: 'Home Hero Section', valueEn: hero.bottomBadgeEn, valueGu: hero.bottomBadgeGu);
    setSiteContentValue('hero_image_url', label: 'Hero Emblem Graphic URL', section: 'Home Hero Section', valueEn: hero.imageUrl, valueGu: hero.imageUrl);

    // Synchronize home_banners collection
    if (_homeBanners.isNotEmpty) {
      final banner = _homeBanners.first.copyWith(
        titleEn: hero.titleEn,
        titleGu: hero.titleGu,
        subtitleEn: hero.mottoEn,
        subtitleGu: hero.mottoGu,
        badgeEn: hero.tagBadgeEn,
        badgeGu: hero.tagBadgeGu,
        imageUrl: hero.imageUrl,
        ctaTextEn: hero.ctaPrimaryTextEn,
        ctaTextGu: hero.ctaPrimaryTextGu,
        ctaRoute: hero.ctaPrimaryRoute,
      );
      _homeBanners[0] = banner;
      _writeToFirestore('home_banners', banner.id, banner.toMap());
    } else {
      final banner = AdminHomeBanner(
        id: 'banner_hero_main',
        titleEn: hero.titleEn,
        titleGu: hero.titleGu,
        subtitleEn: hero.mottoEn,
        subtitleGu: hero.mottoGu,
        badgeEn: hero.tagBadgeEn,
        badgeGu: hero.tagBadgeGu,
        imageUrl: hero.imageUrl,
        ctaTextEn: hero.ctaPrimaryTextEn,
        ctaTextGu: hero.ctaPrimaryTextGu,
        ctaRoute: hero.ctaPrimaryRoute,
      );
      _homeBanners.add(banner);
      _writeToFirestore('home_banners', banner.id, banner.toMap());
    }

    logActivity('UPDATE', 'Home Screen', 'Hero Section saved and published to website');
    notifyListeners();
  }

  Future<void> clearHeroField(String key) async {
    final existing = _siteContentMap[key];
    if (existing != null) {
      final cleared = existing.copyWith(valueEn: '', valueGu: '');
      _siteContentMap[key] = cleared;
      _writeToFirestore('site_content', key, cleared.toMap());
      notifyListeners();
    }
  }

  Future<void> saveStatsSection(AdminStatsData stats) async {
    setSiteContentValue('stat_years_title', label: 'Stat 1: Heritage Years Title', section: 'Heritage Highlights', valueEn: stats.stat1.titleEn, valueGu: stats.stat1.titleGu);
    setSiteContentValue('stat_years_desc', label: 'Stat 1: Heritage Years Description', section: 'Heritage Highlights', valueEn: stats.stat1.descEn, valueGu: stats.stat1.descGu);

    setSiteContentValue('stat_music_title', label: 'Stat 2: Music Heritage Title', section: 'Heritage Highlights', valueEn: stats.stat2.titleEn, valueGu: stats.stat2.titleGu);
    setSiteContentValue('stat_music_desc', label: 'Stat 2: Music Heritage Description', section: 'Heritage Highlights', valueEn: stats.stat2.descEn, valueGu: stats.stat2.descGu);

    setSiteContentValue('stat_devotion_title', label: 'Stat 3: Devotion Title', section: 'Heritage Highlights', valueEn: stats.stat3.titleEn, valueGu: stats.stat3.titleGu);
    setSiteContentValue('stat_devotion_desc', label: 'Stat 3: Devotion Description', section: 'Heritage Highlights', valueEn: stats.stat3.descEn, valueGu: stats.stat3.descGu);

    setSiteContentValue('stat_archive_title', label: 'Stat 4: Archive Title', section: 'Heritage Highlights', valueEn: stats.stat4.titleEn, valueGu: stats.stat4.titleGu);
    setSiteContentValue('stat_archive_desc', label: 'Stat 4: Archive Description', section: 'Heritage Highlights', valueEn: stats.stat4.descEn, valueGu: stats.stat4.descGu);

    logActivity('UPDATE', 'Heritage Highlights', 'Quick Heritage Highlights updated on website');
    notifyListeners();
  }

  Future<void> clearAllStats() async {
    final keys = [
      'stat_years_title',
      'stat_years_desc',
      'stat_music_title',
      'stat_music_desc',
      'stat_devotion_title',
      'stat_devotion_desc',
      'stat_archive_title',
      'stat_archive_desc',
    ];
    for (final k in keys) {
      setSiteContentValue(k, label: k, section: 'Heritage Highlights', valueEn: '', valueGu: '');
    }
    logActivity('UPDATE', 'Heritage Highlights', 'All Quick Heritage Highlights cleared');
    notifyListeners();
  }

  // --- Section 3: About Mandal Highlights & Daily Aarti ---
  Future<void> saveAboutSection({
    String tagEn = '',
    String tagGu = '',
    String titleEn = '',
    String titleGu = '',
    String descEn = '',
    String descGu = '',
    String aartiEn = '',
    String aartiGu = '',
  }) async {
    setSiteContentValue('sec_01_tag', label: 'About Section Eyebrow Tag', section: 'About The Mandal', valueEn: tagEn, valueGu: tagGu);
    setSiteContentValue('sec_01_title', label: 'About Section Headline', section: 'About The Mandal', valueEn: titleEn, valueGu: titleGu, isMultiline: true);
    setSiteContentValue('sec_01_desc', label: 'About Section Description', section: 'About The Mandal', valueEn: descEn, valueGu: descGu, isMultiline: true);
    setSiteContentValue('daily_aarti_announcement', label: 'Daily Maha Aarti Announcement', section: 'Aarti & Schedule', valueEn: aartiEn, valueGu: aartiGu);
    logActivity('UPDATE', 'About The Mandal', 'About highlights and announcements updated on website');
    notifyListeners();
  }

  Future<void> clearAboutSection() async {
    final keys = ['sec_01_tag', 'sec_01_title', 'sec_01_desc', 'daily_aarti_announcement'];
    for (final k in keys) {
      setSiteContentValue(k, label: k, section: 'About The Mandal', valueEn: '', valueGu: '');
    }
    logActivity('UPDATE', 'About The Mandal', 'About section cleared');
    notifyListeners();
  }

  // --- CRUD: About Cards (Section 3) ---
  Future<void> addAboutCard(AdminAboutCard card) async {
    var finalCard = card;
    if (finalCard.titleGu.trim().isEmpty && finalCard.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalCard.titleEn);
        finalCard = finalCard.copyWith(titleGu: trans);
      } catch (_) {}
    }
    if (finalCard.descGu.trim().isEmpty && finalCard.descEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalCard.descEn);
        finalCard = finalCard.copyWith(descGu: trans);
      } catch (_) {}
    }
    _aboutCards.add(finalCard);
    _aboutCards.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'About Cards', 'Added value card: "${finalCard.titleEn.isNotEmpty ? finalCard.titleEn : finalCard.titleGu}"');
    await _writeToFirestore('home_about_cards', finalCard.id, finalCard.toMap());
    notifyListeners();
  }

  Future<void> updateAboutCard(AdminAboutCard updated) async {
    var finalCard = updated;
    if (finalCard.titleGu.trim().isEmpty && finalCard.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalCard.titleEn);
        finalCard = finalCard.copyWith(titleGu: trans);
      } catch (_) {}
    }
    if (finalCard.descGu.trim().isEmpty && finalCard.descEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalCard.descEn);
        finalCard = finalCard.copyWith(descGu: trans);
      } catch (_) {}
    }
    final index = _aboutCards.indexWhere((c) => c.id == finalCard.id);
    if (index != -1) {
      _aboutCards[index] = finalCard;
    } else {
      _aboutCards.add(finalCard);
    }
    _aboutCards.sort((a, b) => a.order.compareTo(b.order));
    logActivity('UPDATE', 'About Cards', 'Updated value card: "${finalCard.titleEn.isNotEmpty ? finalCard.titleEn : finalCard.titleGu}"');
    await _writeToFirestore('home_about_cards', finalCard.id, finalCard.toMap());
    notifyListeners();
  }

  Future<void> deleteAboutCard(String id) async {
    final card = _aboutCards.firstWhere((c) => c.id == id, orElse: () => AdminAboutCard(id: id));
    _aboutCards.removeWhere((c) => c.id == id);
    logActivity('DELETE', 'About Cards', 'Deleted value card: "${card.titleEn.isNotEmpty ? card.titleEn : card.titleGu}"');
    await _deleteFromFirestore('home_about_cards', id);
    notifyListeners();
  }

  // --- CRUD: Home Pillars (Section 4: Sacred Foundations) ---
  Future<void> addHomePillar(AdminHomePillar pillar) async {
    var finalPillar = pillar;
    if (finalPillar.titleGu.trim().isEmpty && finalPillar.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalPillar.titleEn);
        finalPillar = finalPillar.copyWith(titleGu: trans);
      } catch (_) {}
    }
    if (finalPillar.descGu.trim().isEmpty && finalPillar.descEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalPillar.descEn);
        finalPillar = finalPillar.copyWith(descGu: trans);
      } catch (_) {}
    }
    _pillars.add(finalPillar);
    _pillars.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'Home Pillars', 'Added sacred pillar: "${finalPillar.titleEn.isNotEmpty ? finalPillar.titleEn : finalPillar.titleGu}"');
    await _writeToFirestore('home_pillars', finalPillar.id, finalPillar.toMap());
    notifyListeners();
  }

  Future<void> updateHomePillar(AdminHomePillar updated) async {
    var finalPillar = updated;
    if (finalPillar.titleGu.trim().isEmpty && finalPillar.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalPillar.titleEn);
        finalPillar = finalPillar.copyWith(titleGu: trans);
      } catch (_) {}
    }
    if (finalPillar.descGu.trim().isEmpty && finalPillar.descEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalPillar.descEn);
        finalPillar = finalPillar.copyWith(descGu: trans);
      } catch (_) {}
    }
    final index = _pillars.indexWhere((p) => p.id == finalPillar.id);
    if (index != -1) {
      _pillars[index] = finalPillar;
    } else {
      _pillars.add(finalPillar);
    }
    _pillars.sort((a, b) => a.order.compareTo(b.order));
    logActivity('UPDATE', 'Home Pillars', 'Updated sacred pillar: "${finalPillar.titleEn.isNotEmpty ? finalPillar.titleEn : finalPillar.titleGu}"');
    await _writeToFirestore('home_pillars', finalPillar.id, finalPillar.toMap());
    notifyListeners();
  }

  Future<void> deleteHomePillar(String id) async {
    final pillar = _pillars.firstWhere((p) => p.id == id, orElse: () => AdminHomePillar(id: id));
    _pillars.removeWhere((p) => p.id == id);
    logActivity('DELETE', 'Home Pillars', 'Deleted sacred pillar: "${pillar.titleEn.isNotEmpty ? pillar.titleEn : pillar.titleGu}"');
    await _deleteFromFirestore('home_pillars', id);
    notifyListeners();
  }

  Future<void> saveHomePillarsHeader({required String tagEn, required String tagGu, required String titleEn, required String titleGu}) async {
    setSiteContentValue('sec_pillars_tag', label: 'Pillars Section Eyebrow Tag', section: 'Sacred Foundations', valueEn: tagEn, valueGu: tagGu);
    setSiteContentValue('sec_pillars_title', label: 'Pillars Section Headline', section: 'Sacred Foundations', valueEn: titleEn, valueGu: titleGu, isMultiline: true);
    logActivity('UPDATE', 'Sacred Foundations', 'Pillars section header updated');
    notifyListeners();
  }

  Future<void> clearHomePillarsHeader() async {
    setSiteContentValue('sec_pillars_tag', label: 'Pillars Section Eyebrow Tag', section: 'Sacred Foundations', valueEn: '', valueGu: '');
    setSiteContentValue('sec_pillars_title', label: 'Pillars Section Headline', section: 'Sacred Foundations', valueEn: '', valueGu: '');
    logActivity('UPDATE', 'Sacred Foundations', 'Pillars section header cleared');
    notifyListeners();
  }


  // --- Header: Home Singers (Section 5: Folk Artists Troupe) ---
  Future<void> saveHomeSingersHeader({
    required String tagEn,
    required String tagGu,
    required String titleEn,
    required String titleGu,
    required String descEn,
    required String descGu,
  }) async {
    setSiteContentValue('sec_singers_tag', label: 'Singers Section Eyebrow Tag', section: 'Folk Artists Troupe', valueEn: tagEn, valueGu: tagGu);
    setSiteContentValue('sec_singers_title', label: 'Singers Section Headline', section: 'Folk Artists Troupe', valueEn: titleEn, valueGu: titleGu);
    setSiteContentValue('sec_singers_desc', label: 'Singers Section Subtitle', section: 'Folk Artists Troupe', valueEn: descEn, valueGu: descGu, isMultiline: true);
    logActivity('UPDATE', 'Folk Artists Troupe', 'Singers section header updated');
    notifyListeners();
  }

  Future<void> clearHomeSingersHeader() async {
    setSiteContentValue('sec_singers_tag', label: 'Singers Section Eyebrow Tag', section: 'Folk Artists Troupe', valueEn: '', valueGu: '');
    setSiteContentValue('sec_singers_title', label: 'Singers Section Headline', section: 'Folk Artists Troupe', valueEn: '', valueGu: '');
    setSiteContentValue('sec_singers_desc', label: 'Singers Section Subtitle', section: 'Folk Artists Troupe', valueEn: '', valueGu: '', isMultiline: true);
    logActivity('UPDATE', 'Folk Artists Troupe', 'Singers section header cleared');
    notifyListeners();
  }

  // --- CRUD: Home Blessings (Section 6: Elders & Dignitaries Blessings) ---
  Future<void> addHomeBlessing(AdminHomeBlessing blessing) async {
    var finalBlessing = blessing;
    if (finalBlessing.authorGu.trim().isEmpty && finalBlessing.authorEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalBlessing.authorEn);
        finalBlessing = finalBlessing.copyWith(authorGu: trans);
      } catch (_) {}
    }
    if (finalBlessing.designationGu.trim().isEmpty && finalBlessing.designationEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalBlessing.designationEn);
        finalBlessing = finalBlessing.copyWith(designationGu: trans);
      } catch (_) {}
    }
    if (finalBlessing.quoteGu.trim().isEmpty && finalBlessing.quoteEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalBlessing.quoteEn);
        finalBlessing = finalBlessing.copyWith(quoteGu: trans);
      } catch (_) {}
    }
    _blessings.add(finalBlessing);
    _blessings.sort((a, b) => a.order.compareTo(b.order));
    logActivity('CREATE', 'Elders Blessings', 'Added blessing from: "${finalBlessing.authorEn.isNotEmpty ? finalBlessing.authorEn : finalBlessing.authorGu}"');
    await _writeToFirestore('home_blessings', finalBlessing.id, finalBlessing.toMap());
    notifyListeners();
  }

  Future<void> updateHomeBlessing(AdminHomeBlessing updated) async {
    var finalBlessing = updated;
    if (finalBlessing.authorGu.trim().isEmpty && finalBlessing.authorEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalBlessing.authorEn);
        finalBlessing = finalBlessing.copyWith(authorGu: trans);
      } catch (_) {}
    }
    if (finalBlessing.designationGu.trim().isEmpty && finalBlessing.designationEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalBlessing.designationEn);
        finalBlessing = finalBlessing.copyWith(designationGu: trans);
      } catch (_) {}
    }
    if (finalBlessing.quoteGu.trim().isEmpty && finalBlessing.quoteEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalBlessing.quoteEn);
        finalBlessing = finalBlessing.copyWith(quoteGu: trans);
      } catch (_) {}
    }
    final index = _blessings.indexWhere((b) => b.id == finalBlessing.id);
    if (index != -1) {
      _blessings[index] = finalBlessing;
    } else {
      _blessings.add(finalBlessing);
    }
    _blessings.sort((a, b) => a.order.compareTo(b.order));
    logActivity('UPDATE', 'Elders Blessings', 'Updated blessing from: "${finalBlessing.authorEn.isNotEmpty ? finalBlessing.authorEn : finalBlessing.authorGu}"');
    await _writeToFirestore('home_blessings', finalBlessing.id, finalBlessing.toMap());
    notifyListeners();
  }

  Future<void> deleteHomeBlessing(String id) async {
    final blessing = _blessings.firstWhere((b) => b.id == id, orElse: () => AdminHomeBlessing(id: id));
    _blessings.removeWhere((b) => b.id == id);
    logActivity('DELETE', 'Elders Blessings', 'Deleted blessing from: "${blessing.authorEn.isNotEmpty ? blessing.authorEn : blessing.authorGu}"');
    await _deleteFromFirestore('home_blessings', id);
    notifyListeners();
  }

  Future<void> saveHomeBlessingsHeader({required String tagEn, required String tagGu, required String titleEn, required String titleGu}) async {
    setSiteContentValue('sec_opinions_tag', label: 'Blessings Section Eyebrow Tag', section: 'Elders Blessings', valueEn: tagEn, valueGu: tagGu);
    setSiteContentValue('sec_opinions_title', label: 'Blessings Section Headline', section: 'Elders Blessings', valueEn: titleEn, valueGu: titleGu);
    logActivity('UPDATE', 'Elders Blessings', 'Blessings section header updated');
    notifyListeners();
  }

  Future<void> clearHomeBlessingsHeader() async {
    setSiteContentValue('sec_opinions_tag', label: 'Blessings Section Eyebrow Tag', section: 'Elders Blessings', valueEn: '', valueGu: '');
    setSiteContentValue('sec_opinions_title', label: 'Blessings Section Headline', section: 'Elders Blessings', valueEn: '', valueGu: '');
    logActivity('UPDATE', 'Elders Blessings', 'Blessings section header cleared');
    notifyListeners();
  }

  // --- Header: Cultural Stories & Articles (Section 7) ---
  Future<void> saveHomeArticlesHeader({required String tagEn, required String tagGu, required String titleEn, required String titleGu}) async {
    setSiteContentValue('sec_blog_tag', label: 'Articles Eyebrow Tag', section: 'Cultural Stories & Articles', valueEn: tagEn, valueGu: tagGu);
    setSiteContentValue('sec_blog_title', label: 'Articles Section Headline', section: 'Cultural Stories & Articles', valueEn: titleEn, valueGu: titleGu);
    logActivity('UPDATE', 'Cultural Articles', 'Articles section header updated');
    notifyListeners();
  }

  Future<void> clearHomeArticlesHeader() async {
    setSiteContentValue('sec_blog_tag', label: 'Articles Eyebrow Tag', section: 'Cultural Stories & Articles', valueEn: '', valueGu: '');
    setSiteContentValue('sec_blog_title', label: 'Articles Section Headline', section: 'Cultural Stories & Articles', valueEn: '', valueGu: '');
    logActivity('UPDATE', 'Cultural Articles', 'Articles section header cleared');
    notifyListeners();
  }

  // --- CRUD: Home Call-To-Action Banner (Section 8) ---
  Future<void> saveHomeCtaData(AdminHomeCtaData data) async {
    setSiteContentValue('home_cta_invocation', label: 'CTA Top Sacred Chant', section: 'Call To Action Banner', valueEn: data.invocationEn, valueGu: data.invocationGu);
    setSiteContentValue('home_cta_motto', label: 'CTA Motto Headline', section: 'Call To Action Banner', valueEn: data.mottoEn, valueGu: data.mottoGu, isMultiline: true);
    setSiteContentValue('home_cta_btn_text', label: 'CTA Action Button Label', section: 'Call To Action Banner', valueEn: data.btnTextEn, valueGu: data.btnTextGu);
    setSiteContentValue('home_cta_btn_route', label: 'CTA Action Button Route', section: 'Call To Action Banner', valueEn: data.btnRoute, valueGu: data.btnRoute);
    logActivity('UPDATE', 'Call To Action Banner', 'Call-to-action banner updated on website');
    notifyListeners();
  }

  Future<void> clearHomeCtaData() async {
    final keys = ['home_cta_invocation', 'home_cta_motto', 'home_cta_btn_text', 'home_cta_btn_route'];
    for (final k in keys) {
      setSiteContentValue(k, label: k, section: 'Call To Action Banner', valueEn: '', valueGu: '');
    }
    logActivity('UPDATE', 'Call To Action Banner', 'CTA Banner cleared');
    notifyListeners();
  }

  // --- CRUD: Years ---
  void addYear(AdminGarbiYear year) async {
    var finalYear = year;
    if (finalYear.titleGu.trim().isEmpty && finalYear.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalYear.titleEn);
        finalYear = finalYear.copyWith(titleGu: trans);
      } catch (_) {}
    }
    _years.insert(0, finalYear);
    logActivity('CREATE', 'Years', 'Added festival year ${finalYear.year}');
    _writeToFirestore('garbi_years', finalYear.id, finalYear.toMap());
    notifyListeners();
  }

  void updateYear(AdminGarbiYear updatedYear) async {
    var finalYear = updatedYear;
    if (finalYear.titleGu.trim().isEmpty && finalYear.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalYear.titleEn);
        finalYear = finalYear.copyWith(titleGu: trans);
      } catch (_) {}
    }
    final index = _years.indexWhere((y) => y.id == finalYear.id);
    if (index != -1) {
      _years[index] = finalYear;
      logActivity('UPDATE', 'Years', 'Updated festival year ${finalYear.year}');
      _writeToFirestore('garbi_years', finalYear.id, finalYear.toMap());
      notifyListeners();
    }
  }

  void deleteYear(String id) {
    final item = _years.firstWhere(
      (y) => y.id == id,
      orElse: () => AdminGarbiYear(id: '', year: 0, titleEn: '', titleGu: '', description: ''),
    );
    _years.removeWhere((y) => y.id == id);
    logActivity('DELETE', 'Years', 'Deleted festival year ${item.year}');
    _deleteFromFirestore('garbi_years', id);
    notifyListeners();
  }

  // --- CRUD: Albums ---
  void addAlbum(AdminAlbum album) {
    _albums.insert(0, album);
    logActivity('CREATE', 'Albums', 'Created album "${album.name}" (${album.year})');
    _writeToFirestore('albums', album.id, album.toMap());
    notifyListeners();
  }

  void updateAlbum(AdminAlbum updatedAlbum) {
    final index = _albums.indexWhere((a) => a.id == updatedAlbum.id);
    if (index != -1) {
      _albums[index] = updatedAlbum;
      logActivity('UPDATE', 'Albums', 'Updated album "${updatedAlbum.name}"');
      _writeToFirestore('albums', updatedAlbum.id, updatedAlbum.toMap());
      notifyListeners();
    }
  }

  void deleteAlbum(String id) {
    final item = _albums.firstWhere(
      (a) => a.id == id,
      orElse: () => AdminAlbum(id: '', year: '', name: '', dayTag: '', description: ''),
    );
    _albums.removeWhere((a) => a.id == id);
    logActivity('DELETE', 'Albums', 'Deleted album "${item.name}"');
    _deleteFromFirestore('albums', id);
    notifyListeners();
  }

  // --- CRUD: Photos ---
  void addPhoto(AdminPhoto photo) async {
    var finalPhoto = photo;
    if (finalPhoto.titleGu.trim().isEmpty && finalPhoto.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalPhoto.titleEn);
        finalPhoto = finalPhoto.copyWith(titleGu: trans);
      } catch (_) {}
    }
    _photos.insert(0, finalPhoto);
    logActivity('CREATE', 'Photos', 'Uploaded photo "${finalPhoto.titleEn}" (${finalPhoto.year})');
    _writeToFirestore('photos', finalPhoto.id, finalPhoto.toMap());
    notifyListeners();
  }

  void updatePhoto(AdminPhoto updatedPhoto) async {
    var finalPhoto = updatedPhoto;
    if (finalPhoto.titleGu.trim().isEmpty && finalPhoto.titleEn.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalPhoto.titleEn);
        finalPhoto = finalPhoto.copyWith(titleGu: trans);
      } catch (_) {}
    }
    final index = _photos.indexWhere((p) => p.id == finalPhoto.id);
    if (index != -1) {
      _photos[index] = finalPhoto;
      logActivity('UPDATE', 'Photos', 'Updated photo "${finalPhoto.titleEn}"');
      _writeToFirestore('photos', finalPhoto.id, finalPhoto.toMap());
      notifyListeners();
    }
  }

  void deletePhoto(String id) {
    final item = _photos.firstWhere(
      (p) => p.id == id,
      orElse: () => AdminPhoto(id: '', year: '', albumId: '', day: '', titleEn: '', titleGu: ''),
    );
    _photos.removeWhere((p) => p.id == id);
    logActivity('DELETE', 'Photos', 'Deleted photo "${item.titleEn}"');
    _deleteFromFirestore('photos', id);
    notifyListeners();
  }

  // --- CRUD: Videos ---
  void addVideo(AdminVideo video) async {
    var finalVideo = video;
    if (finalVideo.titleGu.trim().isEmpty && finalVideo.title.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalVideo.title);
        finalVideo = finalVideo.copyWith(titleGu: trans);
      } catch (_) {}
    }
    _videos.insert(0, finalVideo);
    logActivity('CREATE', 'Videos', 'Added video recording "${finalVideo.title}"');
    _writeToFirestore('videos', finalVideo.id, finalVideo.toMap());
    notifyListeners();
  }

  void updateVideo(AdminVideo updatedVideo) async {
    var finalVideo = updatedVideo;
    if (finalVideo.titleGu.trim().isEmpty && finalVideo.title.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalVideo.title);
        finalVideo = finalVideo.copyWith(titleGu: trans);
      } catch (_) {}
    }
    final index = _videos.indexWhere((v) => v.id == finalVideo.id);
    if (index != -1) {
      _videos[index] = finalVideo;
      logActivity('UPDATE', 'Videos', 'Updated video "${finalVideo.title}"');
      _writeToFirestore('videos', finalVideo.id, finalVideo.toMap());
      notifyListeners();
    }
  }

  void toggleVideoPublish(String id) {
    final index = _videos.indexWhere((v) => v.id == id);
    if (index != -1) {
      final current = _videos[index];
      final updated = current.copyWith(isPublished: !current.isPublished);
      _videos[index] = updated;
      logActivity('UPDATE', 'Videos', '${updated.isPublished ? "Published" : "Unpublished"} video "${updated.title}"');
      _writeToFirestore('videos', updated.id, updated.toMap());
      notifyListeners();
    }
  }

  void toggleVideoFeatured(String id) {
    final index = _videos.indexWhere((v) => v.id == id);
    if (index != -1) {
      final current = _videos[index];
      final updated = current.copyWith(isFeatured: !current.isFeatured);
      _videos[index] = updated;
      logActivity('UPDATE', 'Videos', '${updated.isFeatured ? "Featured" : "Unfeatured"} video "${updated.title}"');
      _writeToFirestore('videos', updated.id, updated.toMap());
      notifyListeners();
    }
  }

  void deleteVideo(String id) {
    final item = _videos.firstWhere(
      (v) => v.id == id,
      orElse: () => AdminVideo(id: '', title: '', tag: '', duration: '', youtubeUrl: '', year: ''),
    );
    _videos.removeWhere((v) => v.id == id);
    logActivity('DELETE', 'Videos', 'Deleted video "${item.title}"');
    _deleteFromFirestore('videos', id);
    notifyListeners();
  }

  // --- Live Stream Settings ---
  void updateLiveStream(AdminLiveStreamSettings settings) {
    _liveStreamSettings = settings;
    logActivity('CONFIG', 'Live Streaming', 'Broadcast status: ${settings.isLive ? "LIVE NOW" : "OFFLINE"}, title: "${settings.title}"');
    _writeToFirestore('live_stream', 'current', settings.toMap());
    notifyListeners();
  }

  // --- CRUD: Blogs ---
  void addBlog(AdminBlog blog) {
    _blogs.insert(0, blog);
    logActivity('CREATE', 'Blogs', 'Published new article "${blog.title}"');
    _writeToFirestore('blogs', blog.id, blog.toMap());
    notifyListeners();
  }

  void updateBlog(AdminBlog updatedBlog) {
    final index = _blogs.indexWhere((b) => b.id == updatedBlog.id);
    if (index != -1) {
      _blogs[index] = updatedBlog;
      logActivity('UPDATE', 'Blogs', 'Updated article "${updatedBlog.title}"');
      _writeToFirestore('blogs', updatedBlog.id, updatedBlog.toMap());
      notifyListeners();
    }
  }

  void deleteBlog(String id) {
    final item = _blogs.firstWhere(
      (b) => b.id == id,
      orElse: () => AdminBlog(id: '', slug: '', title: '', category: '', date: '', readTime: '', snippet: '', content: ''),
    );
    _blogs.removeWhere((b) => b.id == id);
    logActivity('DELETE', 'Blogs', 'Deleted article "${item.title}"');
    _deleteFromFirestore('blogs', id);
    notifyListeners();
  }

  // --- CRUD: Enquiries ---
  void addEnquiry(AdminEnquiry enquiry) {
    _enquiries.insert(0, enquiry);
    logActivity('CREATE', 'Enquiries', 'Received new enquiry from ${enquiry.name}');
    _writeToFirestore('enquiries', enquiry.id, enquiry.toMap());
    notifyListeners();
  }

  void updateEnquiryStatus(String id, String status) {
    final index = _enquiries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _enquiries[index] = _enquiries[index].copyWith(status: status);
      logActivity('UPDATE', 'Enquiries', 'Updated enquiry status to "$status" for ${_enquiries[index].name}');
      _writeToFirestore('enquiries', id, _enquiries[index].toMap());
      notifyListeners();
    }
  }

  void deleteEnquiry(String id) {
    final item = _enquiries.firstWhere(
      (e) => e.id == id,
      orElse: () => AdminEnquiry(id: '', name: '', phone: '', email: '', message: '', date: ''),
    );
    _enquiries.removeWhere((e) => e.id == id);
    logActivity('DELETE', 'Enquiries', 'Deleted enquiry from ${item.name}');
    _deleteFromFirestore('enquiries', id);
    notifyListeners();
  }

  // --- Settings ---
  void updateSettings(AdminSettings newSettings) {
    _settings = newSettings;
    updateSiteContentField('app_title', valueEn: newSettings.mandalNameEn, valueGu: newSettings.mandalNameGu);
    updateSiteContentField('contact_phone', valueEn: newSettings.contactPhone, valueGu: newSettings.contactPhone);
    updateSiteContentField('contact_email', valueEn: newSettings.contactEmail, valueGu: newSettings.contactEmail);
    updateSiteContentField('contact_address', valueEn: newSettings.address, valueGu: newSettings.address);
    updateSiteContentField('contact_aarti_time', valueEn: newSettings.dailyAartiTime, valueGu: newSettings.dailyAartiTime);
    logActivity('CONFIG', 'Settings', 'Saved portal and Mandal general settings');
    _writeToFirestore('settings', 'mandal_settings', newSettings.toMap());
    notifyListeners();
  }

  // --- CRUD: Footer Navigation Links ---
  Future<void> saveFooterLink(AdminFooterLink link) async {
    final index = _footerLinks.indexWhere((l) => l.id == link.id);
    if (index != -1) {
      _footerLinks[index] = link;
      logActivity('UPDATE', 'Footer', 'Updated footer link: "${link.titleEn}"');
    } else {
      _footerLinks.add(link);
      logActivity('CREATE', 'Footer', 'Added footer link: "${link.titleEn}"');
    }
    _footerLinks.sort((a, b) => a.order.compareTo(b.order));
    await _writeToFirestore('footer_links', link.id, link.toMap());
    notifyListeners();
  }

  Future<void> deleteFooterLink(String id) async {
    final item = _footerLinks.firstWhere(
      (l) => l.id == id,
      orElse: () => const AdminFooterLink(id: '', titleEn: '', titleGu: '', url: ''),
    );
    _footerLinks.removeWhere((l) => l.id == id);
    logActivity('DELETE', 'Footer', 'Deleted footer link: "${item.titleEn}"');
    await _deleteFromFirestore('footer_links', id);
    notifyListeners();
  }

  Future<void> toggleFooterLinkEnabled(String id) async {
    final index = _footerLinks.indexWhere((l) => l.id == id);
    if (index != -1) {
      final updated = _footerLinks[index].copyWith(isEnabled: !_footerLinks[index].isEnabled);
      _footerLinks[index] = updated;
      await _writeToFirestore('footer_links', updated.id, updated.toMap());
      notifyListeners();
    }
  }

  Future<void> reorderFooterLinks(String column, int oldIndex, int newIndex) async {
    final colLinks = _footerLinks.where((l) => l.column == column).toList();
    if (oldIndex < 0 || oldIndex >= colLinks.length || newIndex < 0 || newIndex >= colLinks.length) return;
    final item = colLinks.removeAt(oldIndex);
    colLinks.insert(newIndex, item);

    for (int i = 0; i < colLinks.length; i++) {
      final updated = colLinks[i].copyWith(order: i + 1);
      final idx = _footerLinks.indexWhere((l) => l.id == updated.id);
      if (idx != -1) _footerLinks[idx] = updated;
      await _writeToFirestore('footer_links', updated.id, updated.toMap());
    }
    _footerLinks.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  // --- CRUD: Footer Social Media Links ---
  Future<void> saveFooterSocialLink(AdminFooterSocialLink link) async {
    final index = _footerSocialLinks.indexWhere((s) => s.id == link.id);
    if (index != -1) {
      _footerSocialLinks[index] = link;
      logActivity('UPDATE', 'Footer', 'Updated social channel: "${link.platform}"');
    } else {
      _footerSocialLinks.add(link);
      logActivity('CREATE', 'Footer', 'Added social channel: "${link.platform}"');
    }
    _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
    await _writeToFirestore('footer_social_links', link.id, link.toMap());
    notifyListeners();
  }

  Future<void> deleteFooterSocialLink(String id) async {
    final item = _footerSocialLinks.firstWhere(
      (s) => s.id == id,
      orElse: () => const AdminFooterSocialLink(id: '', platform: '', url: ''),
    );
    _footerSocialLinks.removeWhere((s) => s.id == id);
    logActivity('DELETE', 'Footer', 'Deleted social channel: "${item.platform}"');
    await _deleteFromFirestore('footer_social_links', id);
    notifyListeners();
  }

  Future<void> toggleFooterSocialLinkEnabled(String id) async {
    final index = _footerSocialLinks.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updated = _footerSocialLinks[index].copyWith(isEnabled: !_footerSocialLinks[index].isEnabled);
      _footerSocialLinks[index] = updated;
      await _writeToFirestore('footer_social_links', updated.id, updated.toMap());
      notifyListeners();
    }
  }

  // --- Save Footer Text & Contact Settings ---
  Future<void> saveFooterContentSettings({
    required String taglineEn,
    required String taglineGu,
    required String mottoEn,
    required String mottoGu,
    required String col1TitleEn,
    required String col1TitleGu,
    required String col2TitleEn,
    required String col2TitleGu,
    required String socialTitleEn,
    required String socialTitleGu,
    required String locationEn,
    required String locationGu,
    required String copyrightEn,
    required String copyrightGu,
    required String phone,
    required String email,
    String? appTitleEn,
    String? appTitleGu,
    String? appSubtitleEn,
    String? appSubtitleGu,
  }) async {
    updateSiteContentField('footer_tagline', valueEn: taglineEn, valueGu: taglineGu);
    updateSiteContentField('footer_motto', valueEn: mottoEn, valueGu: mottoGu);
    updateSiteContentField('footer_links_title', valueEn: col1TitleEn, valueGu: col1TitleGu);
    updateSiteContentField('footer_links2_title', valueEn: col2TitleEn, valueGu: col2TitleGu);
    updateSiteContentField('footer_social', valueEn: socialTitleEn, valueGu: socialTitleGu);
    updateSiteContentField('footer_location', valueEn: locationEn, valueGu: locationGu);
    updateSiteContentField('footer_copyright', valueEn: copyrightEn, valueGu: copyrightGu);

    if (appTitleEn != null || appTitleGu != null) {
      updateSiteContentField('app_title', valueEn: appTitleEn ?? _settings.mandalNameEn, valueGu: appTitleGu ?? _settings.mandalNameGu);
    }
    if (appSubtitleEn != null || appSubtitleGu != null) {
      updateSiteContentField('app_subtitle', valueEn: appSubtitleEn ?? '', valueGu: appSubtitleGu ?? '');
    }

    final updatedSettings = _settings.copyWith(
      contactPhone: phone,
      contactEmail: email,
      address: locationGu.isNotEmpty ? locationGu : locationEn,
      mandalNameEn: appTitleEn?.isNotEmpty == true ? appTitleEn : _settings.mandalNameEn,
      mandalNameGu: appTitleGu?.isNotEmpty == true ? appTitleGu : _settings.mandalNameGu,
    );
    updateSettings(updatedSettings);

    logActivity('CONFIG', 'Footer', 'Updated website footer configuration and metadata');
    notifyListeners();
  }

  Future<void> clearAllFooterFields() async {
    final keys = [
      'footer_tagline',
      'footer_motto',
      'footer_links_title',
      'footer_links2_title',
      'footer_social',
      'footer_location',
      'footer_copyright',
    ];
    for (final k in keys) {
      updateSiteContentField(k, valueEn: '', valueGu: '');
    }
    logActivity('DELETE', 'Footer', 'Cleared all website footer content fields');
    notifyListeners();
  }

}
