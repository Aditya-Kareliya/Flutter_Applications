import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class AddCategory {
  final ExpenseRepository repository;

  AddCategory(this.repository);

  Future<void> call(Category category) async {
    return await repository.addCategory(category);
  }
}
