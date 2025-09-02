import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/domain/repositories/i_course_repository.dart';

class CourseUseCase {
  final ICourseRepository courseRepository;

  CourseUseCase(this.courseRepository);

  Future<List<Course>> getCourses() async {
    return await courseRepository.getCourses();
  }

  Future<void> addCourse(
    String name,
    int nrc,
    String teacher,
    String category,
    int maxStudents,
  ) async {
    return await courseRepository.addCourse(
      name,
      nrc,
      teacher,
      category,
      maxStudents,
    );
  }

  Future<void> updateCourse(Course course) async {
    return await courseRepository.updateCourse(course);
  }

  Future<void> deleteCourse(Course course) async {
    return await courseRepository.deleteCourse(course);
  }

  Future<void> deleteCourses() async {
    return await courseRepository.deleteCourses();
  }

  Future<void> enrollUser(String courseId, String userEmail) async {
    return await courseRepository.enrollUser(courseId, userEmail);
  }

  Future<void> unenrollUser(String courseId, String userEmail) async {
    return await courseRepository.unenrollUser(courseId, userEmail);
  }
}
