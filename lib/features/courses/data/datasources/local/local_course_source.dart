import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/data/datasources/i_course_source.dart';
import 'dart:math';

class LocalCourseSource implements ICourseSource {
  final List<Course> _teacherCourses = []; // Cursos creados por el profesor
  final List<Course> _studentCourses =
      []; // Cursos donde el estudiante está inscrito
  final Random _random = Random();

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  @override
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Devuelve cursos según el rol (esto se manejará desde el controller)
    return _teacherCourses;
  }

  Future<List<Course>> getTeacherCourses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _teacherCourses;
  }

  Future<List<Course>> getStudentCourses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _studentCourses;
  }

  @override
  Future<void> addCourse(
    String name,
    int nrc,
    String teacher,
    String category,
    int maxStudents,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final newCourse = Course(
      id: _generateId(),
      name: name,
      nrc: nrc,
      teacher: teacher,
      category: category,
      maxStudents: maxStudents,
    );
    _teacherCourses.add(newCourse);
  }

  @override
  Future<void> updateCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _teacherCourses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _teacherCourses[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _teacherCourses.removeWhere((c) => c.id == course.id);
    _studentCourses.removeWhere((c) => c.id == course.id);
  }

  @override
  Future<void> deleteCourses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _teacherCourses.clear();
    _studentCourses.clear();
  }

  @override
  Future<void> enrollUser(String courseId, String userEmail) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Buscar el curso en los cursos del profesor
    final teacherCourse = _teacherCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
    );

    if (teacherCourse.name.isNotEmpty) {
      // Agregar usuario al curso del profesor
      if (!teacherCourse.enrolledUsers.contains(userEmail) &&
          teacherCourse.hasAvailableSpots) {
        teacherCourse.enrolledUsers.add(userEmail);
      }

      // Buscar si el curso ya existe en los cursos del estudiante
      final existingStudentCourse = _studentCourses.firstWhere(
        (c) => c.id == courseId,
        orElse: () =>
            Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
      );

      if (existingStudentCourse.name.isEmpty) {
        // Crear una copia del curso para el estudiante
        final studentCourse = Course(
          id: teacherCourse.id,
          name: teacherCourse.name,
          nrc: teacherCourse.nrc,
          teacher: teacherCourse.teacher,
          category: teacherCourse.category,
          enrolledUsers: List.from(teacherCourse.enrolledUsers),
          maxStudents: teacherCourse.maxStudents,
        );
        _studentCourses.add(studentCourse);
      }
    }
  }

  @override
  Future<void> unenrollUser(String courseId, String userEmail) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Remover usuario del curso del profesor
    final teacherCourse = _teacherCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
    );
    if (teacherCourse.name.isNotEmpty) {
      teacherCourse.enrolledUsers.remove(userEmail);
    }

    // Remover usuario del curso del estudiante
    final studentCourse = _studentCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
    );
    if (studentCourse.name.isNotEmpty) {
      studentCourse.enrolledUsers.remove(userEmail);

      // Si no hay más usuarios inscritos, remover el curso del estudiante
      if (studentCourse.enrolledUsers.isEmpty) {
        _studentCourses.removeWhere((c) => c.id == courseId);
      }
    }
  }

  // Nuevo método para obtener cursos según el rol
  Future<List<Course>> getCoursesByRole(bool isTeacher) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return isTeacher ? _teacherCourses : _studentCourses;
  }
}
