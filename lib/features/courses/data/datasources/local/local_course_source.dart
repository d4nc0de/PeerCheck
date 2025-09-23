import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/data/datasources/i_course_source.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class LocalCourseSource implements ICourseSource {
  static const String _coursesKey = "courses_data";

  final List<Course> _defaultCourses = [
    Course(
      id: 'default_course_001',
      name: 'Programación Avanzada',
      nrc: 12345,
      teacher: 'Dr. Carlos Mendoza',
      category: 'Ingeniería',
      maxStudents: 40,
      enrolledUsers: [],
    ),
    Course(
      id: 'default_course_002',
      name: 'Diseño de Interfaces',
      nrc: 67890,
      teacher: 'Prof. Ana García',
      category: 'Diseño',
      maxStudents: 35,
      enrolledUsers: [],
    ),
    Course(
      id: 'default_course_003',
      name: 'curso1',
      nrc: 11111,
      teacher: 'a@a.com',
      category: 'General',
      maxStudents: 30,
      enrolledUsers: ['b@a.com'],
    ),
  ];

  List<Course> _courses = [];

  LocalCourseSource() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_coursesKey) ?? [];

    _courses = stored.map((e) => Course.fromJson(jsonDecode(e))).toList();

    // Si es primera vez, guardamos cursos por defecto
    if (_courses.isEmpty) {
      _courses = [..._defaultCourses];
      await _saveCourses();
    }
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _courses.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_coursesKey, data);
  }

  @override
  Future<List<Course>> getCourses() async {
    return _courses;
  }

  @override
  Future<List<Course>> getTeacherCourses(String teacherEmail) async {
    return _courses.where((c) => c.teacher == teacherEmail).toList();
  }

  @override
  Future<List<Course>> getStudentCourses(String userEmail) async {
    return _courses
        .where(
          (c) => c.enrolledUsers.contains(userEmail) && c.teacher != userEmail,
        )
        .toList();
  }

  @override
  Future<void> addCourse(
    String name,
    int nrc,
    String teacher,
    String category,
    int maxStudents,
  ) async {
    if (findCourseByNrc(nrc) != null) {
      throw Exception('Ya existe un curso con el NRC: $nrc');
    }

    final newCourse = Course(
      id: 'course_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      nrc: nrc,
      teacher: teacher,
      category: category,
      maxStudents: maxStudents,
      enrolledUsers: [],
    );

    _courses.add(newCourse);
    await _saveCourses();
  }

  @override
  Future<void> updateCourse(Course updatedCourse) async {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      await _saveCourses();
    }
  }

  @override
  Future<void> deleteCourse(Course courseToDelete) async {
    _courses.removeWhere((c) => c.id == courseToDelete.id);
    await _saveCourses();
  }

  @override
  Future<void> deleteCourses() async {
    _courses.clear();
    await _saveCourses();
  }

  @override
  Future<void> enrollUser(String courseId, String userEmail) async {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw Exception("Curso no encontrado"),
    );

    if (course.teacher == userEmail) return;
    if (!course.enrolledUsers.contains(userEmail) && course.hasAvailableSpots) {
      course.enrolledUsers.add(userEmail);
      await _saveCourses();
    }
  }

  @override
  Future<void> unenrollUser(String courseId, String userEmail) async {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw Exception("Curso no encontrado"),
    );

    course.enrolledUsers.remove(userEmail);
    await _saveCourses();
  }

  @override
  Future<List<Course>> getCoursesByRole(
    bool isTeacher,
    String userEmail,
  ) async {
    return isTeacher
        ? await getTeacherCourses(userEmail)
        : await getStudentCourses(userEmail);
  }

  Course? findCourseByNrc(int nrc) {
    try {
      return _courses.firstWhere((c) => c.nrc == nrc);
    } catch (e) {
      return null;
    }
  }

  Future<List<AuthenticationUser>> getEnrolledUsers(
      String courseId, List<AuthenticationUser> allUsers) async {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw Exception("Curso no encontrado"),
    );

    // Filtrar los usuarios completos por los correos inscritos
    final enrolledUsers = allUsers
        .where((u) => course.enrolledUsers.contains(u.email))
        .toList();

    return enrolledUsers;
  }

}