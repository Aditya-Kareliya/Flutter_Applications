import '../../../admin_module/dashboard/data/admin_data_store.dart';
import '../models/garbi_year_model.dart';

abstract interface class GarbiYearRepository {
  Future<List<GarbiYearModel>> getPublishedYears();
}

final class FirestoreGarbiYearRepository implements GarbiYearRepository {
  const FirestoreGarbiYearRepository();

  @override
  Future<List<GarbiYearModel>> getPublishedYears() async {
    final list = AdminDataStore.instance.years.where((y) => y.isPublished).toList();
    return list.asMap().entries.map((entry) {
      final y = entry.value;
      return GarbiYearModel(
        id: y.id,
        year: y.year,
        titleEn: y.titleEn,
        titleGu: y.titleGu,
        descriptionEn: y.description,
        descriptionGu: y.description,
        isPublished: y.isPublished,
        displayOrder: entry.key,
      );
    }).toList();
  }
}
