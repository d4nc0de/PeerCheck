import 'package:f_clean_template/features/categories/domain/models/category.dart';


abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<void> removeCategory(String categoryId);
  Future<void> updateCategory(Category category);
}
