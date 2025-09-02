import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/data/datasources/i_course_source.dart';

class LocalCourseSource implements ICourseSource {
  final List<Course> _courses = [];

  @override
  Future<List<Course>> getCourses() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); // Simular delay de red
    return _courses;
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
      name: name,
      nrc: nrc,
      teacher: teacher,
      category: category,
      maxStudents: maxStudents,
    );
    _courses.add(newCourse);
  }

  @override
  Future<void> updateCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _courses.removeWhere((c) => c.id == course.id);
  }

  @override
  Future<void> deleteCourses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _courses.clear();
  }

  @override
  Future<void> enrollUser(String courseId, String userEmail) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(name: '', nrc: 0, teacher: '', category: ''),
    );
    if (!course.enrolledUsers.contains(userEmail) && course.hasAvailableSpots) {
      course.enrolledUsers.add(userEmail);
    }
  }

  @override
  Future<void> unenrollUser(String courseId, String userEmail) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(name: '', nrc: 0, teacher: '', category: ''),
    );
    course.enrolledUsers.remove(userEmail);
  }
}
