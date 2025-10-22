import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';

/// Acceso a tablas: Group y Rel_Estudiante_Grupo
class RemoteGroupSource {
  final http.Client client;
  final String baseDb; // ej: https://roble-api.../database
  final String dbName;
  final RemoteAuthenticationSourceService auth;

  RemoteGroupSource({
    required this.client,
    required this.baseDb,
    required this.dbName,
    required this.auth,
  });

  Uri get _read   => Uri.parse('$baseDb/$dbName/read');
  Uri get _insert => Uri.parse('$baseDb/$dbName/insert');
  Uri get _delete => Uri.parse('$baseDb/$dbName/delete');

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await auth.getAccessToken()}',
      };

  // -------- GROUP --------
  Future<List<Map<String, dynamic>>> readGroupsByCategory(String categoryId) async {
    final uri = _read.replace(queryParameters: {
      'tableName': 'Group',
      'Categorie_Id': categoryId,
    });
    final r = await client.get(uri, headers: await _headers());
    if (r.statusCode != 200) {
      throw Exception('readGroupsByCategory -> ${r.statusCode} ${r.body}');
    }
    return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<String> insertGroup({
    required String categoryId,
    required int number,         // lo usaremos como “Quantity”
    required bool isRandomGroup, // mapea con IsRamdonGroup
  }) async {
    final body = jsonEncode({
      'tableName': 'Group',
      'records': [
        {
          'Categorie_Id': categoryId,
          'Quantity': number,
          'IsRamdonGroup': isRandomGroup,
        }
      ]
    });
    final r = await client.post(_insert, headers: await _headers(), body: body);
    if (r.statusCode != 200) {
      throw Exception('insertGroup -> ${r.statusCode} ${r.body}');
    }
    final parsed = jsonDecode(r.body) as Map<String, dynamic>;
    final inserted = (parsed['inserted'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (inserted.isEmpty) throw Exception('insertGroup -> sin inserted');
    return inserted.first['_id'] as String;
  }

  Future<void> deleteGroupsByCategory(String categoryId) async {
    final body = jsonEncode({
      'tableName': 'Group',
      'Categorie_Id': categoryId,
    });
    final r = await client.post(_delete, headers: await _headers(), body: body);
    if (r.statusCode != 200) {
      throw Exception('deleteGroupsByCategory -> ${r.statusCode} ${r.body}');
    }
  }

  Future<void> deleteGroupById(String groupId) async {
    final body = jsonEncode({
      'tableName': 'Group',
      'idColumn': '_id',
      'idValue': groupId,
    });
    final r = await client.delete(_delete, headers: await _headers(), body: body);
    if (r.statusCode != 200) {
      throw Exception('deleteGroupById -> ${r.statusCode} ${r.body}');
    }
  }

  // -------- REL_ESTUDIANTE_GRUPO --------
  Future<void> insertMembersBatch({
    required String groupId,
    required List<String> studentIdsOrEmails,
  }) async {
    if (studentIdsOrEmails.isEmpty) return;

    final today = DateTime.now();
    final yyyyMmDd = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final records = studentIdsOrEmails.map((s) {
      return {
        'Estudiante_Id': s,   // usamos email como id temporal
        'Grupo_Id': groupId,
        'Estado': 'ACT',
        'Fecha_Ingreso': yyyyMmDd,
      };
    }).toList();

    final body = jsonEncode({
      'tableName': 'Rel_Estudiante_Grupo',
      'records': records,
    });

    final r = await client.post(_insert, headers: await _headers(), body: body);
    if (r.statusCode != 200) {
      throw Exception('insertMembersBatch -> ${r.statusCode} ${r.body}');
    }
  }

  Future<void> deleteMembersByGroup(String groupId) async {
    final body = jsonEncode({
      'tableName': 'Rel_Estudiante_Grupo',
      'Grupo_Id': groupId,
    });

    final r = await client.post(_delete, headers: await _headers(), body: body);
    if (r.statusCode != 200) {
      throw Exception('deleteMembersByGroup -> ${r.statusCode} ${r.body}');
    }
  }
}
