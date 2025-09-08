import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/data/datasources/i_course_source.dart';
import 'package:get/get.dart';

class LocalCourseSource implements ICourseSource {
  final List<Course> _courses = [
    // Cursos predeterminados para pruebas
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
  ].obs;

  @override
  Future<List<Course>> getCourses() async {
    return _courses;
  }

  @override
  Future<List<Course>> getTeacherCourses() async {
    return _courses
        .where((course) => !course.id.startsWith('default_'))
        .toList();
  }

  @override
  Future<List<Course>> getStudentCourses(String userEmail) async {
    return _courses
        .where((course) => course.enrolledUsers.contains(userEmail))
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
    // Verificar si ya existe un curso con el mismo NRC
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
  }

  @override
  Future<void> updateCourse(Course updatedCourse) async {
    final index = _courses.indexWhere(
      (course) => course.id == updatedCourse.id,
    );
    if (index != -1) {
      _courses[index] = updatedCourse;
    }
  }

  @override
  Future<void> deleteCourse(Course courseToDelete) async {
    _courses.removeWhere((course) => course.id == courseToDelete.id);
  }

  @override
  Future<void> deleteCourses() async {
    final defaultCourses = _courses
        .where((course) => course.id.startsWith('default_'))
        .toList();
    _courses.clear();
    _courses.addAll(defaultCourses);
  }

  @override
  Future<void> enrollUser(String courseId, String userEmail) async {
    final course = _courses.firstWhere((c) => c.id == courseId);
    if (!course.enrolledUsers.contains(userEmail) && course.hasAvailableSpots) {
      course.enrolledUsers.add(userEmail);
    }
  }

  @override
  Future<void> unenrollUser(String courseId, String userEmail) async {
    final course = _courses.firstWhere((c) => c.id == courseId);
    course.enrolledUsers.remove(userEmail);
  }

  @override
  Future<List<Course>> getCoursesByRole(
    bool isTeacher,
    String userEmail,
  ) async {
    return isTeacher
        ? await getTeacherCourses()
        : await getStudentCourses(userEmail);
  }

  Course? findCourseByNrc(int nrc) {
    try {
      return _courses.firstWhere((course) => course.nrc == nrc);
    } catch (e) {
      return null;
    }
  }
}
