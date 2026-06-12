import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class GetCategories {
  final ExpenseRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}
