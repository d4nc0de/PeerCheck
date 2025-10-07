import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';

class RemoteCategorySource {
  final http.Client _client;
  final String _baseUrl; // .../database
  final String _dbName;
  final RemoteAuthenticationSourceService _auth;

  RemoteCategorySource({
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

  bool _isRandom(String method) => method.toLowerCase().trim() == 'aleatorio';

  String _todayDate() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // ---------- helpers ----------
  Future<List<Map<String, dynamic>>> _read({
    required String table,
    Map<String, String>? filters,
  }) async {
    final resp = await _client.get(
      _readUri({'tableName': table, ...?filters}),
      headers: {'Authorization': 'Bearer ${await _token()}', 'Content-Type': 'application/json'},
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
      headers: {'Authorization': 'Bearer ${await _token()}', 'Content-Type': 'application/json'},
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
      headers: {'Authorization': 'Bearer ${await _token()}', 'Content-Type': 'application/json'},
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

  // ---------- API Pública ----------
  /// Crea la categoría y los grupos correspondientes.
  Future<void> addCategory(Category category) async {
    // 1) Insertar categoría (pasamos _id = category.id para mantener tu modelo)
    await _insert('Categorie', [
      {
        '_id': category.id,
        // si tu tabla tiene Course_Id, esto la relaciona al curso
        'Course_Id': category.courseId,
        'Name': category.name,
        'Description': category.method, // opcional, útil para ver método
        'IsRamdom': _isRandom(category.method),
      }
    ]);

    // 2) Leer Max_students del curso
    final courseRows = await _read(table: 'Course', filters: {'_id': category.courseId});
    if (courseRows.isEmpty) throw Exception('Curso no encontrado');
    final maxStudents = int.tryParse('${courseRows.first['Max_students'] ?? 0}') ?? 0;

    // 3) Calcular cantidad de grupos = ceil(Max / groupSize). Mínimo 1
    final gs = (category.groupSize <= 0) ? 5 : category.groupSize;
    final groupCount = (maxStudents / gs).ceil().clamp(1, 1000);

    // 4) Crear grupos
    final List<Map<String, dynamic>> records = [];
    for (int i = 0; i < groupCount; i++) {
      records.add({
        // si quieres controlar IDs, agrega '_id': 'grp_${category.id}_$i'
        'Categorie_Id': category.id,
        'Quantity': gs,                 // capacidad deseada por grupo
        'IsRamdomGroup': _isRandom(category.method),
      });
    }
    await _insert('Group', records);

    // 5) Si es aleatorio, opcional: distribuir estudiantes actuales en grupos
    if (_isRandom(category.method)) {
      await _autoAssignStudentsToGroups(categoryId: category.id, courseId: category.courseId);
    }
  }

  /// Edita campos básicos y, si cambia `groupSize`, ajusta cantidad/capacidad de grupos.
  Future<void> updateCategory(Category category) async {
    // 1) Actualizar la categoría
    await _update(
      table: 'Categorie',
      id: category.id,
      changes: {
        'Name': category.name,
        'Description': category.method,
        'IsRamdom': _isRandom(category.method),
      },
    );

    // 2) Ajuste de grupos si cambia el tamaño (capacidad por grupo)
    //    (para hacer un "resize" suave, solo actualizamos Quantity de los grupos existentes)
    await _updateGroupsCapacity(
      categoryId: category.id,
      newCapacity: category.groupSize <= 0 ? 5 : category.groupSize,
    );
  }

  /// Dar de baja la categoría. Si tu tabla no tiene columnas de estado, no falla; solo intenta.
  Future<void> closeCategory(String categoryId) async {
    // Intento marcar FIN si existen columnas (no rompe si no existen)
    try {
      await _update(
        table: 'Categorie',
        id: categoryId,
        changes: {'Estado': 'FIN', 'Fecha_Fin': _todayDate()},
      );
    } catch (_) {
      // Silencioso: tu tabla puede no tener estas columnas
    }

    // También podrías marcar grupos como cerrados si tienes columnas de estado.
  }

  // ---------- utilidades para grupos / asignación ----------
  Future<void> _updateGroupsCapacity({
    required String categoryId,
    required int newCapacity,
  }) async {
    // leer grupos de la categoría
    final groups = await _read(table: 'Group', filters: {'Categorie_Id': categoryId});
    if (groups.isEmpty) return;
    // actualizar quantity en cada grupo
    for (final g in groups) {
      final gid = (g['_id'] ?? '').toString();
      if (gid.isEmpty) continue;
      await _update(table: 'Group', id: gid, changes: {'Quantity': newCapacity});
    }
  }

  /// Asignación aleatoria inicial de estudiantes del curso a los grupos (balanceado)
  Future<void> _autoAssignStudentsToGroups({
    required String categoryId,
    required String courseId,
  }) async {
    // 1) estudiantes activos del curso
    final rels = await _read(
      table: 'Rel_Curso_Estudiante',
      filters: {'Curso_Id': courseId, 'Estado': 'ACT'},
    );
    if (rels.isEmpty) return;

    // 2) grupos de la categoría
    final groups = await _read(table: 'Group', filters: {'Categorie_Id': categoryId});
    if (groups.isEmpty) return;

    // 3) round-robin (sin exceder Quantity)
    int gi = 0;
    final toInsert = <Map<String, dynamic>>[];
    final capacities = {
      for (final g in groups) (g['_id'] as String): int.tryParse('${g['Quantity'] ?? 0}') ?? 0
    };
    final occupancy = {for (final id in capacities.keys) id: 0};

    for (final r in rels) {
      // buscar siguiente grupo con cupo
      int attempts = 0;
      String? targetGroupId;
      while (attempts < groups.length) {
        final g = groups[gi % groups.length];
        final gid = (g['_id'] ?? '').toString();
        if (occupancy[gid]! < capacities[gid]!) {
          targetGroupId = gid;
          break;
        }
        gi++;
        attempts++;
      }
      if (targetGroupId == null) break; // no hay más cupos

      toInsert.add({
        'Estudiante_Id': (r['Estudiante_Id'] ?? '').toString(),
        'Grupo_Id': targetGroupId,
        'Estado': 'ACT',
        'Fecha_Ingreso': DateTime.now().millisecondsSinceEpoch, // tu tabla es int8
      });
      occupancy[targetGroupId] = occupancy[targetGroupId]! + 1;
      gi++;
    }

    if (toInsert.isNotEmpty) {
      await _insert('Rel_Estudiante_Grupo', toInsert);
    }
  }
}
