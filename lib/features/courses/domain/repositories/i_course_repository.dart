import '../models/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();
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
