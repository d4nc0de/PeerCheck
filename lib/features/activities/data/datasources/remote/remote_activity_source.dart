import 'dart:convert';
import 'package:f_clean_template/features/activities/data/datasources/i_activity_source.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
import 'package:http/http.dart' as http;

/// Fuente remota de actividades (usa el servicio de base de datos Roble)
class RemoteActivitySource implements IActivitySource {
  final http.Client client;
  final String baseUrl;
  final String dbName;
  final RemoteAuthenticationSourceService auth;

  RemoteActivitySource({
    required this.client,
    required this.baseUrl,
    required this.dbName,
    required this.auth,
  });

  String get _readUrl => '$baseUrl/$dbName/read';
  String get _insertUrl => '$baseUrl/$dbName/insert';
  String get _deleteUrl => '$baseUrl/$dbName/delete';

  /// 🧠 Construye los encabezados de forma segura (token real, no closure)
  Future<Map<String, String>> _getHeaders() async {
  final token = await auth.getAccessToken();
    if (token == null || token.isEmpty) {
      print("⚠️ Advertencia: accessToken no encontrado, posible sesión expirada.");
      return {
        'Content-Type': 'application/json',
        // ⚠️ sin Authorization, backend responderá 401 pero no crashea la app
      };
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  /// 📘 Obtiene las actividades de una categoría
  @override
  Future<List<Activity>> getActivities(String categoryId) async {
    final uri = Uri.parse(
        '$_readUrl?tableName=Activities&Categorie_Id=$categoryId');

    final headers = await _getHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      print('❌ Error al obtener actividades: ${res.body}');
      throw Exception('Error al obtener actividades');
    }

    final List<dynamic> decoded = jsonDecode(res.body);

    if (decoded.isEmpty) {
      print('ℹ️ No hay actividades registradas');
      return [];
    }

    return decoded.map((json) {
      final map = Map<String, dynamic>.from(json);
      return Activity(
        id: map['_id'] ?? '',
        categoryId: map['Categorie_Id'] ?? '',
        name: map['Name'] ?? '',
        description: '', // la BD no tiene campo descripción
        dueDate: map['EndDate'] != null
            ? DateTime.tryParse(map['EndDate']) ?? DateTime.now()
            : DateTime.now(),
        score: 0, // no hay calificación en la BD todavía
      );
    }).toList();
  }


  /// 💾 Guarda o reemplaza las actividades de una categoría
  /// (borra las existentes antes de insertar las nuevas)
  @override
  Future<void> saveActivities(
      String categoryId, List<Activity> activities) async {
    final headers = await _getHeaders(); // 👈 usar el mismo método

    // 🧹 1️⃣ Eliminar las actividades existentes de esa categoría
    final deleteUri = Uri.parse(_deleteUrl);
    final deleteBody = jsonEncode({
      "tableName": "Activities",
      "idColumn": "Categorie_Id",
      "idValue": categoryId,
    });

    final delRes = await client.delete(
      deleteUri,
      headers: headers,
      body: deleteBody,
    );

    if (delRes.statusCode != 200) {
      print('⚠️ Error al eliminar actividades previas: ${delRes.body}');
    } else {
      print('🗑️ Actividades previas eliminadas para categoría $categoryId');
    }

    // 🚀 2️⃣ Insertar las nuevas actividades
    if (activities.isEmpty) return;

    final insertUri = Uri.parse(_insertUrl);

    final records = activities.map((a) {
      final jsonMap = a.toJson();
      return {
        "Name": jsonMap['name'],
        "Categorie_Id": jsonMap['categoryId'],
        "StartDate": DateTime.now().toIso8601String(),
        "EndDate": jsonMap['dueDate'],
      };
    }).toList();

    final insertBody = jsonEncode({
      "tableName": "Activities",
      "records": records,
    });

    final res =
        await client.post(insertUri, headers: headers, body: insertBody);

    if (res.statusCode != 200) {
      print('❌ Error al guardar actividades: ${res.body}');
      throw Exception('Error al guardar actividades');
    }

    print('✅ Actividades guardadas remotamente (${activities.length})');
  }
}
