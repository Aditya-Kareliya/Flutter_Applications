import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/garbi_year_model.dart';
import '../data/repositories/garbi_year_repository.dart';

sealed class ArchiveState {
  const ArchiveState();
}

final class ArchiveInitial extends ArchiveState {
  const ArchiveInitial();
}

final class ArchiveLoading extends ArchiveState {
  const ArchiveLoading();
}

final class ArchiveLoaded extends ArchiveState {
  const ArchiveLoaded(this.years);

  final List<GarbiYearModel> years;
}

final class ArchiveFailure extends ArchiveState {
  const ArchiveFailure(this.message);

  final String message;
}

class ArchiveCubit extends Cubit<ArchiveState> {
  ArchiveCubit(this._repository) : super(const ArchiveInitial());

  final GarbiYearRepository _repository;

  Future<void> load() async {
    emit(const ArchiveLoading());
    try {
      final years = await _repository.getPublishedYears();
      emit(ArchiveLoaded(years));
    } catch (error) {
      emit(const ArchiveFailure('Unable to load the archive right now.'));
    }
  }
}
