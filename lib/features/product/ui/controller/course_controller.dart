import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/course.dart';
import '../../domain/use_case/course_usecase.dart';

class CourseController extends GetxController {
  final RxList<Course> _courses = <Course>[].obs;
  final CourseUseCase courseUseCase = Get.find();
  final RxBool isLoading = false.obs;
  List<Course> get courses => _courses;

  @override
  void onInit() {
    getCourses();
    super.onInit();
  }

  getCourses() async {
    logInfo("CourseController: Getting courses");
    isLoading.value = true;
    _courses.value = await courseUseCase.getCourses();
    isLoading.value = false;
  }

  addCourse(
    String name,
    int nrc,
    String teacher,
    String category,
    int maxStudents,
  ) async {
    logInfo("CourseController: Add course");
    await courseUseCase.addCourse(name, nrc, teacher, category, maxStudents);
    getCourses();
  }

  updateCourse(Course course) async {
    logInfo("CourseController: Update course");
    await courseUseCase.updateCourse(course);
    await getCourses();
  }

  void deleteCourse(Course course) async {
    logInfo("CourseController: Delete course");
    await courseUseCase.deleteCourse(course);
    await getCourses();
  }

  void deleteCourses() async {
    logInfo("CourseController: Delete all courses");
    isLoading.value = true;
    await courseUseCase.deleteCourses();
    await getCourses();
    isLoading.value = false;
  }

  void enrollUser(String courseId, String userEmail) async {
    logInfo("CourseController: Enroll user $userEmail in course $courseId");
    await courseUseCase.enrollUser(courseId, userEmail);
    await getCourses();
  }

  void unenrollUser(String courseId, String userEmail) async {
    logInfo("CourseController: Unenroll user $userEmail from course $courseId");
    await courseUseCase.unenrollUser(courseId, userEmail);
    await getCourses();
  }

  List<String> getEnrolledUsers(String courseId) {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(name: '', nrc: 0, teacher: '', category: ''),
    );
    return course.enrolledUsers;
  }
}
