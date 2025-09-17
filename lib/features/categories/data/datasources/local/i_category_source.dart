abstract class ICategorySource {
  Future<List<Map<String, dynamic>>> getCategories();
  Future<void> addCategory(Map<String, dynamic> category);
  Future<void> updateCategory(Map<String, dynamic> updatedCategory, int index);
  Future<void> deleteCategory(int index);
  Future<void> deleteAllCategories();
}