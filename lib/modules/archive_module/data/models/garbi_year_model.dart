class GarbiYearModel {
  const GarbiYearModel({
    required this.id,
    required this.year,
    required this.titleEn,
    this.titleGu,
    this.descriptionEn,
    this.descriptionGu,
    this.coverImage,
    this.isPublished = true,
    this.displayOrder = 0,
  });

  final String id;
  final int year;
  final String titleEn;
  final String? titleGu;
  final String? descriptionEn;
  final String? descriptionGu;
  final String? coverImage;
  final bool isPublished;
  final int displayOrder;

  factory GarbiYearModel.fromMap(String id, Map<String, dynamic> map) {
    return GarbiYearModel(
      id: id,
      year: (map['year'] as num?)?.toInt() ?? 0,
      titleEn: map['titleEn'] as String? ?? '',
      titleGu: map['titleGu'] as String?,
      descriptionEn: map['descriptionEn'] as String?,
      descriptionGu: map['descriptionGu'] as String?,
      coverImage: map['coverImage'] as String?,
      isPublished: map['isPublished'] as bool? ?? false,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
