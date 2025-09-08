import 'package:f_clean_template/features/courses/domain/models/course.dart';

abstract class ICourseSource {
  Future<List<Course>> getCourses();
  Future<List<Course>> getTeacherCourses();
  Future<List<Course>> getStudentCourses(String userEmail);
  Future<List<Course>> getCoursesByRole(bool isTeacher, String userEmail);
  Future<void> addCourse(
    String name,
    int nrc,
    String teacher,
    String category,
    int maxStudents,
  );
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(Course course);
  Future<void> deleteCourses();
  Future<void> enrollUser(String courseId, String userEmail);
  Future<void> unenrollUser(String courseId, String userEmail);
}
