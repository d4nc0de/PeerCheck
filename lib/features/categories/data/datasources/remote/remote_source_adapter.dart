import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';

/// Usa la API remota pero respeta la interfaz ICategorySource
class RemoteCategorySourceAdapter implements ICategorySource {
  final http.Client _client;
  final String _baseUrl; // .../database
  final String _dbName;
  final RemoteAuthenticationSourceService _auth;

  RemoteCategorySourceAdapter({
    required http.Client client,
    required String baseUrl,
    required String dbName,
    required RemoteAuthenticationSourceService auth,
  })  : _client = client,
        _baseUrl = baseUrl,
        _dbName = dbName,
        _auth = auth;

  Uri _insertUri() => Uri.parse('$_baseUrl/$_dbName/insert');
  Uri _updateUri() => Uri.parse('$_baseUrl/$_dbName/update');
  Uri _readUri(Map<String, String> q) =>
      Uri.parse('$_baseUrl/$_dbName/read').replace(queryParameters: q);

  Future<String> _token() async {
    final t = await _auth.getAccessToken();
    if (t == null) throw Exception('Sesión inválida');
    return t;
  }

  // ---------- helpers ----------
  Future<List<Map<String, dynamic>>> _read({
    required String table,
    Map<String, String>? filters,
  }) async {
    final resp = await _client.get(
      _readUri({'tableName': table, ...?filters}),
      headers: {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json'
      },
    );
    if (resp.statusCode >= 300) {
      throw Exception('READ $table -> ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    throw Exception('Formato inesperado en /read');
  }

  Future<void> _insert(String table, List<Map<String, dynamic>> records) async {
    final resp = await _client.post(
      _insertUri(),
      headers: {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'tableName': table, 'records': records}),
    );
    if (resp.statusCode >= 300) {
      throw Exception('INSERT $table -> ${resp.statusCode} ${resp.body}');
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    final skipped = (parsed['skipped'] as List?) ?? [];
    if (skipped.isNotEmpty) {
      throw Exception('INSERT $table omitió: ${skipped.first}');
    }
  }

  Future<void> _update({
    required String table,
    required String id,
    required Map<String, dynamic> changes,
  }) async {
    final resp = await _client.put(
      _updateUri(),
      headers: {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'tableName': table,
        'idColumn': '_id',
        'idValue': id,
        'updates': changes,
      }),
    );
    if (resp.statusCode >= 300) {
      throw Exception('UPDATE $table -> ${resp.statusCode} ${resp.body}');
    }
  }

  bool _isRandom(String method) => method.toLowerCase().trim() == 'aleatorio';

  // ================== ICategorySource ==================
  @override
  Future<List<Category>> getCategoriesByCourse(String courseId) async {
    // 👇 Tabla correcta y FK correcta
    final rows = await _read(table: 'Categories', filters: {
      'Curso_id': courseId,
    });

    final List<Category> out = [];
    for (final r in rows) {
      final catId = (r['_id'] ?? '').toString();

      // (opcional) traer grupos para calcular groupSize
      final groups = await _read(table: 'Group', filters: {'Categorie_Id': catId});

      out.add(
        Category(
          id: catId,
          courseId: (r['Curso_id'] ?? '').toString(),
          name: (r['Name'] ?? '').toString(),        // por si es int8 en el esquema
          method: (r['IsRamdom'] == true || r['IsRamdom'] == 'true')
              ? 'aleatorio'
              : 'manual',
          groupSize: groups.isNotEmpty
              ? (int.tryParse('${groups.first['Quantity'] ?? 0}') ?? 0)
              : 0,
          groups: const [],
        ),
      );
    }
    return out;
  }

  @override
  Future<void> addCategory(Category category) async {
    // 1) Insertar categoría SIN _id para que se autogenere
    final insertResp = await _client.post(
      _insertUri(),
      headers: {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'tableName': 'Categories',
        'records': [
          {
            // '_id':  NO ENVIAR
            'Curso_id': category.courseId,      // 👈 FK correcta
            'Name': category.name,              // idealmente varchar en BD
            'Description': category.method,     // opcional
            'IsRamdom': _isRandom(category.method),
          }
        ]
      }),
    );

    if (insertResp.statusCode >= 300) {
      throw Exception('INSERT Categories -> ${insertResp.statusCode} ${insertResp.body}');
    }
    final parsed = jsonDecode(insertResp.body) as Map<String, dynamic>;
    final skipped = (parsed['skipped'] as List?) ?? [];
    if (skipped.isNotEmpty) {
      throw Exception('INSERT Categories omitió: ${skipped.first}');
    }
    final inserted = (parsed['inserted'] as List?) ?? [];
    if (inserted.isEmpty) throw Exception('INSERT Categories no devolvió registro');
    final newCategoryId = (inserted.first['_id'] ?? '').toString();
    if (newCategoryId.isEmpty) throw Exception('No se obtuvo _id de la categoría creada');

    // 2) Leer Max_students del curso
    final courseRows =
        await _read(table: 'Course', filters: {'_id': category.courseId});
    if (courseRows.isEmpty) throw Exception('Curso no encontrado');
    final maxStudents =
        int.tryParse('${courseRows.first['Max_students'] ?? 0}') ?? 0;

    // 3) Calcular grupos (mínimo 1)
    final groupSize = (category.groupSize <= 0) ? 5 : category.groupSize;
    final groupCount = (maxStudents / groupSize).ceil().clamp(1, 1000);

    // 4) Crear grupos con FK a la categoría recién creada
    final List<Map<String, dynamic>> records = List.generate(groupCount, (i) {
      return {
        'Categorie_Id': newCategoryId,             // 👈 debe ser varchar en BD
        'Quantity': groupSize,
        'IsRamdomGroup': _isRandom(category.method),
      };
    });

    final gResp = await _client.post(
      _insertUri(),
      headers: {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'tableName': 'Group', 'records': records}),
    );
    if (gResp.statusCode >= 300) {
      throw Exception('INSERT Group -> ${gResp.statusCode} ${gResp.body}');
    }
    final gParsed = jsonDecode(gResp.body) as Map<String, dynamic>;
    final gSkipped = (gParsed['skipped'] as List?) ?? [];
    if (gSkipped.isNotEmpty) {
      throw Exception('INSERT Group omitió: ${gSkipped.first}');
    }
  }

  @override
  Future<void> updateCategory(Category updated) async {
    await _update(
      table: 'Categories',               // 👈 tabla correcta
      id: updated.id,
      changes: {
        'Name': updated.name,
        'Description': updated.method,
        'IsRamdom': _isRandom(updated.method),
      },
    );

    // actualizar capacidad de grupos si cambió el groupSize
    final newCapacity = updated.groupSize <= 0 ? 5 : updated.groupSize;
    final groups =
        await _read(table: 'Group', filters: {'Categorie_Id': updated.id});
    for (final g in groups) {
      final gid = (g['_id'] ?? '').toString();
      if (gid.isEmpty) continue;
      await _update(
        table: 'Group',
        id: gid,
        changes: {'Quantity': newCapacity},
      );
    }
  }

  @override
  Future<void> removeCategory(String categoryId) async {
    // Si no tienes columnas de estado, puedes omitir este update.
    try {
      await _update(
        table: 'Categories',
        id: categoryId,
        changes: {'Estado': 'FIN'}, // solo si existe
      );
    } catch (_) {/* silencioso */}
  }
}
