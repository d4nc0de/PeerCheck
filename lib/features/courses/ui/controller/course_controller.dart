import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/course.dart';
import '../../domain/use_case/course_usecase.dart';

class CourseController extends GetxController {
  final RxList<Course> _teacherCourses = <Course>[].obs;
  final RxList<Course> _studentCourses = <Course>[].obs;
  final CourseUseCase courseUseCase = Get.find();
  final RxBool isLoading = false.obs;

  List<Course> get teacherCourses => _teacherCourses;
  List<Course> get studentCourses => _studentCourses;

  @override
  void onInit() {
    getTeacherCourses();
    getStudentCourses();
    super.onInit();
  }

  getCourses() async {
    logInfo("CourseController: Getting all courses");
    isLoading.value = true;
    _teacherCourses.value = await courseUseCase.getTeacherCourses();
    _studentCourses.value = await courseUseCase.getStudentCourses();
    isLoading.value = false;
  }

  getTeacherCourses() async {
    logInfo("CourseController: Getting teacher courses");
    isLoading.value = true;
    _teacherCourses.value = await courseUseCase.getTeacherCourses();
    isLoading.value = false;
  }

  getStudentCourses() async {
    logInfo("CourseController: Getting student courses");
    isLoading.value = true;
    _studentCourses.value = await courseUseCase.getStudentCourses();
    isLoading.value = false;
  }

  getCoursesByRole(bool isTeacher) async {
    logInfo("CourseController: Getting courses by role: $isTeacher");
    isLoading.value = true;
    if (isTeacher) {
      _teacherCourses.value = await courseUseCase.getTeacherCourses();
    } else {
      _studentCourses.value = await courseUseCase.getStudentCourses();
    }
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
    await getTeacherCourses();
  }

  updateCourse(Course course) async {
    logInfo("CourseController: Update course");
    await courseUseCase.updateCourse(course);
    await getTeacherCourses();
  }

  void deleteCourse(Course course) async {
    logInfo("CourseController: Delete course");
    await courseUseCase.deleteCourse(course);
    await getTeacherCourses();
    await getStudentCourses();
  }

  void deleteCourses() async {
    logInfo("CourseController: Delete all courses");
    isLoading.value = true;
    await courseUseCase.deleteCourses();
    await getTeacherCourses();
    await getStudentCourses();
    isLoading.value = false;
  }

  void enrollUser(String courseId, String userEmail) async {
    logInfo("CourseController: Enroll user $userEmail in course $courseId");
    await courseUseCase.enrollUser(courseId, userEmail);
    await getTeacherCourses();
    await getStudentCourses();
  }

  void unenrollUser(String courseId, String userEmail) async {
    logInfo("CourseController: Unenroll user $userEmail from course $courseId");
    await courseUseCase.unenrollUser(courseId, userEmail);
    await getTeacherCourses();
    await getStudentCourses();
  }

  List<String> getEnrolledUsers(String courseId) {
    // Buscar en ambos listados
    final teacherCourse = _teacherCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
    );

    if (teacherCourse.name.isNotEmpty) {
      return teacherCourse.enrolledUsers;
    }

    final studentCourse = _studentCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
    );

    return studentCourse.enrolledUsers;
  }

  List<Course> getCurrentCourses(bool isTeacher) {
    return isTeacher ? _teacherCourses : _studentCourses;
  }
}
