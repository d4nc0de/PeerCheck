import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/data/datasources/i_course_source.dart';

class LocalCourseSource implements ICourseSource {
  // Cursos predeterminados (visibles para todos)
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
      teacher: 'a@a.com', // profesor
      category: 'General',
      maxStudents: 30,
      enrolledUsers: ['b@a.com'], // estudiante
    ),
  ];

  // Mapa de profesor → lista de cursos creados
  final Map<String, List<Course>> _teacherCourses = {};

  @override
  Future<List<Course>> getCourses() async {
    // Todos los cursos (default + creados por profes)
    return [
      ..._defaultCourses,
      for (final courses in _teacherCourses.values) ...courses,
    ];
  }

  @override
  Future<List<Course>> getTeacherCourses(String teacherEmail) async {
    // Buscar en cursos por defecto y en los creados
    final allCourses = [
      ..._defaultCourses,
      for (final courses in _teacherCourses.values) ...courses,
    ];

    return allCourses
        .where((course) => course.teacher == teacherEmail)
        .toList();
  }

  @override
  Future<List<Course>> getStudentCourses(String userEmail) async {
    final allCourses = [
      ..._defaultCourses,
      for (final courses in _teacherCourses.values) ...courses,
    ];

    return allCourses
        .where(
          (course) =>
              course.enrolledUsers.contains(userEmail) &&
              course.teacher !=
                  userEmail, // 🚫 no puede ser estudiante en su propio curso
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
    // Evitar duplicados por NRC
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

    _teacherCourses.putIfAbsent(teacher, () => []);
    _teacherCourses[teacher]!.add(newCourse);
  }

  @override
  Future<void> updateCourse(Course updatedCourse) async {
    // Buscar entre cursos de todos los profes
    for (final entry in _teacherCourses.entries) {
      final index = entry.value.indexWhere(
        (course) => course.id == updatedCourse.id,
      );
      if (index != -1) {
        entry.value[index] = updatedCourse;
        return;
      }
    }
  }

  @override
  Future<void> deleteCourse(Course courseToDelete) async {
    for (final entry in _teacherCourses.entries) {
      entry.value.removeWhere((course) => course.id == courseToDelete.id);
    }
  }

  @override
  Future<void> deleteCourses() async {
    _teacherCourses.clear();
    // Los cursos default no se eliminan
  }

  @override
  Future<void> enrollUser(String courseId, String userEmail) async {
    final course = await _findCourseById(courseId);
    if (course == null) return;

    // 🚫 no permitir inscribirse si es el profesor del curso
    if (course.teacher == userEmail) return;

    if (!course.enrolledUsers.contains(userEmail) && course.hasAvailableSpots) {
      course.enrolledUsers.add(userEmail);
    }
  }

  @override
  Future<void> unenrollUser(String courseId, String userEmail) async {
    final course = await _findCourseById(courseId);
    if (course == null) return;

    course.enrolledUsers.remove(userEmail);
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
    final allCourses = [
      ..._defaultCourses,
      for (final courses in _teacherCourses.values) ...courses,
    ];
    try {
      return allCourses.firstWhere((course) => course.nrc == nrc);
    } catch (e) {
      return null;
    }
  }

  Future<Course?> _findCourseById(String courseId) async {
    final allCourses = [
      ..._defaultCourses,
      for (final courses in _teacherCourses.values) ...courses,
    ];
    try {
      return allCourses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }
}
