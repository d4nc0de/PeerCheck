import 'package:f_clean_template/features/product/domain/models/course.dart';
import 'package:f_clean_template/features/product/domain/repositories/i_course_repository.dart';
import 'package:f_clean_template/features/product/data/datasources/i_course_source.dart';

class CourseRepository implements ICourseRepository {
  final ICourseSource courseSource;

  CourseRepository(this.courseSource);

  @override
  Future<List<Course>> getCourses() async {
    return await courseSource.getCourses();
  }

  @override
  Future<void> addCourse(
    String name,
    int nrc,
    String teacher,
    String category,
    int maxStudents,
  ) async {
    return await courseSource.addCourse(
      name,
      nrc,
      teacher,
      category,
      maxStudents,
    );
  }

  @override
  Future<void> updateCourse(Course course) async {
    return await courseSource.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(Course course) async {
    return await courseSource.deleteCourse(course);
  }

  @override
  Future<void> deleteCourses() async {
    return await courseSource.deleteCourses();
  }

  @override
  Future<void> enrollUser(String courseId, String userEmail) async {
    return await courseSource.enrollUser(courseId, userEmail);
  }

  @override
  Future<void> unenrollUser(String courseId, String userEmail) async {
    return await courseSource.unenrollUser(courseId, userEmail);
  }
}
