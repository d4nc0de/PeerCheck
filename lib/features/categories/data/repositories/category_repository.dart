// lib/features/categories/data/repositories/category_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryRepository {
  static const String _categoriesKey = "categories_data";

  final List<Map<String, dynamic>> _defaultCategories = [
    {
      "name": "General",
      "method": "Random",
      "groupSize": 0,
      "groups": [],
    },
  ];

  List<Map<String, dynamic>> _categories = [];

  CategoryRepository() {
    _loadFromPrefs();
  }

  /// Cargar categorías desde SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_categoriesKey) ?? [];

    _categories = stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    // Si es primera vez, guardamos categorías por defecto
    if (_categories.isEmpty) {
      _categories = [..._defaultCategories];
      await _saveCategories();
    }
  }

  /// Guardar categorías en SharedPreferences
  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _categories.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList(_categoriesKey, data);
  }

  /// Obtener todas las categorías
  Future<List<Map<String, dynamic>>> getCategories() async {
    return _categories;
  }

  /// Agregar una nueva categoría
  Future<void> addCategory(Map<String, dynamic> category) async {
    _categories.add(category);
    await _saveCategories();
  }

  /// Editar una categoría existente
  Future<void> editCategory(int index, Map<String, dynamic> updatedCategory) async {
    if (index < 0 || index >= _categories.length) return;
    _categories[index] = updatedCategory;
    await _saveCategories();
  }

  /// Eliminar una categoría
  Future<void> deleteCategory(int index) async {
    if (index < 0 || index >= _categories.length) return;
    _categories.removeAt(index);
    await _saveCategories();
  }

  /// Agregar un grupo dentro de una categoría
  Future<void> addGroup(int categoryIndex, Map<String, dynamic> group) async {
    if (categoryIndex < 0 || categoryIndex >= _categories.length) return;
    _categories[categoryIndex]["groups"].add(group);
    await _saveCategories();
  }

  /// Mover estudiante entre grupos
  Future<void> moveStudent(
    int categoryIndex,
    int fromGroup,
    int toGroup,
    dynamic student,
  ) async {
    final category = _categories[categoryIndex];
    final from = category["groups"][fromGroup]["students"] as List<dynamic>;
    final to = category["groups"][toGroup]["students"] as List<dynamic>;

    from.remove(student);
    to.add(student);

    await _saveCategories();
  }
}
