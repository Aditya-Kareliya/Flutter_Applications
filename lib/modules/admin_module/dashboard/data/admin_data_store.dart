import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/google_translation_service.dart';
import '../../../../core/localization/my_app_translations.dart';
import '../../../../core/utils/youtube_url_helper.dart';

class AdminActivityLog {
  AdminActivityLog({this.id = '', DateTime? timestamp, this.action = 'UPDATE', this.module = 'General', this.details = '', this.user = 'admin'})
    : timestamp = timestamp ?? DateTime.now();

  AdminActivityLog.fromJson(dynamic json) {
    if (json is! Map) {
      timestamp = DateTime.now();
      return;
    }
    id = json['id']?.toString() ?? 'log-${DateTime.now().millisecondsSinceEpoch}';
    timestamp = DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now();
    action = json['action']?.toString() ?? 'UPDATE';
    module = json['module']?.toString() ?? 'General';
    details = json['details']?.toString() ?? '';
    user = json['user']?.toString() ?? 'admin';
  }

  factory AdminActivityLog.fromMap(Map<String, dynamic> map) => AdminActivityLog.fromJson(map);

  String id = '';
  DateTime timestamp = DateTime.now();
  String action = 'UPDATE';
  String module = 'General';
  String details = '';
  String user = 'admin';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['timestamp'] = timestamp.toIso8601String();
    map['action'] = action;
    map['module'] = module;
    map['details'] = details;
    map['user'] = user;
    return map;
  }

  Map<String, dynamic> toMap() => toJson();
}

class AdminContentField {
  AdminContentField({this.key = '', this.label = '', this.section = 'General', this.valueEn = '', this.valueGu = '', this.isMultiline = false});

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminContentField.fromJson(dynamic json) {
    if (json is! Map) return;
    key = json['key']?.toString() ?? '';
    label = json['label']?.toString() ?? '';
    section = json['section']?.toString() ?? 'General';
    valueEn = json['valueEn']?.toString() ?? json['value_en']?.toString() ?? '';
    valueGu = json['valueGu']?.toString() ?? json['value_gu']?.toString() ?? '';
    isMultiline = _toBool(json['isMultiline'] ?? json['is_multiline']) ?? false;
  }

  factory AdminContentField.fromMap(Map<String, dynamic> map) => AdminContentField.fromJson(map);

  String key = '';
  String label = '';
  String section = 'General';
  String valueEn = '';
  String valueGu = '';
  bool isMultiline = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['key'] = key;
    map['label'] = label;
    map['section'] = section;
    map['valueEn'] = valueEn;
    map['valueGu'] = valueGu;
    map['isMultiline'] = isMultiline;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  AdminContentField copyWith({String? valueEn, String? valueGu}) {
    return AdminContentField(key: key, label: label, section: section, valueEn: valueEn ?? this.valueEn, valueGu: valueGu ?? this.valueGu, isMultiline: isMultiline);
  }
}

class AdminCommitteeMember {
  AdminCommitteeMember({
    this.id = '',
    this.nameEn = '',
    this.nameGu = '',
    this.designationEn = '',
    this.designationGu = '',
    this.phone = '',
    this.photoUrl = 'assets/images/pavan_putra_logo.png',
    this.order = 0,
    this.isActive = true,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminCommitteeMember.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    nameEn = json['nameEn']?.toString() ?? json['name_en']?.toString() ?? '';
    nameGu = json['nameGu']?.toString() ?? json['name_gu']?.toString() ?? '';
    designationEn = json['designationEn']?.toString() ?? json['designation_en']?.toString() ?? '';
    designationGu = json['designationGu']?.toString() ?? json['designation_gu']?.toString() ?? '';
    phone = json['phone']?.toString() ?? '';
    photoUrl = json['photoUrl']?.toString() ?? json['photo_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    order = _toInt(json['order']) ?? 0;
    isActive = _toBool(json['isActive'] ?? json['is_active']) ?? true;
  }

  factory AdminCommitteeMember.fromMap(Map<String, dynamic> map) => AdminCommitteeMember.fromJson(map);

  String id = '';
  String nameEn = '';
  String nameGu = '';
  String designationEn = '';
  String designationGu = '';
  String phone = '';
  String photoUrl = 'assets/images/pavan_putra_logo.png';
  int order = 0;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['nameEn'] = nameEn;
    map['nameGu'] = nameGu;
    map['designationEn'] = designationEn;
    map['designationGu'] = designationGu;
    map['phone'] = phone;
    map['photoUrl'] = photoUrl;
    map['order'] = order;
    map['isActive'] = isActive;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminHistoryMilestone {
  AdminHistoryMilestone({
    this.id = '',
    this.year = '',
    this.badgeEn = 'MILESTONE',
    this.badgeGu = 'માઇલસ્ટોન',
    this.titleEn = '',
    this.titleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.iconName = 'local_fire_department_rounded',
    this.imageUrl = 'assets/images/pavan_putra_logo.png',
    this.order = 0,
    this.isActive = true,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminHistoryMilestone.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    year = json['year']?.toString() ?? '';
    badgeEn = json['badgeEn']?.toString() ?? json['badge_en']?.toString() ?? 'MILESTONE';
    badgeGu = json['badgeGu']?.toString() ?? json['badge_gu']?.toString() ?? 'માઇલસ્ટોન';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    iconName = json['iconName']?.toString() ?? json['icon_name']?.toString() ?? 'local_fire_department_rounded';
    imageUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    order = _toInt(json['order']) ?? 0;
    isActive = _toBool(json['isActive'] ?? json['is_active']) ?? true;
  }

  factory AdminHistoryMilestone.fromMap(Map<String, dynamic> map) => AdminHistoryMilestone.fromJson(map);

  String id = '';
  String year = '';
  String badgeEn = 'MILESTONE';
  String badgeGu = 'માઇલસ્ટોન';
  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String iconName = 'local_fire_department_rounded';
  String imageUrl = 'assets/images/pavan_putra_logo.png';
  int order = 0;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['year'] = year;
    map['badgeEn'] = badgeEn;
    map['badgeGu'] = badgeGu;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['iconName'] = iconName;
    map['imageUrl'] = imageUrl;
    map['order'] = order;
    map['isActive'] = isActive;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
    bool? isActive,
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
      isActive: isActive ?? this.isActive,
    );
  }
}

class AdminHomeSinger {
  AdminHomeSinger({
    this.id = '',
    this.nameEn = '',
    this.nameGu = '',
    this.roleEn = '',
    this.roleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.imageUrl = 'assets/images/pavan_putra_logo.png',
    this.order = 0,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  AdminHomeSinger.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    nameEn = json['nameEn']?.toString() ?? json['name_en']?.toString() ?? '';
    nameGu = json['nameGu']?.toString() ?? json['name_gu']?.toString() ?? '';
    roleEn = json['roleEn']?.toString() ?? json['role_en']?.toString() ?? '';
    roleGu = json['roleGu']?.toString() ?? json['role_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    imageUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    order = _toInt(json['order']) ?? 0;
  }

  factory AdminHomeSinger.fromMap(Map<String, dynamic> map) => AdminHomeSinger.fromJson(map);

  String id = '';
  String nameEn = '';
  String nameGu = '';
  String roleEn = '';
  String roleGu = '';
  String descEn = '';
  String descGu = '';
  String imageUrl = 'assets/images/pavan_putra_logo.png';
  int order = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['nameEn'] = nameEn;
    map['nameGu'] = nameGu;
    map['roleEn'] = roleEn;
    map['roleGu'] = roleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['imageUrl'] = imageUrl;
    map['order'] = order;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminHeroData {
  AdminHeroData({
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

  AdminHeroData.fromJson(dynamic json) {
    if (json is! Map) return;
    sacredInvocationEn = json['sacredInvocationEn']?.toString() ?? json['sacred_invocation_en']?.toString() ?? '';
    sacredInvocationGu = json['sacredInvocationGu']?.toString() ?? json['sacred_invocation_gu']?.toString() ?? '';
    tagBadgeEn = json['tagBadgeEn']?.toString() ?? json['tag_badge_en']?.toString() ?? '';
    tagBadgeGu = json['tagBadgeGu']?.toString() ?? json['tag_badge_gu']?.toString() ?? '';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    mottoEn = json['mottoEn']?.toString() ?? json['motto_en']?.toString() ?? '';
    mottoGu = json['mottoGu']?.toString() ?? json['motto_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    ctaPrimaryTextEn = json['ctaPrimaryTextEn']?.toString() ?? json['cta_primary_text_en']?.toString() ?? '';
    ctaPrimaryTextGu = json['ctaPrimaryTextGu']?.toString() ?? json['cta_primary_text_gu']?.toString() ?? '';
    ctaPrimaryRoute = json['ctaPrimaryRoute']?.toString() ?? json['cta_primary_route']?.toString() ?? '/archive';
    ctaSecondaryTextEn = json['ctaSecondaryTextEn']?.toString() ?? json['cta_secondary_text_en']?.toString() ?? '';
    ctaSecondaryTextGu = json['ctaSecondaryTextGu']?.toString() ?? json['cta_secondary_text_gu']?.toString() ?? '';
    ctaSecondaryRoute = json['ctaSecondaryRoute']?.toString() ?? json['cta_secondary_route']?.toString() ?? '/about';
    bottomBadgeEn = json['bottomBadgeEn']?.toString() ?? json['bottom_badge_en']?.toString() ?? '';
    bottomBadgeGu = json['bottomBadgeGu']?.toString() ?? json['bottom_badge_gu']?.toString() ?? '';
    imageUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '';
  }

  factory AdminHeroData.fromMap(Map<String, dynamic> map) => AdminHeroData.fromJson(map);

  String sacredInvocationEn = '';
  String sacredInvocationGu = '';
  String tagBadgeEn = '';
  String tagBadgeGu = '';
  String titleEn = '';
  String titleGu = '';
  String mottoEn = '';
  String mottoGu = '';
  String descEn = '';
  String descGu = '';
  String ctaPrimaryTextEn = '';
  String ctaPrimaryTextGu = '';
  String ctaPrimaryRoute = '/archive';
  String ctaSecondaryTextEn = '';
  String ctaSecondaryTextGu = '';
  String ctaSecondaryRoute = '/about';
  String bottomBadgeEn = '';
  String bottomBadgeGu = '';
  String imageUrl = '';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sacredInvocationEn'] = sacredInvocationEn;
    map['sacredInvocationGu'] = sacredInvocationGu;
    map['tagBadgeEn'] = tagBadgeEn;
    map['tagBadgeGu'] = tagBadgeGu;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['mottoEn'] = mottoEn;
    map['mottoGu'] = mottoGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['ctaPrimaryTextEn'] = ctaPrimaryTextEn;
    map['ctaPrimaryTextGu'] = ctaPrimaryTextGu;
    map['ctaPrimaryRoute'] = ctaPrimaryRoute;
    map['ctaSecondaryTextEn'] = ctaSecondaryTextEn;
    map['ctaSecondaryTextGu'] = ctaSecondaryTextGu;
    map['ctaSecondaryRoute'] = ctaSecondaryRoute;
    map['bottomBadgeEn'] = bottomBadgeEn;
    map['bottomBadgeGu'] = bottomBadgeGu;
    map['imageUrl'] = imageUrl;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminHighlightStat {
  AdminHighlightStat({this.titleEn = '', this.titleGu = '', this.descEn = '', this.descGu = '', this.iconKey = 'book'});

  AdminHighlightStat.fromJson(dynamic json) {
    if (json is! Map) return;
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    iconKey = json['iconKey']?.toString() ?? json['icon_key']?.toString() ?? 'book';
  }

  factory AdminHighlightStat.fromMap(Map<String, dynamic> map) => AdminHighlightStat.fromJson(map);

  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String iconKey = 'book';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['iconKey'] = iconKey;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminStatsData {
  AdminStatsData({AdminHighlightStat? stat1, AdminHighlightStat? stat2, AdminHighlightStat? stat3, AdminHighlightStat? stat4})
    : stat1 = stat1 ?? AdminHighlightStat(iconKey: 'book'),
      stat2 = stat2 ?? AdminHighlightStat(iconKey: 'music'),
      stat3 = stat3 ?? AdminHighlightStat(iconKey: 'flame'),
      stat4 = stat4 ?? AdminHighlightStat(iconKey: 'history');

  AdminStatsData.fromJson(dynamic json)
    : stat1 = AdminHighlightStat(iconKey: 'book'),
      stat2 = AdminHighlightStat(iconKey: 'music'),
      stat3 = AdminHighlightStat(iconKey: 'flame'),
      stat4 = AdminHighlightStat(iconKey: 'history') {
    if (json is! Map) return;
    if (json['stat1'] != null) stat1 = AdminHighlightStat.fromJson(json['stat1']);
    if (json['stat2'] != null) stat2 = AdminHighlightStat.fromJson(json['stat2']);
    if (json['stat3'] != null) stat3 = AdminHighlightStat.fromJson(json['stat3']);
    if (json['stat4'] != null) stat4 = AdminHighlightStat.fromJson(json['stat4']);
  }

  factory AdminStatsData.fromMap(Map<String, dynamic> map) => AdminStatsData.fromJson(map);

  AdminHighlightStat stat1;
  AdminHighlightStat stat2;
  AdminHighlightStat stat3;
  AdminHighlightStat stat4;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['stat1'] = stat1.toJson();
    map['stat2'] = stat2.toJson();
    map['stat3'] = stat3.toJson();
    map['stat4'] = stat4.toJson();
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  List<AdminHighlightStat> get allStats => [stat1, stat2, stat3, stat4];

  List<AdminHighlightStat> get activeStats => allStats.where((s) => s.isActive).toList();

  bool get hasAnyStat => activeStats.isNotEmpty;

  AdminStatsData copyWith({AdminHighlightStat? stat1, AdminHighlightStat? stat2, AdminHighlightStat? stat3, AdminHighlightStat? stat4}) {
    return AdminStatsData(stat1: stat1 ?? this.stat1, stat2: stat2 ?? this.stat2, stat3: stat3 ?? this.stat3, stat4: stat4 ?? this.stat4);
  }
}

class AdminAboutCard {
  AdminAboutCard({this.id = '', this.titleEn = '', this.titleGu = '', this.descEn = '', this.descGu = '', this.iconKey = 'shield', this.order = 0});

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  AdminAboutCard.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? 'card-${DateTime.now().millisecondsSinceEpoch}';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    iconKey = json['iconKey']?.toString() ?? json['icon_key']?.toString() ?? 'shield';
    order = _toInt(json['order']) ?? 0;
  }

  factory AdminAboutCard.fromMap(Map<String, dynamic> map) => AdminAboutCard.fromJson(map);

  String id = '';
  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String iconKey = 'shield';
  int order = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['iconKey'] = iconKey;
    map['order'] = order;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminAboutData {
  AdminAboutData({this.tagEn = '', this.tagGu = '', this.titleEn = '', this.titleGu = '', this.descEn = '', this.descGu = '', this.aartiEn = '', this.aartiGu = ''});

  AdminAboutData.fromJson(dynamic json) {
    if (json is! Map) return;
    tagEn = json['tagEn']?.toString() ?? json['tag_en']?.toString() ?? '';
    tagGu = json['tagGu']?.toString() ?? json['tag_gu']?.toString() ?? '';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    aartiEn = json['aartiEn']?.toString() ?? json['aarti_en']?.toString() ?? '';
    aartiGu = json['aartiGu']?.toString() ?? json['aarti_gu']?.toString() ?? '';
  }

  factory AdminAboutData.fromMap(Map<String, dynamic> map) => AdminAboutData.fromJson(map);

  String tagEn = '';
  String tagGu = '';
  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String aartiEn = '';
  String aartiGu = '';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tagEn'] = tagEn;
    map['tagGu'] = tagGu;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['aartiEn'] = aartiEn;
    map['aartiGu'] = aartiGu;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminAboutPrinciple {
  AdminAboutPrinciple({
    this.id = '',
    this.number = '૦૧',
    this.titleEn = '',
    this.titleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.iconKey = 'verified',
    this.order = 0,
    this.isActive = true,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminAboutPrinciple.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? 'principle-${DateTime.now().millisecondsSinceEpoch}';
    number = json['number']?.toString() ?? '૦૧';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    iconKey = json['iconKey']?.toString() ?? json['icon_key']?.toString() ?? 'verified';
    order = _toInt(json['order']) ?? 0;
    isActive = _toBool(json['isActive'] ?? json['is_active']) ?? true;
  }

  factory AdminAboutPrinciple.fromMap(Map<String, dynamic> map) => AdminAboutPrinciple.fromJson(map);

  String id = '';
  String number = '૦૧';
  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String iconKey = 'verified';
  int order = 0;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['number'] = number;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['iconKey'] = iconKey;
    map['order'] = order;
    map['isActive'] = isActive;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminAboutPageData {
  AdminAboutPageData({
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
    this.foundationImageUrl = 'assets/images/pavan_putra_logo.png',
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

  AdminAboutPageData.fromJson(dynamic json) {
    if (json is! Map) return;
    tagBadgeEn = json['tagBadgeEn']?.toString() ?? json['tag_badge_en']?.toString() ?? '';
    tagBadgeGu = json['tagBadgeGu']?.toString() ?? json['tag_badge_gu']?.toString() ?? '';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    foundationTitleEn = json['foundationTitleEn']?.toString() ?? json['foundation_title_en']?.toString() ?? '';
    foundationTitleGu = json['foundationTitleGu']?.toString() ?? json['foundation_title_gu']?.toString() ?? '';
    foundationDescEn = json['foundationDescEn']?.toString() ?? json['foundation_desc_en']?.toString() ?? '';
    foundationDescGu = json['foundationDescGu']?.toString() ?? json['foundation_desc_gu']?.toString() ?? '';
    foundationMottoEn = json['foundationMottoEn']?.toString() ?? json['foundation_motto_en']?.toString() ?? '';
    foundationMottoGu = json['foundationMottoGu']?.toString() ?? json['foundation_motto_gu']?.toString() ?? '';
    foundationImageUrl = json['foundationImageUrl']?.toString() ?? json['foundation_image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    valuesTagEn = json['valuesTagEn']?.toString() ?? json['values_tag_en']?.toString() ?? '';
    valuesTagGu = json['valuesTagGu']?.toString() ?? json['values_tag_gu']?.toString() ?? '';
    valuesTitleEn = json['valuesTitleEn']?.toString() ?? json['values_title_en']?.toString() ?? '';
    valuesTitleGu = json['valuesTitleGu']?.toString() ?? json['values_title_gu']?.toString() ?? '';
    committeeBadgeEn = json['committeeBadgeEn']?.toString() ?? json['committee_badge_en']?.toString() ?? '';
    committeeBadgeGu = json['committeeBadgeGu']?.toString() ?? json['committee_badge_gu']?.toString() ?? '';
    committeeTitleEn = json['committeeTitleEn']?.toString() ?? json['committee_title_en']?.toString() ?? '';
    committeeTitleGu = json['committeeTitleGu']?.toString() ?? json['committee_title_gu']?.toString() ?? '';
    committeeDescEn = json['committeeDescEn']?.toString() ?? json['committee_desc_en']?.toString() ?? '';
    committeeDescGu = json['committeeDescGu']?.toString() ?? json['committee_desc_gu']?.toString() ?? '';
    ctaTitleEn = json['ctaTitleEn']?.toString() ?? json['cta_title_en']?.toString() ?? '';
    ctaTitleGu = json['ctaTitleGu']?.toString() ?? json['cta_title_gu']?.toString() ?? '';
    ctaDescEn = json['ctaDescEn']?.toString() ?? json['cta_desc_en']?.toString() ?? '';
    ctaDescGu = json['ctaDescGu']?.toString() ?? json['cta_desc_gu']?.toString() ?? '';
    ctaBtnTextEn = json['ctaBtnTextEn']?.toString() ?? json['cta_btn_text_en']?.toString() ?? '';
    ctaBtnTextGu = json['ctaBtnTextGu']?.toString() ?? json['cta_btn_text_gu']?.toString() ?? '';
    ctaRoute = json['ctaRoute']?.toString() ?? json['cta_route']?.toString() ?? '/history';
  }

  factory AdminAboutPageData.fromMap(Map<String, dynamic> map) => AdminAboutPageData.fromJson(map);

  String tagBadgeEn = '';
  String tagBadgeGu = '';
  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String foundationTitleEn = '';
  String foundationTitleGu = '';
  String foundationDescEn = '';
  String foundationDescGu = '';
  String foundationMottoEn = '';
  String foundationMottoGu = '';
  String foundationImageUrl = 'assets/images/pavan_putra_logo.png';
  String valuesTagEn = '';
  String valuesTagGu = '';
  String valuesTitleEn = '';
  String valuesTitleGu = '';
  String committeeBadgeEn = '';
  String committeeBadgeGu = '';
  String committeeTitleEn = '';
  String committeeTitleGu = '';
  String committeeDescEn = '';
  String committeeDescGu = '';
  String ctaTitleEn = '';
  String ctaTitleGu = '';
  String ctaDescEn = '';
  String ctaDescGu = '';
  String ctaBtnTextEn = '';
  String ctaBtnTextGu = '';
  String ctaRoute = '/history';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tagBadgeEn'] = tagBadgeEn;
    map['tagBadgeGu'] = tagBadgeGu;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['foundationTitleEn'] = foundationTitleEn;
    map['foundationTitleGu'] = foundationTitleGu;
    map['foundationDescEn'] = foundationDescGu;
    map['foundationMottoEn'] = foundationMottoEn;
    map['foundationMottoGu'] = foundationMottoGu;
    map['foundationImageUrl'] = foundationImageUrl;
    map['valuesTagEn'] = valuesTagEn;
    map['valuesTagGu'] = valuesTagGu;
    map['valuesTitleEn'] = valuesTitleEn;
    map['valuesTitleGu'] = valuesTitleGu;
    map['committeeBadgeEn'] = committeeBadgeEn;
    map['committeeBadgeGu'] = committeeBadgeGu;
    map['committeeTitleEn'] = committeeTitleEn;
    map['committeeTitleGu'] = committeeTitleGu;
    map['committeeDescEn'] = committeeDescEn;
    map['committeeDescGu'] = committeeDescGu;
    map['ctaTitleEn'] = ctaTitleEn;
    map['ctaTitleGu'] = ctaTitleGu;
    map['ctaDescEn'] = ctaDescEn;
    map['ctaDescGu'] = ctaDescGu;
    map['ctaBtnTextEn'] = ctaBtnTextEn;
    map['ctaBtnTextGu'] = ctaBtnTextGu;
    map['ctaRoute'] = ctaRoute;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminHomeBanner {
  AdminHomeBanner({
    this.id = '',
    this.badgeEn = 'HERITAGE',
    this.badgeGu = 'વારસો',
    this.titleEn = '',
    this.titleGu = '',
    this.subtitleEn = '',
    this.subtitleGu = '',
    this.imageUrl = 'assets/images/pavan_putra_logo.png',
    this.ctaTextEn = 'EXPLORE ARCHIVE',
    this.ctaTextGu = 'આર્કાઇવ જુઓ',
    this.ctaRoute = '/archive',
    this.order = 0,
    this.isActive = true,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminHomeBanner.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    badgeEn = json['badgeEn']?.toString() ?? json['badge_en']?.toString() ?? 'HERITAGE';
    badgeGu = json['badgeGu']?.toString() ?? json['badge_gu']?.toString() ?? 'વારસો';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    subtitleEn = json['subtitleEn']?.toString() ?? json['subtitle_en']?.toString() ?? '';
    subtitleGu = json['subtitleGu']?.toString() ?? json['subtitle_gu']?.toString() ?? '';
    imageUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    ctaTextEn = json['ctaTextEn']?.toString() ?? json['cta_text_en']?.toString() ?? 'EXPLORE';
    ctaTextGu = json['ctaTextGu']?.toString() ?? json['cta_text_gu']?.toString() ?? 'જુઓ';
    ctaRoute = json['ctaRoute']?.toString() ?? json['cta_route']?.toString() ?? '/archive';
    order = _toInt(json['order']) ?? 0;
    isActive = _toBool(json['isActive'] ?? json['is_active']) ?? true;
  }

  factory AdminHomeBanner.fromMap(Map<String, dynamic> map) => AdminHomeBanner.fromJson(map);

  String id = '';
  String badgeEn = 'HERITAGE';
  String badgeGu = 'વારસો';
  String titleEn = '';
  String titleGu = '';
  String subtitleEn = '';
  String subtitleGu = '';
  String imageUrl = 'assets/images/pavan_putra_logo.png';
  String ctaTextEn = 'EXPLORE ARCHIVE';
  String ctaTextGu = 'આર્કાઇવ જુઓ';
  String ctaRoute = '/archive';
  int order = 0;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['badgeEn'] = badgeEn;
    map['badgeGu'] = badgeGu;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['subtitleEn'] = subtitleEn;
    map['subtitleGu'] = subtitleGu;
    map['imageUrl'] = imageUrl;
    map['ctaTextEn'] = ctaTextEn;
    map['ctaTextGu'] = ctaTextGu;
    map['ctaRoute'] = ctaRoute;
    map['order'] = order;
    map['isActive'] = isActive;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminHomePillar {
  AdminHomePillar({
    this.id = '',
    this.number = '૦૧',
    this.titleEn = '',
    this.titleGu = '',
    this.descEn = '',
    this.descGu = '',
    this.iconKey = 'group',
    this.order = 0,
    this.isActive = true,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminHomePillar.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? 'pillar-${DateTime.now().millisecondsSinceEpoch}';
    number = json['number']?.toString() ?? '૦૧';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    descEn = json['descEn']?.toString() ?? json['desc_en']?.toString() ?? '';
    descGu = json['descGu']?.toString() ?? json['desc_gu']?.toString() ?? '';
    iconKey = json['iconKey']?.toString() ?? json['icon_key']?.toString() ?? 'group';
    order = _toInt(json['order']) ?? 0;
    isActive = _toBool(json['isActive'] ?? json['is_active']) ?? true;
  }

  factory AdminHomePillar.fromMap(Map<String, dynamic> map) => AdminHomePillar.fromJson(map);

  String id = '';
  String number = '૦૧';
  String titleEn = '';
  String titleGu = '';
  String descEn = '';
  String descGu = '';
  String iconKey = 'group';
  int order = 0;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['number'] = number;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['descEn'] = descEn;
    map['descGu'] = descGu;
    map['iconKey'] = iconKey;
    map['order'] = order;
    map['isActive'] = isActive;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminHomeBlessing {
  AdminHomeBlessing({
    this.id = '',
    this.quoteEn = '',
    this.quoteGu = '',
    this.authorEn = '',
    this.authorGu = '',
    this.designationEn = '',
    this.designationGu = '',
    this.photoUrl = 'assets/images/pavan_putra_logo.png',
    this.order = 0,
    this.isActive = true,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminHomeBlessing.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? 'blessing-${DateTime.now().millisecondsSinceEpoch}';
    quoteEn = json['quoteEn']?.toString() ?? json['quote_en']?.toString() ?? '';
    quoteGu = json['quoteGu']?.toString() ?? json['quote_gu']?.toString() ?? '';
    authorEn = json['authorEn']?.toString() ?? json['author_en']?.toString() ?? '';
    authorGu = json['authorGu']?.toString() ?? json['author_gu']?.toString() ?? '';
    designationEn = json['designationEn']?.toString() ?? json['designation_en']?.toString() ?? '';
    designationGu = json['designationGu']?.toString() ?? json['designation_gu']?.toString() ?? '';
    photoUrl = json['photoUrl']?.toString() ?? json['photo_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    order = _toInt(json['order']) ?? 0;
    isActive = _toBool(json['isActive'] ?? json['is_active']) ?? true;
  }

  factory AdminHomeBlessing.fromMap(Map<String, dynamic> map) => AdminHomeBlessing.fromJson(map);

  String id = '';
  String quoteEn = '';
  String quoteGu = '';
  String authorEn = '';
  String authorGu = '';
  String designationEn = '';
  String designationGu = '';
  String photoUrl = 'assets/images/pavan_putra_logo.png';
  int order = 0;
  bool isActive = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['quoteEn'] = quoteEn;
    map['quoteGu'] = quoteGu;
    map['authorEn'] = authorEn;
    map['authorGu'] = authorGu;
    map['designationEn'] = designationEn;
    map['designationGu'] = designationGu;
    map['photoUrl'] = photoUrl;
    map['order'] = order;
    map['isActive'] = isActive;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  String getQuote(String lang) => lang == 'gu' ? (quoteGu.trim().isNotEmpty ? quoteGu.trim() : quoteEn.trim()) : (quoteEn.trim().isNotEmpty ? quoteEn.trim() : quoteGu.trim());

  String getAuthor(String lang) =>
      lang == 'gu' ? (authorGu.trim().isNotEmpty ? authorGu.trim() : authorEn.trim()) : (authorEn.trim().isNotEmpty ? authorEn.trim() : authorGu.trim());

  String getDesignation(String lang) => lang == 'gu'
      ? (designationGu.trim().isNotEmpty ? designationGu.trim() : designationEn.trim())
      : (designationEn.trim().isNotEmpty ? designationEn.trim() : designationGu.trim());

  bool get hasQuote => quoteEn.trim().isNotEmpty || quoteGu.trim().isNotEmpty;

  bool get hasAuthor => authorEn.trim().isNotEmpty || authorGu.trim().isNotEmpty;

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

class AdminHomeCtaData {
  AdminHomeCtaData({
    this.invocationEn = '|| Jagti Jogmaya ||',
    this.invocationGu = '|| જાગતી જોગમાયા ||',
    this.mottoEn = 'Connect with our sacred tradition and feel the divine presence of Maa Ambe.',
    this.mottoGu = 'આપણી પ્રાચીન સંસ્કૃતિ, પરંપરા અને ભક્તિ સાથે જોડાઓ અને માં અંબાના આશીર્વાદ પ્રાપ્ત કરો.',
    this.btnTextEn = 'Connect With Us',
    this.btnTextGu = 'સંપર્ક કરો / સહભાગી બનો',
    this.btnRoute = '/contact',
  });

  AdminHomeCtaData.fromJson(dynamic json) {
    if (json is! Map) return;
    invocationEn = json['invocationEn']?.toString() ?? json['invocation_en']?.toString() ?? '|| Jagti Jogmaya ||';
    invocationGu = json['invocationGu']?.toString() ?? json['invocation_gu']?.toString() ?? '|| જાગતી જોગમાયા ||';
    mottoEn = json['mottoEn']?.toString() ?? json['motto_en']?.toString() ?? '';
    mottoGu = json['mottoGu']?.toString() ?? json['motto_gu']?.toString() ?? '';
    btnTextEn = json['btnTextEn']?.toString() ?? json['btn_text_en']?.toString() ?? 'Connect With Us';
    btnTextGu = json['btnTextGu']?.toString() ?? json['btn_text_gu']?.toString() ?? 'સંપર્ક કરો / સહભાગી બનો';
    btnRoute = json['btnRoute']?.toString() ?? json['btn_route']?.toString() ?? '/contact';
  }

  factory AdminHomeCtaData.fromMap(Map<String, dynamic> map) => AdminHomeCtaData.fromJson(map);

  String invocationEn = '|| Jagti Jogmaya ||';
  String invocationGu = '|| જાગતી જોગમાયા ||';
  String mottoEn = 'Connect with our sacred tradition and feel the divine presence of Maa Ambe.';
  String mottoGu = 'આપણી પ્રાચીન સંસ્કૃતિ, પરંપરા અને ભક્તિ સાથે જોડાઓ અને માં અંબાના આશીર્વાદ પ્રાપ્ત કરો.';
  String btnTextEn = 'Connect With Us';
  String btnTextGu = 'સંપર્ક કરો / સહભાગી બનો';
  String btnRoute = '/contact';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['invocationEn'] = invocationEn;
    map['invocationGu'] = invocationGu;
    map['mottoEn'] = mottoEn;
    map['mottoGu'] = mottoGu;
    map['btnTextEn'] = btnTextEn;
    map['btnTextGu'] = btnTextGu;
    map['btnRoute'] = btnRoute;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
  AdminGarbiYear({this.id = '', this.year = 2025, this.titleEn = '', this.titleGu = '', this.description = '', this.isPublished = true, this.albumCount = 0});

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminGarbiYear.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    year = _toInt(json['year']) ?? 2025;
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    isPublished = _toBool(json['isPublished'] ?? json['is_published']) ?? true;
    albumCount = _toInt(json['albumCount'] ?? json['album_count']) ?? 0;
  }

  factory AdminGarbiYear.fromMap(Map<String, dynamic> map) => AdminGarbiYear.fromJson(map);

  String id = '';
  int year = 2025;
  String titleEn = '';
  String titleGu = '';
  String description = '';
  bool isPublished = true;
  int albumCount = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['year'] = year;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['description'] = description;
    map['isPublished'] = isPublished;
    map['albumCount'] = albumCount;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
  AdminAlbum({
    this.id = '',
    this.year = '2025',
    this.name = '',
    this.nameGu = '',
    this.dayTag = 'Day 1',
    this.dayTagGu = '',
    this.description = '',
    this.descriptionGu = '',
    this.coverImageUrl = 'assets/images/pavan_putra_logo.png',
    this.photoCount = 0,
  });

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  AdminAlbum.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    year = json['year']?.toString() ?? '2025';
    name = json['name']?.toString() ?? json['nameEn']?.toString() ?? json['name_en']?.toString() ?? '';
    nameGu = json['nameGu']?.toString() ?? json['name_gu']?.toString() ?? '';
    dayTag = json['dayTag']?.toString() ?? json['day_tag']?.toString() ?? 'Day 1';
    dayTagGu = json['dayTagGu']?.toString() ?? json['day_tag_gu']?.toString() ?? '';
    description = json['description']?.toString() ?? json['descriptionEn']?.toString() ?? json['description_en']?.toString() ?? '';
    descriptionGu = json['descriptionGu']?.toString() ?? json['description_gu']?.toString() ?? '';
    coverImageUrl = json['coverImageUrl']?.toString() ?? json['cover_image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    photoCount = _toInt(json['photoCount'] ?? json['photo_count']) ?? 0;
  }

  factory AdminAlbum.fromMap(Map<String, dynamic> map) => AdminAlbum.fromJson(map);

  String id = '';
  String year = '2025';
  String name = '';
  String nameGu = '';
  String dayTag = 'Day 1';
  String dayTagGu = '';
  String description = '';
  String descriptionGu = '';
  String coverImageUrl = 'assets/images/pavan_putra_logo.png';
  int photoCount = 0;

  String getName([String lang = 'en']) {
    if (lang == 'gu' && nameGu.trim().isNotEmpty) return nameGu.trim();
    return name;
  }

  String getDescription([String lang = 'en']) {
    if (lang == 'gu' && descriptionGu.trim().isNotEmpty) return descriptionGu.trim();
    return description;
  }

  String getDayTag([String lang = 'en']) {
    if (lang == 'gu' && dayTagGu.trim().isNotEmpty) return dayTagGu.trim();
    return dayTag;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['year'] = year;
    map['name'] = name;
    map['nameGu'] = nameGu;
    map['dayTag'] = dayTag;
    map['dayTagGu'] = dayTagGu;
    map['description'] = description;
    map['descriptionGu'] = descriptionGu;
    map['coverImageUrl'] = coverImageUrl;
    map['photoCount'] = photoCount;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  AdminAlbum copyWith({
    String? id,
    String? year,
    String? name,
    String? nameGu,
    String? dayTag,
    String? dayTagGu,
    String? description,
    String? descriptionGu,
    String? coverImageUrl,
    int? photoCount,
  }) {
    return AdminAlbum(
      id: id ?? this.id,
      year: year ?? this.year,
      name: name ?? this.name,
      nameGu: nameGu ?? this.nameGu,
      dayTag: dayTag ?? this.dayTag,
      dayTagGu: dayTagGu ?? this.dayTagGu,
      description: description ?? this.description,
      descriptionGu: descriptionGu ?? this.descriptionGu,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}

class AdminPhoto {
  AdminPhoto({
    this.id = '',
    this.year = '2025',
    this.albumId = '',
    this.day = 'Day 1',
    this.titleEn = '',
    this.titleGu = '',
    this.imageUrl = 'assets/images/pavan_putra_logo.png',
    this.caption = '',
    this.isFeatured = true,
  });

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminPhoto.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    year = json['year']?.toString() ?? '2025';
    albumId = json['albumId']?.toString() ?? json['album_id']?.toString() ?? '';
    day = json['day']?.toString() ?? 'Day 1';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    imageUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    caption = json['caption']?.toString() ?? '';
    isFeatured = _toBool(json['isFeatured'] ?? json['is_featured']) ?? true;
  }

  factory AdminPhoto.fromMap(Map<String, dynamic> map) => AdminPhoto.fromJson(map);

  String id = '';
  String year = '2025';
  String albumId = '';
  String day = 'Day 1';
  String titleEn = '';
  String titleGu = '';
  String imageUrl = 'assets/images/pavan_putra_logo.png';
  String caption = '';
  bool isFeatured = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['year'] = year;
    map['albumId'] = albumId;
    map['day'] = day;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['imageUrl'] = imageUrl;
    map['caption'] = caption;
    map['isFeatured'] = isFeatured;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
  AdminVideo({
    this.id = '',
    String? youtubeVideoId,
    this.title = '',
    this.titleGu = '',
    this.tag = 'Garbi',
    this.duration = '',
    this.youtubeUrl = '',
    this.year = '2024',
    String? thumbnailUrl,
    this.isFeatured = true,
    this.isPublished = true,
    this.sourceChannel = 'Ratnadeep Sound',
  }) : youtubeVideoId = youtubeVideoId?.isNotEmpty == true ? youtubeVideoId! : (YoutubeUrlHelper.extractVideoId(youtubeUrl) ?? ''),
       thumbnailUrl = (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
           ? thumbnailUrl
           : ((youtubeVideoId != null && youtubeVideoId.isNotEmpty)
                 ? YoutubeUrlHelper.buildThumbnailUrl(youtubeVideoId)
                 : (YoutubeUrlHelper.extractVideoId(youtubeUrl) != null
                       ? YoutubeUrlHelper.buildThumbnailUrl(YoutubeUrlHelper.extractVideoId(youtubeUrl)!)
                       : 'assets/images/pavan_putra_logo.png'));

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminVideo.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    youtubeUrl = json['youtubeUrl']?.toString() ?? json['youtube_url']?.toString() ?? '';
    final rawExtractedId = json['youtubeVideoId']?.toString() ?? json['youtube_video_id']?.toString() ?? YoutubeUrlHelper.extractVideoId(youtubeUrl) ?? '';
    youtubeVideoId = rawExtractedId;
    title = json['title']?.toString() ?? json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    tag = json['tag']?.toString() ?? json['category']?.toString() ?? 'Garbi';
    duration = json['duration']?.toString() ?? '';
    year = json['year']?.toString() ?? '2024';
    final rawThumb = json['thumbnailUrl']?.toString() ?? json['thumbnail_url']?.toString() ?? '';
    thumbnailUrl = rawThumb.isNotEmpty ? rawThumb : (rawExtractedId.isNotEmpty ? YoutubeUrlHelper.buildThumbnailUrl(rawExtractedId) : 'assets/images/pavan_putra_logo.png');
    isFeatured = _toBool(json['isFeatured'] ?? json['is_featured']) ?? true;
    isPublished = _toBool(json['isPublished'] ?? json['is_published']) ?? true;
    sourceChannel = json['sourceChannel']?.toString() ?? json['source_channel']?.toString() ?? 'Ratnadeep Sound';
  }

  factory AdminVideo.fromMap(Map<String, dynamic> map) => AdminVideo.fromJson(map);

  String id = '';
  String youtubeVideoId = '';
  String title = '';
  String titleGu = '';
  String tag = 'Garbi';
  String duration = '';
  String youtubeUrl = '';
  String year = '2024';
  String thumbnailUrl = 'assets/images/pavan_putra_logo.png';
  bool isFeatured = true;
  bool isPublished = true;
  String sourceChannel = 'Ratnadeep Sound';

  Map<String, dynamic> toJson() {
    final canonId = youtubeVideoId.isNotEmpty ? youtubeVideoId : (YoutubeUrlHelper.extractVideoId(youtubeUrl) ?? '');
    final thumb = thumbnailUrl.isNotEmpty ? thumbnailUrl : (canonId.isNotEmpty ? YoutubeUrlHelper.buildThumbnailUrl(canonId) : 'assets/images/pavan_putra_logo.png');

    final map = <String, dynamic>{};
    map['id'] = id;
    map['youtubeVideoId'] = canonId;
    map['title'] = title;
    map['titleGu'] = titleGu;
    map['tag'] = tag;
    map['duration'] = duration;
    map['youtubeUrl'] = youtubeUrl;
    map['year'] = year;
    map['thumbnailUrl'] = thumb;
    map['isFeatured'] = isFeatured;
    map['isPublished'] = isPublished;
    map['sourceChannel'] = sourceChannel;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
  AdminLiveStreamSettings({this.isLive = false, this.title = '', this.streamUrl = '', this.announcement = '', this.scheduleTime = ''});

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminLiveStreamSettings.fromJson(dynamic json) {
    if (json is! Map) return;
    isLive = _toBool(json['isLive'] ?? json['is_live']) ?? false;
    title = json['title']?.toString() ?? '';
    streamUrl = json['streamUrl']?.toString() ?? json['stream_url']?.toString() ?? '';
    announcement = json['announcement']?.toString() ?? '';
    scheduleTime = json['scheduleTime']?.toString() ?? json['schedule_time']?.toString() ?? '';
  }

  factory AdminLiveStreamSettings.fromMap(Map<String, dynamic> map) => AdminLiveStreamSettings.fromJson(map);

  bool isLive = false;
  String title = '';
  String streamUrl = '';
  String announcement = '';
  String scheduleTime = '';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isLive'] = isLive;
    map['title'] = title;
    map['streamUrl'] = streamUrl;
    map['announcement'] = announcement;
    map['scheduleTime'] = scheduleTime;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
  AdminBlog({
    this.id = '',
    this.slug = '',
    this.title = '',
    this.titleGu = '',
    this.category = 'Heritage',
    this.date = '',
    this.readTime = '5 min',
    this.snippet = '',
    this.snippetGu = '',
    this.content = '',
    this.contentGu = '',
    this.imageUrl = 'assets/images/pavan_putra_logo.png',
    this.isPublished = true,
  });

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminBlog.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    slug = json['slug']?.toString() ?? '';
    title = json['title']?.toString() ?? json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    category = json['category']?.toString() ?? 'Heritage';
    date = json['date']?.toString() ?? '';
    readTime = json['readTime']?.toString() ?? json['read_time']?.toString() ?? '5 min';
    snippet = json['snippet']?.toString() ?? json['snippetEn']?.toString() ?? json['snippet_en']?.toString() ?? '';
    snippetGu = json['snippetGu']?.toString() ?? json['snippet_gu']?.toString() ?? '';
    content = json['content']?.toString() ?? json['contentEn']?.toString() ?? json['content_en']?.toString() ?? '';
    contentGu = json['contentGu']?.toString() ?? json['content_gu']?.toString() ?? '';
    imageUrl = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? 'assets/images/pavan_putra_logo.png';
    isPublished = _toBool(json['isPublished'] ?? json['is_published']) ?? true;
  }

  factory AdminBlog.fromMap(Map<String, dynamic> map) => AdminBlog.fromJson(map);

  String id = '';
  String slug = '';
  String title = '';
  String titleGu = '';
  String category = 'Heritage';
  String date = '';
  String readTime = '5 min';
  String snippet = '';
  String snippetGu = '';
  String content = '';
  String contentGu = '';
  String imageUrl = 'assets/images/pavan_putra_logo.png';
  bool isPublished = true;

  String getTitle(String lang) => (lang == 'gu' && titleGu.isNotEmpty) ? titleGu : title;

  String getSnippet(String lang) => (lang == 'gu' && snippetGu.isNotEmpty) ? snippetGu : snippet;

  String getContent(String lang) => (lang == 'gu' && contentGu.isNotEmpty) ? contentGu : content;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['slug'] = slug;
    map['title'] = title;
    map['titleGu'] = titleGu;
    map['category'] = category;
    map['date'] = date;
    map['readTime'] = readTime;
    map['snippet'] = snippet;
    map['snippetGu'] = snippetGu;
    map['content'] = content;
    map['contentGu'] = contentGu;
    map['imageUrl'] = imageUrl;
    map['isPublished'] = isPublished;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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
    String? contentGu,
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
      contentGu: contentGu ?? this.contentGu,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

class AdminEnquiry {
  AdminEnquiry({this.id = '', this.name = '', this.phone = '', this.email = '', this.message = '', this.date = '', this.status = 'New'});

  AdminEnquiry.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    phone = json['phone']?.toString() ?? '';
    email = json['email']?.toString() ?? '';
    message = json['message']?.toString() ?? '';
    date = json['date']?.toString() ?? '';
    status = json['status']?.toString() ?? 'New';
  }

  factory AdminEnquiry.fromMap(Map<String, dynamic> map) => AdminEnquiry.fromJson(map);

  String id = '';
  String name = '';
  String phone = '';
  String email = '';
  String message = '';
  String date = '';
  String status = 'New';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['phone'] = phone;
    map['email'] = email;
    map['message'] = message;
    map['date'] = date;
    map['status'] = status;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

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

class AdminNotificationEmail {
  AdminNotificationEmail({
    this.id = '',
    this.email = '',
    this.recipientName = '',
    this.department = 'General Management',
    this.isPrimary = false,
    this.isEnabled = true,
    this.createdAt = '',
  });

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminNotificationEmail.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? '';
    email = json['email']?.toString() ?? '';
    recipientName = json['recipientName']?.toString() ?? '';
    department = json['department']?.toString() ?? 'General Management';
    isPrimary = _toBool(json['isPrimary'] ?? json['is_primary']) ?? false;
    isEnabled = _toBool(json['isEnabled'] ?? json['is_enabled']) ?? true;
    createdAt = json['createdAt']?.toString() ?? '';
  }

  factory AdminNotificationEmail.fromMap(Map<String, dynamic> map) => AdminNotificationEmail.fromJson(map);

  String id = '';
  String email = '';
  String recipientName = '';
  String department = 'General Management';
  bool isPrimary = false;
  bool isEnabled = true;
  String createdAt = '';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['recipientName'] = recipientName;
    map['department'] = department;
    map['isPrimary'] = isPrimary;
    map['isEnabled'] = isEnabled;
    map['createdAt'] = createdAt.isNotEmpty ? createdAt : DateTime.now().toIso8601String();
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  AdminNotificationEmail copyWith({String? id, String? email, String? recipientName, String? department, bool? isPrimary, bool? isEnabled, String? createdAt}) {
    return AdminNotificationEmail(
      id: id ?? this.id,
      email: email ?? this.email,
      recipientName: recipientName ?? this.recipientName,
      department: department ?? this.department,
      isPrimary: isPrimary ?? this.isPrimary,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AdminSettings {
  AdminSettings({
    this.mandalNameEn = 'Pavan Putra Garbi Mandal',
    this.mandalNameGu = 'શ્રી પવનપુત્ર ગરબી મંડળ',
    this.contactPhone = '',
    this.contactEmail = '',
    this.address = '',
    this.addressGu = '',
    this.dailyAartiTime = '',
    this.dailyAartiTimeGu = '',
    this.youtubeChannel = '',
    this.instagramHandle = '',
    this.facebookUrl = 'https://facebook.com/PavanPutraGarbiRajkot',
    this.whatsappNumber = '+919876543210',
    this.logoImageUrl = 'assets/images/pavan_putra_logo.png',
    this.paymentQrImageUrl = '',
    this.paymentUpiId = '',
    this.paymentRecipientName = '',
    this.paymentRecipientNameGu = '',
    this.paymentNotes = '',
    this.paymentNotesGu = '',
    this.isPaymentEnabled = false,
  });

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminSettings.fromJson(dynamic json) {
    if (json is! Map) return;
    mandalNameEn = json['mandalNameEn']?.toString() ?? json['mandal_name_en']?.toString() ?? 'Pavan Putra Garbi Mandal';
    mandalNameGu = json['mandalNameGu']?.toString() ?? json['mandal_name_gu']?.toString() ?? 'શ્રી પવનપુત્ર ગરબી મંડળ';
    contactPhone = json['contactPhone']?.toString() ?? json['contact_phone']?.toString() ?? '';
    contactEmail = json['contactEmail']?.toString() ?? json['contact_email']?.toString() ?? '';
    address = json['address']?.toString() ?? '';
    addressGu = json['addressGu']?.toString() ?? json['address_gu']?.toString() ?? '';
    dailyAartiTime = json['dailyAartiTime']?.toString() ?? json['daily_aarti_time']?.toString() ?? '';
    dailyAartiTimeGu = json['dailyAartiTimeGu']?.toString() ?? json['daily_aarti_time_gu']?.toString() ?? '';
    youtubeChannel = json['youtubeChannel']?.toString() ?? json['youtube_channel']?.toString() ?? '';
    instagramHandle = json['instagramHandle']?.toString() ?? json['instagram_handle']?.toString() ?? '';
    facebookUrl = json['facebookUrl']?.toString() ?? json['facebook_url']?.toString() ?? 'https://facebook.com/PavanPutraGarbiRajkot';
    whatsappNumber = json['whatsappNumber']?.toString() ?? json['whatsapp_number']?.toString() ?? '+919876543210';
    final rawLogo = (json['logoImageUrl']?.toString() ?? json['logo_image_url']?.toString() ?? '').trim();
    logoImageUrl = rawLogo.isNotEmpty ? rawLogo : 'assets/images/pavan_putra_logo.png';
    paymentQrImageUrl = json['paymentQrImageUrl']?.toString() ?? json['payment_qr_image_url']?.toString() ?? '';
    paymentUpiId = json['paymentUpiId']?.toString() ?? json['payment_upi_id']?.toString() ?? '';
    paymentRecipientName = json['paymentRecipientName']?.toString() ?? json['payment_recipient_name']?.toString() ?? '';
    paymentRecipientNameGu = json['paymentRecipientNameGu']?.toString() ?? json['payment_recipient_name_gu']?.toString() ?? '';
    paymentNotes = json['paymentNotes']?.toString() ?? json['payment_notes']?.toString() ?? '';
    paymentNotesGu = json['paymentNotesGu']?.toString() ?? json['payment_notes_gu']?.toString() ?? '';
    isPaymentEnabled = _toBool(json['isPaymentEnabled'] ?? json['is_payment_enabled']) ?? false;
  }

  factory AdminSettings.fromMap(Map<String, dynamic> map) => AdminSettings.fromJson(map);

  String mandalNameEn = 'Pavan Putra Garbi Mandal';
  String mandalNameGu = 'શ્રી પવનપુત્ર ગરબી મંડળ';
  String contactPhone = '';
  String contactEmail = '';
  String address = '';
  String addressGu = '';
  String dailyAartiTime = '';
  String dailyAartiTimeGu = '';
  String youtubeChannel = '';
  String instagramHandle = '';
  String facebookUrl = 'https://facebook.com/PavanPutraGarbiRajkot';
  String whatsappNumber = '+919876543210';
  String logoImageUrl = 'assets/images/pavan_putra_logo.png';
  String paymentQrImageUrl = '';
  String paymentUpiId = '';
  String paymentRecipientName = '';
  String paymentRecipientNameGu = '';
  String paymentNotes = '';
  String paymentNotesGu = '';
  bool isPaymentEnabled = false;

  String get logoUrl => logoImageUrl;

  String getMandalName(String lang) {
    if (lang == 'gu') {
      return mandalNameGu.trim().isNotEmpty ? mandalNameGu.trim() : 'શ્રી પવનપુત્ર ગરબી મંડળ — રાજકોટ';
    }
    return mandalNameEn.trim().isNotEmpty ? mandalNameEn.trim() : 'Pavan Putra Garbi Mandal — Rajkot';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['mandalNameEn'] = mandalNameEn;
    map['mandalNameGu'] = mandalNameGu;
    map['contactPhone'] = contactPhone;
    map['contactEmail'] = contactEmail;
    map['address'] = address;
    map['addressGu'] = addressGu;
    map['dailyAartiTime'] = dailyAartiTime;
    map['dailyAartiTimeGu'] = dailyAartiTimeGu;
    map['youtubeChannel'] = youtubeChannel;
    map['instagramHandle'] = instagramHandle;
    map['facebookUrl'] = facebookUrl;
    map['whatsappNumber'] = whatsappNumber;
    map['logoImageUrl'] = logoImageUrl;
    map['paymentQrImageUrl'] = paymentQrImageUrl;
    map['paymentUpiId'] = paymentUpiId;
    map['paymentRecipientName'] = paymentRecipientName;
    map['paymentRecipientNameGu'] = paymentRecipientNameGu;
    map['paymentNotes'] = paymentNotes;
    map['paymentNotesGu'] = paymentNotesGu;
    map['isPaymentEnabled'] = isPaymentEnabled;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  AdminSettings copyWith({
    String? mandalNameEn,
    String? mandalNameGu,
    String? contactPhone,
    String? contactEmail,
    String? address,
    String? addressGu,
    String? dailyAartiTime,
    String? dailyAartiTimeGu,
    String? youtubeChannel,
    String? instagramHandle,
    String? facebookUrl,
    String? whatsappNumber,
    String? logoImageUrl,
    String? paymentQrImageUrl,
    String? paymentUpiId,
    String? paymentRecipientName,
    String? paymentRecipientNameGu,
    String? paymentNotes,
    String? paymentNotesGu,
    bool? isPaymentEnabled,
  }) {
    return AdminSettings(
      mandalNameEn: mandalNameEn ?? this.mandalNameEn,
      mandalNameGu: mandalNameGu ?? this.mandalNameGu,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      address: address ?? this.address,
      addressGu: addressGu ?? this.addressGu,
      dailyAartiTime: dailyAartiTime ?? this.dailyAartiTime,
      dailyAartiTimeGu: dailyAartiTimeGu ?? this.dailyAartiTimeGu,
      youtubeChannel: youtubeChannel ?? this.youtubeChannel,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      logoImageUrl: logoImageUrl ?? this.logoImageUrl,
      paymentQrImageUrl: paymentQrImageUrl ?? this.paymentQrImageUrl,
      paymentUpiId: paymentUpiId ?? this.paymentUpiId,
      paymentRecipientName: paymentRecipientName ?? this.paymentRecipientName,
      paymentRecipientNameGu: paymentRecipientNameGu ?? this.paymentRecipientNameGu,
      paymentNotes: paymentNotes ?? this.paymentNotes,
      paymentNotesGu: paymentNotesGu ?? this.paymentNotesGu,
      isPaymentEnabled: isPaymentEnabled ?? this.isPaymentEnabled,
    );
  }
}

class AdminFooterLink {
  AdminFooterLink({this.id = '', this.titleEn = '', this.titleGu = '', this.url = '/', this.column = 'col1', this.order = 1, this.isEnabled = true, this.isExternal = false});

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminFooterLink.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? 'flink-${DateTime.now().millisecondsSinceEpoch}';
    titleEn = json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '';
    titleGu = json['titleGu']?.toString() ?? json['title_gu']?.toString() ?? '';
    url = json['url']?.toString() ?? '/';
    column = json['column']?.toString() ?? 'col1';
    order = _toInt(json['order']) ?? 1;
    isEnabled = _toBool(json['isEnabled'] ?? json['is_enabled']) ?? true;
    isExternal = _toBool(json['isExternal'] ?? json['is_external']) ?? false;
  }

  factory AdminFooterLink.fromMap(Map<String, dynamic> map) => AdminFooterLink.fromJson(map);

  String id = '';
  String titleEn = '';
  String titleGu = '';
  String url = '/';
  String column = 'col1';
  int order = 1;
  bool isEnabled = true;
  bool isExternal = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['titleEn'] = titleEn;
    map['titleGu'] = titleGu;
    map['url'] = url;
    map['column'] = column;
    map['order'] = order;
    map['isEnabled'] = isEnabled;
    map['isExternal'] = isExternal;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  AdminFooterLink copyWith({String? id, String? titleEn, String? titleGu, String? url, String? column, int? order, bool? isEnabled, bool? isExternal}) {
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

class AdminFooterSocialLink {
  AdminFooterSocialLink({this.id = '', this.platform = 'Social', this.url = '', this.iconKey = 'link', this.order = 1, this.isEnabled = true});

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1';
    }
    return null;
  }

  AdminFooterSocialLink.fromJson(dynamic json) {
    if (json is! Map) return;
    id = json['id']?.toString() ?? 'fsoc-${DateTime.now().millisecondsSinceEpoch}';
    platform = json['platform']?.toString() ?? 'Social';
    url = json['url']?.toString() ?? '';
    iconKey = json['iconKey']?.toString() ?? json['icon_key']?.toString() ?? 'link';
    order = _toInt(json['order']) ?? 1;
    isEnabled = _toBool(json['isEnabled'] ?? json['is_enabled']) ?? true;
  }

  factory AdminFooterSocialLink.fromMap(Map<String, dynamic> map) => AdminFooterSocialLink.fromJson(map);

  String id = '';
  String platform = 'Social';
  String url = '';
  String iconKey = 'link';
  int order = 1;
  bool isEnabled = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['platform'] = platform;
    map['url'] = url;
    map['iconKey'] = iconKey;
    map['order'] = order;
    map['isEnabled'] = isEnabled;
    map['updatedAt'] = DateTime.now().toIso8601String();
    return map;
  }

  Map<String, dynamic> toMap() => toJson();

  AdminFooterSocialLink copyWith({String? id, String? platform, String? url, String? iconKey, int? order, bool? isEnabled}) {
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

  AdminDataStore._internal();

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
  final List<AdminNotificationEmail> _notificationEmails = [];
  final List<AdminActivityLog> _activityLogs = [];
  final List<AdminFooterLink> _footerLinks = [];
  final List<AdminFooterSocialLink> _footerSocialLinks = [];
  final Map<String, AdminContentField> _siteContentMap = {};

  AdminLiveStreamSettings _liveStreamSettings = AdminLiveStreamSettings();

  AdminSettings _settings = AdminSettings();

  bool _isFirestoreConnected = false;

  bool get isFirestoreConnected => _isFirestoreConnected;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  bool _isBusy = false;
  String? _busyMessage;

  bool get isBusy => _isBusy;

  String? get busyMessage => _busyMessage;

  void setBusy(bool value, [String? message]) {
    _isBusy = value;
    _busyMessage = message;
    notifyListeners();
  }

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

  /// True when all essential home screen data groups are populated in memory
  bool get hasEssentialHomeData => _pillars.isNotEmpty && _blessings.isNotEmpty && _years.isNotEmpty;

  List<AdminAlbum> get albums => List.unmodifiable(_albums);

  List<AdminPhoto> get photos => List.unmodifiable(_photos);

  List<AdminVideo> get videos => List.unmodifiable(_videos);

  List<AdminVideo> get publishedVideos => List.unmodifiable(_videos.where((v) => v.isPublished).toList());

  AdminLiveStreamSettings get liveStreamSettings => _liveStreamSettings;

  List<AdminBlog> get blogs => List.unmodifiable(_blogs);

  List<AdminEnquiry> get enquiries => List.unmodifiable(_enquiries);

  List<AdminNotificationEmail> get notificationEmails => List.unmodifiable(_notificationEmails);

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
      img = 'assets/images/pavan_putra_logo.png';
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
    if (img.isEmpty) img = 'assets/images/pavan_putra_logo.png';

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

    return {'tagEn': getVal('sec_blog_tag', 'en'), 'tagGu': getVal('sec_blog_tag', 'gu'), 'titleEn': getVal('sec_blog_title', 'en'), 'titleGu': getVal('sec_blog_title', 'gu')};
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

  // --- Cloud Firestore Integration ---

  Future<QuerySnapshot<Map<String, dynamic>>> _getCollectionWithFallback(
    CollectionReference<Map<String, dynamic>> col, {
    bool forceServer = false,
  }) async {
    if (forceServer) {
      try {
        return await col.get(const GetOptions(source: Source.server));
      } catch (e) {
        debugPrint('Server fetch fallback to cache for ${col.path}: $e');
        return await col.get();
      }
    }
    return await col.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getDocWithFallback(
    DocumentReference<Map<String, dynamic>> doc, {
    bool forceServer = false,
  }) async {
    if (forceServer) {
      try {
        return await doc.get(const GetOptions(source: Source.server));
      } catch (e) {
        debugPrint('Server fetch fallback to cache for ${doc.path}: $e');
        return await doc.get();
      }
    }
    return await doc.get();
  }

  Future<void> _fetchSettings(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final settingsDoc = await _getDocWithFallback(
        db.collection('settings').doc('mandal_settings'),
        forceServer: forceServer,
      );
      if (settingsDoc.exists && settingsDoc.data() != null && settingsDoc.data()!.isNotEmpty) {
        final data = settingsDoc.data()!;
        if (data['is_deleted'] != true && data['isDeleted'] != true) {
          _settings = AdminSettings.fromMap(data);
        }
      }
    } catch (e) {
      debugPrint('Settings fetch notice: $e');
    }
  }

  Future<void> _fetchSiteContent(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final contentSnap = await _getCollectionWithFallback(
        db.collection('site_content'),
        forceServer: forceServer,
      );
      for (final doc in contentSnap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        final f = AdminContentField.fromMap(data);
        _siteContentMap[f.key] = f;
      }
    } catch (e) {
      debugPrint('Site content fetch notice: $e');
    }
  }

  Future<void> _fetchHomeBanners(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final hbSnap = await _getCollectionWithFallback(
        db.collection('home_banners'),
        forceServer: forceServer,
      );
      if (hbSnap.docs.isNotEmpty) {
        _homeBanners.clear();
        for (final doc in hbSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _homeBanners.add(AdminHomeBanner.fromMap(data));
        }
        _homeBanners.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Home banners fetch notice: $e');
    }
  }

  Future<void> _fetchHomeAboutCards(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final acSnap = await _getCollectionWithFallback(
        db.collection('home_about_cards'),
        forceServer: forceServer,
      );
      if (acSnap.docs.isNotEmpty) {
        _aboutCards.clear();
        for (final doc in acSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _aboutCards.add(AdminAboutCard.fromMap(data));
        }
        _aboutCards.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('About cards fetch notice: $e');
    }
  }

  Future<void> _fetchPillars(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final pillarsSnap = await _getCollectionWithFallback(
        db.collection('home_pillars'),
        forceServer: forceServer,
      );
      if (pillarsSnap.docs.isNotEmpty) {
        _pillars.clear();
        for (final doc in pillarsSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _pillars.add(AdminHomePillar.fromMap(data));
        }
        _pillars.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Pillars fetch notice: $e');
    }
  }

  Future<void> _fetchHomeSingers(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final hsSnap = await _getCollectionWithFallback(
        db.collection('home_singers'),
        forceServer: forceServer,
      );
      if (hsSnap.docs.isNotEmpty) {
        _homeSingers.clear();
        for (final doc in hsSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _homeSingers.add(AdminHomeSinger.fromMap(data));
        }
        _homeSingers.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Singers fetch notice: $e');
    }
  }

  Future<void> _fetchBlessings(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final blessingsSnap = await _getCollectionWithFallback(
        db.collection('home_blessings'),
        forceServer: forceServer,
      );
      if (blessingsSnap.docs.isNotEmpty) {
        _blessings.clear();
        for (final doc in blessingsSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _blessings.add(AdminHomeBlessing.fromMap(data));
        }
        _blessings.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Blessings fetch notice: $e');
    }
  }

  Future<void> _fetchFooter(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final results = await Future.wait([
        _getCollectionWithFallback(db.collection('footer_links'), forceServer: forceServer),
        _getCollectionWithFallback(db.collection('footer_social_links'), forceServer: forceServer),
      ]);
      final fLinksSnap = results[0];
      if (fLinksSnap.docs.isNotEmpty) {
        _footerLinks.clear();
        for (final doc in fLinksSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _footerLinks.add(AdminFooterLink.fromMap(data));
        }
        _footerLinks.sort((a, b) => a.order.compareTo(b.order));
      }
      final fSocSnap = results[1];
      if (fSocSnap.docs.isNotEmpty) {
        _footerSocialLinks.clear();
        for (final doc in fSocSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _footerSocialLinks.add(AdminFooterSocialLink.fromMap(data));
        }
        _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
      }
    } catch (e) {
      debugPrint('Footer fetch notice: $e');
    }
  }

  Future<void> _fetchLiveStream(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final liveDoc = await _getDocWithFallback(
        db.collection('live_stream').doc('current'),
        forceServer: forceServer,
      );
      if (liveDoc.exists && liveDoc.data() != null && liveDoc.data()!.isNotEmpty) {
        final data = liveDoc.data()!;
        if (data['is_deleted'] != true && data['isDeleted'] != true) {
          _liveStreamSettings = AdminLiveStreamSettings.fromMap(data);
        }
      }
    } catch (e) {
      debugPrint('Live stream fetch notice: $e');
    }
  }

  Future<void> _fetchGarbiYears(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final yearsSnap = await _getCollectionWithFallback(
        db.collection('garbi_years'),
        forceServer: forceServer,
      );
      if (yearsSnap.docs.isNotEmpty) {
        _years.clear();
        for (final doc in yearsSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _years.add(AdminGarbiYear.fromMap(data));
        }
        _years.sort((a, b) => b.year.compareTo(a.year));
      }
    } catch (e) {
      debugPrint('Years fetch notice: $e');
    }
  }

  Future<void> _fetchAlbums(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final albumsSnap = await _getCollectionWithFallback(
        db.collection('albums'),
        forceServer: forceServer,
      );
      if (albumsSnap.docs.isNotEmpty) {
        _albums.clear();
        for (final doc in albumsSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _albums.add(AdminAlbum.fromMap(data));
        }
      }
    } catch (e) {
      debugPrint('Albums fetch notice: $e');
    }
  }

  Future<void> _fetchHomeVideosPreview(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final col = db.collection('videos');
      QuerySnapshot<Map<String, dynamic>> videosSnap;
      if (forceServer) {
        try {
          videosSnap = await col.where('isPublished', isEqualTo: true).limit(6).get(const GetOptions(source: Source.server));
        } catch (_) {
          videosSnap = await col.where('isPublished', isEqualTo: true).limit(6).get();
        }
      } else {
        videosSnap = await col.where('isPublished', isEqualTo: true).limit(6).get();
      }
      if (videosSnap.docs.isNotEmpty) {
        _videos.clear();
        for (final doc in videosSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _videos.add(AdminVideo.fromMap(data));
        }
      }
    } catch (e) {
      debugPrint('Home videos preview notice: $e');
    }
  }

  Future<void> _fetchHomeBlogsPreview(FirebaseFirestore db, {bool forceServer = false}) async {
    try {
      final col = db.collection('blogs');
      QuerySnapshot<Map<String, dynamic>> blogsSnap;
      if (forceServer) {
        try {
          blogsSnap = await col.limit(3).get(const GetOptions(source: Source.server));
        } catch (_) {
          blogsSnap = await col.limit(3).get();
        }
      } else {
        blogsSnap = await col.limit(3).get();
      }
      if (blogsSnap.docs.isNotEmpty) {
        _blogs.clear();
        for (final doc in blogsSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _blogs.add(AdminBlog.fromMap(data));
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
        try {
          final decoded = jsonDecode(settingsJson);
          if (decoded is Map) {
            _settings = AdminSettings.fromJson(decoded);
          }
        } catch (_) {}
      }

      // 2. Site Content
      final contentJson = prefs.getString('ppg_cache_site_content');
      if (contentJson != null && contentJson.isNotEmpty) {
        try {
          final list = jsonDecode(contentJson);
          if (list is List) {
            for (final item in list) {
              if (item is Map) {
                final f = AdminContentField.fromJson(item);
                _siteContentMap[f.key] = f;
              }
            }
          }
        } catch (_) {}
      }

      // 3. Home Banners
      final bannersJson = prefs.getString('ppg_cache_home_banners');
      if (bannersJson != null && bannersJson.isNotEmpty) {
        try {
          final list = jsonDecode(bannersJson);
          if (list is List) {
            _homeBanners.clear();
            for (final item in list) {
              if (item is Map) {
                _homeBanners.add(AdminHomeBanner.fromJson(item));
              }
            }
            _homeBanners.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 4. Home About Cards
      final cardsJson = prefs.getString('ppg_cache_home_about_cards');
      if (cardsJson != null && cardsJson.isNotEmpty) {
        try {
          final list = jsonDecode(cardsJson);
          if (list is List) {
            _aboutCards.clear();
            for (final item in list) {
              if (item is Map) {
                _aboutCards.add(AdminAboutCard.fromJson(item));
              }
            }
            _aboutCards.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 5. Pillars
      final pillarsJson = prefs.getString('ppg_cache_home_pillars');
      if (pillarsJson != null && pillarsJson.isNotEmpty) {
        try {
          final list = jsonDecode(pillarsJson);
          if (list is List) {
            _pillars.clear();
            for (final item in list) {
              if (item is Map) {
                _pillars.add(AdminHomePillar.fromJson(item));
              }
            }
            _pillars.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 6. Singers
      final singersJson = prefs.getString('ppg_cache_home_singers');
      if (singersJson != null && singersJson.isNotEmpty) {
        try {
          final list = jsonDecode(singersJson);
          if (list is List) {
            _homeSingers.clear();
            for (final item in list) {
              if (item is Map) {
                _homeSingers.add(AdminHomeSinger.fromJson(item));
              }
            }
            _homeSingers.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 7. Blessings
      final blessingsJson = prefs.getString('ppg_cache_home_blessings');
      if (blessingsJson != null && blessingsJson.isNotEmpty) {
        try {
          final list = jsonDecode(blessingsJson);
          if (list is List) {
            _blessings.clear();
            for (final item in list) {
              if (item is Map) {
                _blessings.add(AdminHomeBlessing.fromJson(item));
              }
            }
            _blessings.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 8. Footer Social Links
      final footerJson = prefs.getString('ppg_cache_footer_social_links');
      if (footerJson != null && footerJson.isNotEmpty) {
        try {
          final list = jsonDecode(footerJson);
          if (list is List) {
            _footerSocialLinks.clear();
            for (final item in list) {
              if (item is Map) {
                _footerSocialLinks.add(AdminFooterSocialLink.fromJson(item));
              }
            }
            _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 9. Live Stream
      final liveJson = prefs.getString('ppg_cache_live_stream');
      if (liveJson != null && liveJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(liveJson);
          if (decoded is Map) {
            _liveStreamSettings = AdminLiveStreamSettings.fromJson(decoded);
          }
        } catch (_) {}
      }

      // 10. Garbi Years
      final yearsJson = prefs.getString('ppg_cache_garbi_years');
      if (yearsJson != null && yearsJson.isNotEmpty) {
        try {
          final list = jsonDecode(yearsJson);
          if (list is List) {
            _years.clear();
            for (final item in list) {
              if (item is Map) {
                _years.add(AdminGarbiYear.fromJson(item));
              }
            }
            _years.sort((a, b) => b.year.compareTo(a.year));
          }
        } catch (_) {}
      }

      // 11. Albums
      final albumsJson = prefs.getString('ppg_cache_albums');
      if (albumsJson != null && albumsJson.isNotEmpty) {
        try {
          final list = jsonDecode(albumsJson);
          if (list is List) {
            _albums.clear();
            for (final item in list) {
              if (item is Map) {
                _albums.add(AdminAlbum.fromJson(item));
              }
            }
          }
        } catch (_) {}
      }

      // 12. Videos
      final videosJson = prefs.getString('ppg_cache_videos');
      if (videosJson != null && videosJson.isNotEmpty) {
        try {
          final list = jsonDecode(videosJson);
          if (list is List) {
            _videos.clear();
            for (final item in list) {
              if (item is Map) {
                _videos.add(AdminVideo.fromJson(item));
              }
            }
          }
        } catch (_) {}
      }

      // 13. Blogs
      final blogsJson = prefs.getString('ppg_cache_blogs');
      if (blogsJson != null && blogsJson.isNotEmpty) {
        try {
          final list = jsonDecode(blogsJson);
          if (list is List) {
            _blogs.clear();
            for (final item in list) {
              if (item is Map) {
                _blogs.add(AdminBlog.fromJson(item));
              }
            }
          }
        } catch (_) {}
      }

      // 14. Committee Members
      final cmJson = prefs.getString('ppg_cache_committee_members');
      if (cmJson != null && cmJson.isNotEmpty) {
        try {
          final list = jsonDecode(cmJson);
          if (list is List) {
            _committeeMembers.clear();
            for (final item in list) {
              if (item is Map) {
                _committeeMembers.add(AdminCommitteeMember.fromJson(item));
              }
            }
            _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 15. About Principles
      final prJson = prefs.getString('ppg_cache_about_principles');
      if (prJson != null && prJson.isNotEmpty) {
        try {
          final list = jsonDecode(prJson);
          if (list is List) {
            _aboutPrinciples.clear();
            for (final item in list) {
              if (item is Map) {
                _aboutPrinciples.add(AdminAboutPrinciple.fromJson(item));
              }
            }
            _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      // 16. History Milestones
      final hmJson = prefs.getString('ppg_cache_history_milestones');
      if (hmJson != null && hmJson.isNotEmpty) {
        try {
          final list = jsonDecode(hmJson);
          if (list is List) {
            _historyMilestones.clear();
            for (final item in list) {
              if (item is Map) {
                _historyMilestones.add(AdminHistoryMilestone.fromJson(item));
              }
            }
            _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
          }
        } catch (_) {}
      }

      if (hasEssentialHomeData) {
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

  /// Saves all cached data atomically into device local storage with sync metadata
  Future<void> _saveAllToLocalStorage() async {
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
        prefs.setString(_kSyncMetadataKey, _lastLocalUpdatedAt),
      ]);
      _hasLocalCache = true;
    } catch (e) {
      debugPrint('Failed to save data to local storage: $e');
    }
  }

  Future<void> _saveEssentialToLocalStorage() => _saveAllToLocalStorage();
  Future<void> _saveBackgroundToLocalStorage() => _saveAllToLocalStorage();

  /// Priority 1: Initialize essential first-viewport data concurrently (~150-250ms)
  Future<void> initializeEssentialFirstViewport({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // Only skip fetching if local cache exists AND all essential home data is present
    if (_hasLocalCache && hasEssentialHomeData && !forceRefresh) {
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
        _fetchSettings(db, forceServer: forceRefresh),
        _fetchSiteContent(db, forceServer: forceRefresh),
        _fetchHomeBanners(db, forceServer: forceRefresh),
        _fetchHomeAboutCards(db, forceServer: forceRefresh),
        _fetchPillars(db, forceServer: forceRefresh),
        _fetchHomeSingers(db, forceServer: forceRefresh),
        _fetchBlessings(db, forceServer: forceRefresh),
        _fetchFooter(db, forceServer: forceRefresh),
        _fetchLiveStream(db, forceServer: forceRefresh),
        _fetchGarbiYears(db, forceServer: forceRefresh),
        _fetchHomeVideosPreview(db, forceServer: forceRefresh),
        _fetchHomeBlogsPreview(db, forceServer: forceRefresh),
        _fetchAlbums(db, forceServer: forceRefresh),
      ]);
      _isFirestoreConnected = true;
      await _saveAllToLocalStorage();
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

    try {
      if (_committeeMembers.isEmpty || forceRefresh) {
        await ensureAboutPageLoaded(forceRefresh: forceRefresh);
      }
      if (_historyMilestones.isEmpty || forceRefresh) {
        await ensureHistoryLoaded(forceRefresh: forceRefresh);
      }
      _listenToRealtimeUpdates(db);
      await _saveAllToLocalStorage();
    } catch (e) {
      debugPrint('Background loading notice: $e');
    }
  }

  /// Standard entry point: fast first viewport + gentle background loading
  Future<void> initializeFromFirestore() async {
    await initializeEssentialFirstViewport(forceRefresh: true);
    unawaited(startGentleBackgroundLoading(forceRefresh: true));
  }

  // --- On-Demand Screen-Level Loaders ---

  bool _isGalleryLoaded = false;

  Future<void> ensureGalleryLoaded([String? year, String? album, bool forceRefresh = false]) async {
    final db = _firestore;
    if (db == null || (_isGalleryLoaded && !forceRefresh)) return;
    try {
      final snap = await _getCollectionWithFallback(db.collection('photos'), forceServer: forceRefresh);
      if (snap.docs.isNotEmpty) {
        _photos.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _photos.add(AdminPhoto.fromMap(data));
        }
        _isGalleryLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gallery on-demand load notice: $e');
    }
  }

  bool _isAboutDetailsLoaded = false;

  Future<void> ensureAboutPageLoaded({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null || (_isAboutDetailsLoaded && !forceRefresh)) return;
    try {
      final results = await Future.wait([
        _getCollectionWithFallback(db.collection('committee_members'), forceServer: forceRefresh),
        _getCollectionWithFallback(db.collection('about_principles'), forceServer: forceRefresh),
      ]);
      final cmSnap = results[0];
      if (cmSnap.docs.isNotEmpty) {
        _committeeMembers.clear();
        for (final doc in cmSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _committeeMembers.add(AdminCommitteeMember.fromMap(data));
        }
        _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
      }

      final prSnap = results[1];
      if (prSnap.docs.isNotEmpty) {
        _aboutPrinciples.clear();
        for (final doc in prSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _aboutPrinciples.add(AdminAboutPrinciple.fromMap(data));
        }
        _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
      }
      _isAboutDetailsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('About page on-demand load notice: $e');
    }
  }

  bool _isHistoryLoaded = false;

  Future<void> ensureHistoryLoaded({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null || (_isHistoryLoaded && !forceRefresh)) return;
    try {
      final hmSnap = await _getCollectionWithFallback(db.collection('history_milestones'), forceServer: forceRefresh);
      if (hmSnap.docs.isNotEmpty) {
        _historyMilestones.clear();
        for (final doc in hmSnap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _historyMilestones.add(AdminHistoryMilestone.fromMap(data));
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

  Future<void> ensureVideosLoaded({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null || (_isFullVideosLoaded && !forceRefresh)) return;
    try {
      final snap = await _getCollectionWithFallback(db.collection('videos'), forceServer: forceRefresh);
      if (snap.docs.isNotEmpty) {
        _videos.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _videos.add(AdminVideo.fromMap(data));
        }
        _isFullVideosLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Videos on-demand load notice: $e');
    }
  }

  bool _isFullBlogsLoaded = false;

  Future<void> ensureBlogsLoaded({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null || (_isFullBlogsLoaded && !forceRefresh)) return;
    try {
      final snap = await _getCollectionWithFallback(db.collection('blogs'), forceServer: forceRefresh);
      if (snap.docs.isNotEmpty) {
        _blogs.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _blogs.add(AdminBlog.fromMap(data));
        }
        _isFullBlogsLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Blogs on-demand load notice: $e');
    }
  }

  bool _isAdminDataLoaded = false;

  Future<void> ensureAdminDataLoaded({bool forceRefresh = false}) async {
    final db = _firestore;
    if (db == null || (_isAdminDataLoaded && !forceRefresh)) return;
    try {
      final results = await Future.wait([
        _getCollectionWithFallback(db.collection('enquiries'), forceServer: forceRefresh),
        _getCollectionWithFallback(db.collection('activity_logs'), forceServer: forceRefresh),
        ensureGalleryLoaded(null, null, forceRefresh),
        ensureVideosLoaded(forceRefresh: forceRefresh),
        ensureBlogsLoaded(forceRefresh: forceRefresh),
        ensureAboutPageLoaded(forceRefresh: forceRefresh),
        ensureHistoryLoaded(forceRefresh: forceRefresh),
      ]);
      final enqSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      _enquiries.clear();
      for (final doc in enqSnap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _enquiries.add(AdminEnquiry.fromMap(data));
      }
      final logsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
      _activityLogs.clear();
      for (final doc in logsSnap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _activityLogs.add(AdminActivityLog.fromMap(data));
      }
      _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Fetch Inbound Notification Emails
      try {
        final notifSnap = await _getCollectionWithFallback(db.collection('notification_emails'), forceServer: forceRefresh);
        if (notifSnap.docs.isNotEmpty) {
          _notificationEmails.clear();
          for (final doc in notifSnap.docs) {
            final data = doc.data();
            if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
            _notificationEmails.add(AdminNotificationEmail.fromMap(data));
          }
        }
      } catch (e) {
        debugPrint('Notification emails fetch notice: $e');
      }
      _isAdminDataLoaded = true;
      _listenToAdminRealtimeUpdates(db);
      notifyListeners();
    } catch (e) {
      debugPrint('Admin data on-demand load notice: $e');
    }
  }

  bool _adminListenersAttached = false;

  void _listenToAdminRealtimeUpdates(FirebaseFirestore db) {
    if (_adminListenersAttached) return;
    _adminListenersAttached = true;

    db.collection('enquiries').snapshots().listen((snap) {
      _enquiries.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _enquiries.add(AdminEnquiry.fromMap(data));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Enquiries stream notice: $e'));

    db.collection('activity_logs').snapshots().listen((snap) {
      _activityLogs.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _activityLogs.add(AdminActivityLog.fromMap(data));
      }
      _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    }, onError: (e) => debugPrint('Logs stream notice: $e'));

    db.collection('notification_emails').snapshots().listen((snap) {
      if (snap.docs.isNotEmpty) {
        _notificationEmails.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _notificationEmails.add(AdminNotificationEmail.fromMap(data));
        }
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Notification emails stream notice: $e'));
  }

  bool _listenersAttached = false;

  void _listenToRealtimeUpdates(FirebaseFirestore db) {
    if (_listenersAttached) return;
    _listenersAttached = true;

    db.collection('settings').doc('mandal_settings').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null && doc.data()!['is_deleted'] != true && doc.data()!['isDeleted'] != true) {
        _settings = AdminSettings.fromMap(doc.data()!);
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Settings stream notice: $e'));

    db.collection('committee_members').snapshots().listen((snap) {
      _committeeMembers.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _committeeMembers.add(AdminCommitteeMember.fromMap(data));
      }
      _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Committee stream notice: $e'));

    db.collection('about_principles').snapshots().listen((snap) {
      _aboutPrinciples.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _aboutPrinciples.add(AdminAboutPrinciple.fromMap(data));
      }
      _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('About principles stream notice: $e'));

    db.collection('history_milestones').snapshots().listen((snap) {
      _historyMilestones.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _historyMilestones.add(AdminHistoryMilestone.fromMap(data));
      }
      _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('History stream notice: $e'));

    db.collection('home_singers').snapshots().listen((snap) {
      _homeSingers.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _homeSingers.add(AdminHomeSinger.fromMap(data));
      }
      _homeSingers.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Singers stream notice: $e'));

    db.collection('home_banners').snapshots().listen((snap) {
      _homeBanners.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _homeBanners.add(AdminHomeBanner.fromMap(data));
      }
      _homeBanners.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Banners stream notice: $e'));

    db.collection('site_content').snapshots().listen((snap) {
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) {
          _siteContentMap.remove(doc.id);
          continue;
        }
        final f = AdminContentField.fromMap(data);
        _siteContentMap[f.key] = f;
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Site content stream notice: $e'));

    db.collection('home_about_cards').snapshots().listen((snap) {
      _aboutCards.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _aboutCards.add(AdminAboutCard.fromMap(data));
      }
      _aboutCards.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('About cards stream notice: $e'));

    db.collection('home_pillars').snapshots().listen((snap) {
      _pillars.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _pillars.add(AdminHomePillar.fromMap(data));
      }
      _pillars.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Pillars stream notice: $e'));

    db.collection('home_blessings').snapshots().listen((snap) {
      _blessings.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _blessings.add(AdminHomeBlessing.fromMap(data));
      }
      _blessings.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Blessings stream notice: $e'));

    db.collection('garbi_years').snapshots().listen((snap) {
      _years.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _years.add(AdminGarbiYear.fromMap(data));
      }
      _years.sort((a, b) => b.year.compareTo(a.year));
      notifyListeners();
    }, onError: (e) => debugPrint('Years stream notice: $e'));

    db.collection('albums').snapshots().listen((snap) {
      _albums.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _albums.add(AdminAlbum.fromMap(data));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Albums stream notice: $e'));

    db.collection('photos').snapshots().listen((snap) {
      _photos.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _photos.add(AdminPhoto.fromMap(data));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Photos stream notice: $e'));

    db.collection('videos').snapshots().listen((snap) {
      _videos.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _videos.add(AdminVideo.fromMap(data));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Videos stream notice: $e'));

    db.collection('live_stream').doc('current').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null && doc.data()!['is_deleted'] != true && doc.data()!['isDeleted'] != true) {
        _liveStreamSettings = AdminLiveStreamSettings.fromMap(doc.data()!);
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Live stream notice: $e'));

    db.collection('blogs').snapshots().listen((snap) {
      _blogs.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _blogs.add(AdminBlog.fromMap(data));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Blogs stream notice: $e'));

    db.collection('enquiries').snapshots().listen((snap) {
      _enquiries.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _enquiries.add(AdminEnquiry.fromMap(data));
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Enquiries stream notice: $e'));

    db.collection('activity_logs').snapshots().listen((snap) {
      _activityLogs.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _activityLogs.add(AdminActivityLog.fromMap(data));
      }
      _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    }, onError: (e) => debugPrint('Logs stream notice: $e'));

    db.collection('notification_emails').snapshots().listen((snap) {
      if (snap.docs.isNotEmpty) {
        _notificationEmails.clear();
        for (final doc in snap.docs) {
          final data = doc.data();
          if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
          _notificationEmails.add(AdminNotificationEmail.fromMap(data));
        }
        notifyListeners();
      }
    }, onError: (e) => debugPrint('Notification emails stream notice: $e'));

    db.collection('footer_links').snapshots().listen((snap) {
      _footerLinks.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _footerLinks.add(AdminFooterLink.fromMap(data));
      }
      _footerLinks.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Footer links stream notice: $e'));

    db.collection('footer_social_links').snapshots().listen((snap) {
      _footerSocialLinks.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['is_deleted'] == true || data['isDeleted'] == true) continue;
        _footerSocialLinks.add(AdminFooterSocialLink.fromMap(data));
      }
      _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: (e) => debugPrint('Footer social links stream notice: $e'));
  }

  Future<void> _touchSyncMetadata(FirebaseFirestore db, [String? collectionName]) async {
    try {
      final now = DateTime.now().toIso8601String();
      _lastLocalUpdatedAt = now;
      final updateData = <String, dynamic>{'lastUpdatedAt': now, 'updatedAt': now, 'isDeleted': false};
      if (collectionName != null && collectionName.isNotEmpty) {
        updateData['collections.$collectionName.version'] = FieldValue.increment(1);
        updateData['collections.$collectionName.updatedAt'] = now;
      }
      await db.collection('settings').doc('sync_metadata').set(updateData, SetOptions(merge: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSyncMetadataKey, now);
    } catch (_) {}
  }

  Future<void> _writeToFirestore(String collection, String docId, Map<String, dynamic> data) async {
    final db = _firestore;
    if (db == null) return;
    try {
      final payload = Map<String, dynamic>.from(data);
      payload['isDeleted'] = false;
      payload['updatedAt'] = DateTime.now().toIso8601String();
      payload.remove('is_deleted');
      payload.remove('updated_at');
      payload.remove('created_at');
      payload.remove('deleted_at');
      await db.collection(collection).doc(docId).set(payload, SetOptions(merge: true));
      _isFirestoreConnected = true;
      if (collection != 'activity_logs' && docId != 'sync_metadata') {
        unawaited(_touchSyncMetadata(db, collection));
      }
    } catch (e) {
      debugPrint('Firestore write notice ($collection/$docId): $e');
    }
  }

  Future<void> _deleteFromFirestore(String collection, String docId) async {
    final db = _firestore;
    if (db == null) return;
    try {
      final now = DateTime.now().toIso8601String();
      await db.collection(collection).doc(docId).set({'isDeleted': true, 'deletedAt': now, 'updatedAt': now}, SetOptions(merge: true));
      unawaited(_touchSyncMetadata(db, collection));
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
    final db = _firestore;
    if (db == null) return;
    await initializeEssentialFirstViewport(forceRefresh: true);
    await startGentleBackgroundLoading(forceRefresh: true);
    await ensureAdminDataLoaded(forceRefresh: true);
    logActivity('CONFIG', 'Database Refreshed', 'Refreshed all website content directly from Firestore');
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
      orElse: () => AdminCommitteeMember(id: '', nameEn: '', nameGu: '', designationEn: '', designationGu: ''),
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
  void addAlbum(AdminAlbum album) async {
    var finalAlbum = album;
    if (finalAlbum.nameGu.trim().isEmpty && finalAlbum.name.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalAlbum.name);
        finalAlbum = finalAlbum.copyWith(nameGu: trans);
      } catch (_) {}
    }
    if (finalAlbum.descriptionGu.trim().isEmpty && finalAlbum.description.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalAlbum.description);
        finalAlbum = finalAlbum.copyWith(descriptionGu: trans);
      } catch (_) {}
    }
    if (finalAlbum.dayTagGu.trim().isEmpty && finalAlbum.dayTag.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalAlbum.dayTag);
        finalAlbum = finalAlbum.copyWith(dayTagGu: trans);
      } catch (_) {}
    }
    _albums.insert(0, finalAlbum);
    logActivity('CREATE', 'Albums', 'Created album "${finalAlbum.name}" (${finalAlbum.year})');
    _writeToFirestore('albums', finalAlbum.id, finalAlbum.toMap());
    notifyListeners();
  }

  void updateAlbum(AdminAlbum updatedAlbum) async {
    var finalAlbum = updatedAlbum;
    if (finalAlbum.nameGu.trim().isEmpty && finalAlbum.name.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalAlbum.name);
        finalAlbum = finalAlbum.copyWith(nameGu: trans);
      } catch (_) {}
    }
    if (finalAlbum.descriptionGu.trim().isEmpty && finalAlbum.description.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalAlbum.description);
        finalAlbum = finalAlbum.copyWith(descriptionGu: trans);
      } catch (_) {}
    }
    if (finalAlbum.dayTagGu.trim().isEmpty && finalAlbum.dayTag.trim().isNotEmpty) {
      try {
        final trans = await GoogleTranslationService.instance.translateToGujarati(finalAlbum.dayTag);
        finalAlbum = finalAlbum.copyWith(dayTagGu: trans);
      } catch (_) {}
    }
    final index = _albums.indexWhere((a) => a.id == finalAlbum.id);
    if (index != -1) {
      _albums[index] = finalAlbum;
      logActivity('UPDATE', 'Albums', 'Updated album "${finalAlbum.name}"');
      _writeToFirestore('albums', finalAlbum.id, finalAlbum.toMap());
      notifyListeners();
    }
  }

  void deleteAlbum(String id) {
    final item = _albums.firstWhere(
      (a) => a.id == id,
      orElse: () => AdminAlbum(id: '', year: '', name: '', dayTag: '', description: ''),
    );
    _albums.removeWhere((a) => a.id == id);
    final linkedPhotos = _photos.where((p) => p.albumId == id).toList();
    for (final p in linkedPhotos) {
      _deleteFromFirestore('photos', p.id);
    }
    _photos.removeWhere((p) => p.albumId == id);
    logActivity('DELETE', 'Albums', 'Deleted album "${item.name}" and ${linkedPhotos.length} associated photos');
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

  // --- CRUD: Notification Emails ---
  void addNotificationEmail(AdminNotificationEmail email) {
    if (email.isPrimary) {
      for (int i = 0; i < _notificationEmails.length; i++) {
        if (_notificationEmails[i].isPrimary) {
          _notificationEmails[i] = _notificationEmails[i].copyWith(isPrimary: false);
          _writeToFirestore('notification_emails', _notificationEmails[i].id, _notificationEmails[i].toMap());
        }
      }
    }
    _notificationEmails.add(email);
    logActivity('CREATE', 'Notification Emails', 'Added notification recipient "${email.email}"');
    _writeToFirestore('notification_emails', email.id, email.toMap());
    notifyListeners();
  }

  void updateNotificationEmail(AdminNotificationEmail email) {
    final index = _notificationEmails.indexWhere((e) => e.id == email.id);
    if (index != -1) {
      if (email.isPrimary) {
        for (int i = 0; i < _notificationEmails.length; i++) {
          if (i != index && _notificationEmails[i].isPrimary) {
            _notificationEmails[i] = _notificationEmails[i].copyWith(isPrimary: false);
            _writeToFirestore('notification_emails', _notificationEmails[i].id, _notificationEmails[i].toMap());
          }
        }
      }
      _notificationEmails[index] = email;
      logActivity('UPDATE', 'Notification Emails', 'Updated notification recipient "${email.email}"');
      _writeToFirestore('notification_emails', email.id, email.toMap());
      notifyListeners();
    }
  }

  void deleteNotificationEmail(String id) {
    final item = _notificationEmails.firstWhere(
      (e) => e.id == id,
      orElse: () => AdminNotificationEmail(id: '', email: '', recipientName: ''),
    );
    _notificationEmails.removeWhere((e) => e.id == id);
    if (item.isPrimary && _notificationEmails.isNotEmpty) {
      _notificationEmails[0] = _notificationEmails[0].copyWith(isPrimary: true);
      _writeToFirestore('notification_emails', _notificationEmails[0].id, _notificationEmails[0].toMap());
    }
    logActivity('DELETE', 'Notification Emails', 'Deleted notification recipient "${item.email}"');
    _deleteFromFirestore('notification_emails', id);
    notifyListeners();
  }

  void toggleNotificationEmailEnabled(String id) {
    final index = _notificationEmails.indexWhere((e) => e.id == id);
    if (index != -1) {
      final current = _notificationEmails[index];
      _notificationEmails[index] = current.copyWith(isEnabled: !current.isEnabled);
      _writeToFirestore('notification_emails', id, _notificationEmails[index].toMap());
      notifyListeners();
    }
  }

  void setPrimaryNotificationEmail(String id) {
    for (int i = 0; i < _notificationEmails.length; i++) {
      final isTarget = _notificationEmails[i].id == id;
      _notificationEmails[i] = _notificationEmails[i].copyWith(isPrimary: isTarget);
      _writeToFirestore('notification_emails', _notificationEmails[i].id, _notificationEmails[i].toMap());
    }
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
      orElse: () => AdminFooterLink(id: '', titleEn: '', titleGu: '', url: ''),
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
      orElse: () => AdminFooterSocialLink(id: '', platform: '', url: ''),
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
    final keys = ['footer_tagline', 'footer_motto', 'footer_links_title', 'footer_links2_title', 'footer_social', 'footer_location', 'footer_copyright'];
    for (final k in keys) {
      updateSiteContentField(k, valueEn: '', valueGu: '');
    }
    logActivity('DELETE', 'Footer', 'Cleared all website footer content fields');
    notifyListeners();
  }

  // --- REORDER METHODS FOR ALL ORDERED COLLECTIONS ---

  Future<void> reorderCommitteeMembers(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _committeeMembers.length || newIndex < 0 || newIndex >= _committeeMembers.length) return;
    final item = _committeeMembers.removeAt(oldIndex);
    _committeeMembers.insert(newIndex, item);
    for (int i = 0; i < _committeeMembers.length; i++) {
      final updated = _committeeMembers[i].copyWith(order: i + 1);
      _committeeMembers[i] = updated;
      await _writeToFirestore('committee_members', updated.id, updated.toMap());
    }
    _committeeMembers.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderAboutPrinciples(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _aboutPrinciples.length || newIndex < 0 || newIndex >= _aboutPrinciples.length) return;
    final item = _aboutPrinciples.removeAt(oldIndex);
    _aboutPrinciples.insert(newIndex, item);
    for (int i = 0; i < _aboutPrinciples.length; i++) {
      final updated = _aboutPrinciples[i].copyWith(order: i + 1);
      _aboutPrinciples[i] = updated;
      await _writeToFirestore('about_principles', updated.id, updated.toMap());
    }
    _aboutPrinciples.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderHistoryMilestones(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _historyMilestones.length || newIndex < 0 || newIndex >= _historyMilestones.length) return;
    final item = _historyMilestones.removeAt(oldIndex);
    _historyMilestones.insert(newIndex, item);
    for (int i = 0; i < _historyMilestones.length; i++) {
      final updated = _historyMilestones[i].copyWith(order: i + 1);
      _historyMilestones[i] = updated;
      await _writeToFirestore('history_milestones', updated.id, updated.toMap());
    }
    _historyMilestones.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderHomeSingers(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _homeSingers.length || newIndex < 0 || newIndex >= _homeSingers.length) return;
    final item = _homeSingers.removeAt(oldIndex);
    _homeSingers.insert(newIndex, item);
    for (int i = 0; i < _homeSingers.length; i++) {
      final updated = _homeSingers[i].copyWith(order: i + 1);
      _homeSingers[i] = updated;
      await _writeToFirestore('home_singers', updated.id, updated.toMap());
    }
    _homeSingers.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderHomeBanners(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _homeBanners.length || newIndex < 0 || newIndex >= _homeBanners.length) return;
    final item = _homeBanners.removeAt(oldIndex);
    _homeBanners.insert(newIndex, item);
    for (int i = 0; i < _homeBanners.length; i++) {
      final updated = _homeBanners[i].copyWith(order: i + 1);
      _homeBanners[i] = updated;
      await _writeToFirestore('home_banners', updated.id, updated.toMap());
    }
    _homeBanners.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderHomePillars(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _pillars.length || newIndex < 0 || newIndex >= _pillars.length) return;
    final item = _pillars.removeAt(oldIndex);
    _pillars.insert(newIndex, item);
    for (int i = 0; i < _pillars.length; i++) {
      final updated = _pillars[i].copyWith(order: i + 1);
      _pillars[i] = updated;
      await _writeToFirestore('home_pillars', updated.id, updated.toMap());
    }
    _pillars.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderHomeBlessings(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _blessings.length || newIndex < 0 || newIndex >= _blessings.length) return;
    final item = _blessings.removeAt(oldIndex);
    _blessings.insert(newIndex, item);
    for (int i = 0; i < _blessings.length; i++) {
      final updated = _blessings[i].copyWith(order: i + 1);
      _blessings[i] = updated;
      await _writeToFirestore('home_blessings', updated.id, updated.toMap());
    }
    _blessings.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderFooterSocialLinks(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _footerSocialLinks.length || newIndex < 0 || newIndex >= _footerSocialLinks.length) return;
    final item = _footerSocialLinks.removeAt(oldIndex);
    _footerSocialLinks.insert(newIndex, item);
    for (int i = 0; i < _footerSocialLinks.length; i++) {
      final updated = _footerSocialLinks[i].copyWith(order: i + 1);
      _footerSocialLinks[i] = updated;
      await _writeToFirestore('footer_social_links', updated.id, updated.toMap());
    }
    _footerSocialLinks.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> reorderYears(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _years.length) return;
    if (newIndex < 0 || newIndex > _years.length) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _years.removeAt(oldIndex);
    _years.insert(newIndex, item);
    logActivity('REORDER', 'Years', 'Reordered festival years');
    notifyListeners();
  }

  // --- Granular Page-Specific Reloaders ---

  Future<void> reloadHomePage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([
        _fetchSettings(db, forceServer: true),
        _fetchSiteContent(db, forceServer: true),
        _fetchHomeBanners(db, forceServer: true),
        _fetchHomeAboutCards(db, forceServer: true),
        _fetchPillars(db, forceServer: true),
        _fetchHomeSingers(db, forceServer: true),
        _fetchBlessings(db, forceServer: true),
        _fetchLiveStream(db, forceServer: true),
        _fetchHomeVideosPreview(db, forceServer: true),
        _fetchHomeBlogsPreview(db, forceServer: true),
        _fetchGarbiYears(db, forceServer: true),
        _fetchAlbums(db, forceServer: true),
      ]);
      unawaited(_saveEssentialToLocalStorage());
      unawaited(_saveBackgroundToLocalStorage());
      notifyListeners();
    } catch (e) {
      debugPrint('Home page reload error: $e');
    }
  }

  Future<void> reloadAboutPage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([_fetchSiteContent(db, forceServer: true), _fetchHomeAboutCards(db, forceServer: true), ensureAboutPageLoaded(forceRefresh: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('About page reload error: $e');
    }
  }

  Future<void> reloadHistoryPage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([_fetchSiteContent(db, forceServer: true), ensureHistoryLoaded(forceRefresh: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('History page reload error: $e');
    }
  }

  Future<void> reloadGalleryPage([String? year, String? album]) async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([ensureGalleryLoaded(year, album, true), _fetchGarbiYears(db, forceServer: true), _fetchAlbums(db, forceServer: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('Gallery page reload error: $e');
    }
  }

  Future<void> reloadVideosPage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([ensureVideosLoaded(forceRefresh: true), _fetchLiveStream(db, forceServer: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('Videos page reload error: $e');
    }
  }

  Future<void> reloadBlogsPage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([ensureBlogsLoaded(forceRefresh: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('Blogs page reload error: $e');
    }
  }

  Future<void> reloadArchivePage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([_fetchGarbiYears(db, forceServer: true), _fetchAlbums(db, forceServer: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('Archive page reload error: $e');
    }
  }

  Future<void> reloadContactPage() async {
    final db = _firestore;
    if (db == null) return;
    try {
      await Future.wait([_fetchSiteContent(db, forceServer: true), _fetchSettings(db, forceServer: true)]);
      notifyListeners();
    } catch (e) {
      debugPrint('Contact page reload error: $e');
    }
  }

  Future<void> refreshAllData({bool forceRefresh = true}) async {
    setBusy(true, 'Refreshing data from cloud...');
    try {
      await initializeEssentialFirstViewport(forceRefresh: forceRefresh);
      await startGentleBackgroundLoading(forceRefresh: forceRefresh);
      logActivity('CONFIG', 'System', 'Refreshed all portal data from Firestore');
    } catch (e) {
      debugPrint('Refresh error: $e');
    } finally {
      setBusy(false);
    }
  }
}
