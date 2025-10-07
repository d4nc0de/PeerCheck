import 'dart:convert';
import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:http/http.dart' as http;
import 'package:f_clean_template/features/courses/data/datasources/i_course_source.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class RemoteCourseSource implements ICourseSource {
  final http.Client _client;
  final String _baseUrl;  // https://roble-api.openlab.uninorte.edu.co/database
  final String _dbName;   // peercheck_xxx
  final RemoteAuthenticationSourceService _auth;

  RemoteCourseSource({
    required http.Client client,
    required String baseUrl,
    required String dbName,
    required RemoteAuthenticationSourceService auth,
  })  : _client = client,
        _baseUrl = baseUrl,
        _dbName = dbName,
        _auth = auth;

  Uri _insertUri()  => Uri.parse('$_baseUrl/$_dbName/insert');
  Uri _readUri(Map<String, String> q) =>
      Uri.parse('$_baseUrl/$_dbName/read').replace(queryParameters: q);
  Uri _updateUri()  => Uri.parse('$_baseUrl/$_dbName/update');

  // ----------------------- helpers HTTP -----------------------
  Future<String> _getToken() async {
    final t = await _auth.getAccessToken();
    if (t == null) throw Exception('Sesión inválida: token no encontrado');
    return t;
  }

  Future<List<Map<String, dynamic>>> _read({
    required String tableName,
    Map<String, String>? filters,
  }) async {
    final token = await _getToken();
    final resp = await _client.get(
      _readUri({'tableName': tableName, ...?filters}),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('READ $tableName -> ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.cast<Map<String, dynamic>>();
    throw Exception('Formato inesperado en /read');
  }

  Future<Map<String, dynamic>> _update({
    required String tableName,
    required String idColumn,
    required String idValue,
    required Map<String, dynamic> updates,
  }) async {
    final token = await _getToken();
    final resp = await _client.put(
      _updateUri(),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'tableName': tableName,
        'idColumn': idColumn,
        'idValue': idValue,
        'updates': updates,
      }),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('UPDATE $tableName -> ${resp.statusCode} ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  String _today() {
    final d = DateTime.now();
    // yyyy-MM-dd (tipo 'date' en tu tabla)
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Course _mapRecordToCourse(
    Map<String, dynamic> rec, {
    required AuthenticationUser currentUser,
  }) {
    return Course(
      id: (rec['_id'] ?? '').toString(),
      name: (rec['Description'] ?? '').toString(),
      nrc: 0, // agrega si luego creas la columna
      teacher: currentUser.email, // para UI
      category: '',               // idem
      maxStudents: int.tryParse('${rec['Max_stude'] ?? 0}') ?? 0,
      enrolledUsers: const [],
    );
  }

  // ----------------------- CREATE COURSE -----------------------
  @override
  Future<void> addCourse(
    String name,
    int nrc,
    String teacher,   // ignorado: se usa el logueado
    String category,  // si lo agregas en DB, mapea aquí
    int maxStudents,
  ) async {
    final access = await _auth.getAccessToken();
    final teacherBackendId = _auth.getCurrentBackendUserId();
    if (access == null || teacherBackendId == null) {
      throw Exception('Sesión inválida: faltan tokens o userId');
    }

    final resp = await _client.post(
      _insertUri(),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $access'},
      body: jsonEncode({
        'tableName': 'Course',
        'records': [
          {
            'Description': name,
            'teacher_id': teacherBackendId, // UUID en varchar
            'Max_students': maxStudents,
          }
        ]
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Insert Course -> ${resp.statusCode} ${resp.body}');
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    final skipped = (parsed['skipped'] as List?) ?? [];
    if (skipped.isNotEmpty) {
      throw Exception('El backend omitió el registro: ${skipped.first}');
    }
  }

  // ------------------ READ: cursos del profesor ------------------
  @override
  Future<List<Course>> getTeacherCourses(String _teacherEmailIgnored) async {
    final user = _auth.getCurrentUser();
    final teacherBackendId = _auth.getCurrentBackendUserId();
    if (user == null || teacherBackendId == null) {
      throw Exception('Sesión inválida: usuario o backendId no disponible');
    }
    final rows = await _read(
      tableName: 'Course',
      filters: {'teacher_id': teacherBackendId},
    );
    return rows.map((r) => _mapRecordToCourse(r, currentUser: user)).toList();
  }

  // ------------------ READ: cursos del estudiante ------------------
  @override
  Future<List<Course>> getStudentCourses(String _userEmailIgnored) async {
    final user = _auth.getCurrentUser();
    final backendId = _auth.getCurrentBackendUserId();
    if (user == null || backendId == null) {
      throw Exception('Sesión inválida: usuario o backendId no disponible');
    }

    // 1) Traer relaciones activas del estudiante
    final rels = await _read(
      tableName: 'Rel_Curso_Estudiante',
      filters: {
        'Estudiante_Id': backendId,
        'Estado': 'ACT',
      },
    );

    if (rels.isEmpty) return [];

    // 2) Por cada relación, traer el curso
    final List<Course> out = [];
    for (final r in rels) {
      final courseId = (r['Curso_Id'] ?? '').toString();
      if (courseId.isEmpty) continue;

      final rows = await _read(
        tableName: 'Course',
        filters: {'_id': courseId},
      );
      if (rows.isNotEmpty) {
        out.add(_mapRecordToCourse(rows.first, currentUser: user));
      }
    }
    return out;
  }

  // ------------------ ENROLL: inscribir estudiante ------------------
  @override
  Future<void> enrollUser(String courseId, String _userEmailIgnored) async {
    final access = await _auth.getAccessToken();
    final studentId = _auth.getCurrentBackendUserId();
    if (access == null || studentId == null) {
      throw Exception('Sesión inválida');
    }

    // 0) Validar no duplicado (ya ACT)
    final existing = await _read(
      tableName: 'Rel_Curso_Estudiante',
      filters: {
        'Estudiante_Id': studentId,
        'Curso_Id': courseId,
        'Estado': 'ACT',
      },
    );
    if (existing.isNotEmpty) {
      throw Exception('Ya estás inscrito en este curso');
    }

    // 1) Traer Max_students del curso
    final courseRows = await _read(
      tableName: 'Course',
      filters: {'_id': courseId},
    );
    if (courseRows.isEmpty) throw Exception('Curso no encontrado');

    // 👇 Cambia esta línea
    final max = int.tryParse('${courseRows.first['Max_students'] ?? 0}') ?? 0;


    // 2) Contar inscritos activos
    final actives = await _read(
      tableName: 'Rel_Curso_Estudiante',
      filters: {'Curso_Id': courseId, 'Estado': 'ACT'},
    );
    if (actives.length >= max) {
      throw Exception('El curso alcanzó su capacidad máxima');
    }

    // 3) Insertar relación ACT
    final resp = await _client.post(
      _insertUri(),
      headers: {'Authorization': 'Bearer $access', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'tableName': 'Rel_Curso_Estudiante',
        'records': [
          {
            'Estudiante_Id': studentId,
            'Curso_Id': courseId,
            'Estado': 'ACT',
            'Fecha_Ingreso': _today(),
          }
        ]
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Insert Rel_Curso_Estudiante -> ${resp.statusCode} ${resp.body}');
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    final skipped = (parsed['skipped'] as List?) ?? [];
    if (skipped.isNotEmpty) {
      throw Exception('No se pudo inscribir: ${skipped.first}');
    }
  }

  // --------------- UNENROLL: darse de baja (FIN) ----------------
  @override
  Future<void> unenrollUser(String courseId, String _userEmailIgnored) async {
    final studentId = _auth.getCurrentBackendUserId();
    if (studentId == null) throw Exception('Sesión inválida');

    // 1) Buscar la relación ACTiva
    final rels = await _read(
      tableName: 'Rel_Curso_Estudiante',
      filters: {'Estudiante_Id': studentId, 'Curso_Id': courseId, 'Estado': 'ACT'},
    );
    if (rels.isEmpty) {
      throw Exception('No estás inscrito en este curso');
    }

    final relId = (rels.first['_id'] ?? '').toString();
    if (relId.isEmpty) throw Exception('Relación inválida');

    // 2) UPDATE -> Estado=FIN, Fecha_Fin=HOY
    await _update(
      tableName: 'Rel_Curso_Estudiante',
      idColumn: '_id',
      idValue: relId,
      updates: {'Estado': 'FIN', 'Fecha_Fin': _today()},
    );
  }

  // ------------------ Aún sin conectar ------------------
  @override
  Future<List<Course>> getCourses() async => throw UnimplementedError();

  @override
  Future<List<Course>> getCoursesByRole(bool isTeacher, String userEmail) async =>
      isTeacher ? getTeacherCourses(userEmail) : getStudentCourses(userEmail);

  @override
  Future<void> updateCourse(Course course) async => throw UnimplementedError();

  @override
  Future<void> deleteCourse(Course course) async => throw UnimplementedError();

  @override
  Future<void> deleteCourses() async => throw UnimplementedError();
}
