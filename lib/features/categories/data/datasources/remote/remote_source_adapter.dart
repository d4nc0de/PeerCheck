// lib/features/categories/data/datasources/remote/remote_source_adapter.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';

class RemoteCategorySourceAdapter implements ICategorySource {
  final http.Client client;
  final String baseUrl; // termina en /database
  final String dbName;
  final RemoteAuthenticationSourceService auth;

  RemoteCategorySourceAdapter({
    required this.client,
    required this.baseUrl,
    required this.dbName,
    required this.auth,
  });

  Uri get _readUri   => Uri.parse('$baseUrl/$dbName/read');
  Uri get _insertUri => Uri.parse('$baseUrl/$dbName/insert');
  Uri get _updateUri => Uri.parse('$baseUrl/$dbName/update');
  Uri get _deleteUri => Uri.parse('$baseUrl/$dbName/delete');

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await auth.getAccessToken()}',
      };

  // ==== READ ====
  @override
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    final uri = _readUri.replace(queryParameters: {
      'tableName': 'Categories',
      'Curso_id': courseId,
    });

    final res = await client.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception('Error leyendo categorías: ${res.body}');
    }

    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return list.map((row) {
      final isRandom = (row['IsRamdom'] == true);
      return Category(
        id: row['_id'] as String,
        courseId: row['Curso_id'] as String,
        name: (row['Name'] ?? '').toString(),
        // 👇 mapeo claro para que no aparezca "Desconocido"
        method: isRandom ? 'random' : 'manual',
        groupSize: (row['Description'] is num)
            ? (row['Description'] as num).toInt()
            : int.tryParse('${row['Description'] ?? 0}') ?? 0,
      );
    }).toList();
  }

  // ==== CREATE ====
  @override
  Future<void> addCategory(Category category) async {
    final body = jsonEncode({
      'tableName': 'Categories',
      'records': [
        {
          // _id se autogenera: NO LO ENVÍES
          'Name': category.name,                   // varchar
          'Description': category.groupSize,       // int8 (usado como tamaño grupo)
          'IsRamdom': category.method == 'random', // bool en BD
          'Curso_id': category.courseId,           // varchar
        }
      ]
    });

    final res = await client.post(_insertUri, headers: await _headers(), body: body);
    if (res.statusCode != 200) {
      throw Exception('Error insertando categoría: ${res.body}');
    }
  }

  // ==== UPDATE ====
  @override
  Future<void> updateCategory(Category c) async {
    final body = jsonEncode({
      'tableName': 'Categories',
      'idColumn': '_id',
      'idValue': c.id,
      'updates': {
        'Name': c.name,
        'Description': c.groupSize,
        'IsRamdom': c.method == 'random',
      }
    });

    final res = await client.put(_updateUri, headers: await _headers(), body: body);
    if (res.statusCode != 200) {
      throw Exception('Error actualizando categoría: ${res.body}');
    }
  }

  // ==== DELETE ====
  @override
  Future<void> removeCategory(String categoryId) async {
    final body = jsonEncode({
      'tableName': 'Categories',
      'idColumn': '_id',
      'idValue': categoryId,
    });

    final res = await client.delete(_deleteUri, headers: await _headers(), body: body);
    if (res.statusCode != 200) {
      throw Exception('Error eliminando categoría: ${res.body}');
    }
  }
}
