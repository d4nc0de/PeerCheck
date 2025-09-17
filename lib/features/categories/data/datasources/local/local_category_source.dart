import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_category_source.dart';

class LocalCategorySource implements ICategorySource {
  static const String _categoriesKey = "categories_data";

  final List<Map<String, dynamic>> _defaultCategories = [
    {
      "name": "General",
      "method": "Random",
      "groupSize": 3,
      "groups": [],
    },
    {
      "name": "Self-assigned Example",
      "method": "Self-assigned",
      "groupSize": 2,
      "groups": [],
    },
  ];

  List<Map<String, dynamic>> _categories = [];

  LocalCategorySource() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_categoriesKey) ?? [];

    _categories = stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    // Guardar valores por defecto si no hay categorías
    if (_categories.isEmpty) {
      _categories = [..._defaultCategories];
      await _saveCategories();
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _categories.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList(_categoriesKey, data);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return _categories;
  }

  @override
  Future<void> addCategory(Map<String, dynamic> category) async {
    _categories.add(category);
    await _saveCategories();
  }

  @override
  Future<void> updateCategory(Map<String, dynamic> updatedCategory, int index) async {
    if (index >= 0 && index < _categories.length) {
      _categories[index] = updatedCategory;
      await _saveCategories();
    }
  }

  @override
  Future<void> deleteCategory(int index) async {
    if (index >= 0 && index < _categories.length) {
      _categories.removeAt(index);
      await _saveCategories();
    }
  }

  @override
  Future<void> deleteAllCategories() async {
    _categories.clear();
    await _saveCategories();
  }
}
