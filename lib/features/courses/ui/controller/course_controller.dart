import 'package:f_clean_template/features/courses/domain/models/activity.dart';
import 'package:f_clean_template/features/courses/domain/models/category.dart';
import 'package:f_clean_template/features/courses/domain/models/group.dart';
import 'package:f_clean_template/features/courses/domain/models/member.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import 'package:f_clean_template/features/courses/domain/models/course.dart';
import 'package:f_clean_template/features/courses/domain/use_case/course_usecase.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';

class CourseController extends GetxController {
  final RxList<Course> _teacherCourses = <Course>[].obs;
  final RxList<Course> _studentCourses = <Course>[].obs;
  final CourseUseCase courseUseCase = Get.find();
  final AuthenticationController authController = Get.find();
  final RxBool isLoading = false.obs;

  final RxMap<String, List<Category>> _categoriesByCourse = <String, List<Category>>{}.obs;
  final RxMap<String, List<Activity>> _activitiesByCategory = <String, List<Activity>>{}.obs;

  final RxMap<String, GroupInfo> _myGroupByCourse = <String, GroupInfo>{}.obs;
  final RxMap<String, List<GroupInfo>> _groupsByCourse = <String, List<GroupInfo>>{}.obs;
  final RxMap<String, List<Member>> _membersByGroup = <String, List<Member>>{}.obs;

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
    final user = authController.currentUser.value;
    if (user != null) {
      _teacherCourses.value = await courseUseCase.getTeacherCourses(user.email);
    }
    if (user != null) {
      _studentCourses.value = await courseUseCase.getStudentCourses(user.email);
    }
    isLoading.value = false;
  }

  getTeacherCourses() async {
    logInfo("CourseController: Getting teacher courses");
    isLoading.value = true;
    final user = authController.currentUser.value;
    if (user != null) {
      _teacherCourses.value = await courseUseCase.getTeacherCourses(user.email);
    }
    isLoading.value = false;
  }

  getStudentCourses() async {
    logInfo("CourseController: Getting student courses");
    isLoading.value = true;

    final user = authController.currentUser.value;
    if (user != null) {
      _studentCourses.value = await courseUseCase.getStudentCourses(user.email);
    } else {
      _studentCourses.clear();
    }

    isLoading.value = false;
  }

  getCoursesByRole(bool isTeacher) async {
    logInfo("CourseController: Getting courses by role: $isTeacher");
    isLoading.value = true;

    final user = authController.currentUser.value;
    if (isTeacher) {
      final user = authController.currentUser.value;
      if (user != null) {
        _teacherCourses.value = await courseUseCase.getTeacherCourses(
          user.email,
        );
      }
    } else if (user != null) {
      _studentCourses.value = await courseUseCase.getCoursesByRole(
        false,
        user.email,
      );
    } else {
      _studentCourses.clear();
    }

    isLoading.value = false;
  }

  addCourse(String name, int nrc, String category, int maxStudents) async {
    final user = authController.currentUser.value;
    if (user == null) {
      Get.snackbar(
        "Error",
        "Debes estar autenticado para crear un curso",
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF001D3D),
        colorText: Colors.white,
      );
      return;
    }
    

    logInfo(
      "CourseController: Add course - $name (NRC: $nrc) by ${user.email}",
    );
    try {
      await courseUseCase.addCourse(
        name,
        nrc,
        user.email,
        category,
        maxStudents,
      );
      await getTeacherCourses();

      Get.back();

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          "Curso Creado",
          "El curso '$name' ha sido creado exitosamente",
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF003566),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      });
    } catch (err) {
      logError("Error adding course: $err");
      Get.snackbar(
        "Error",
        "No se pudo crear el curso: ${err.toString()}",
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF001D3D),
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  int? getMaxStudentsForCourseId(String courseId) {
      try {
        final c = _teacherCourses.firstWhere((e) => e.id == courseId);
        return c.maxStudents;
      } catch (_) {
        try {
          final c = _studentCourses.firstWhere((e) => e.id == courseId);
          return c.maxStudents;
        } catch (_) {
          return null;
        }
      }
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

    Get.snackbar(
      "Curso Eliminado",
      "El curso '${course.name}' ha sido eliminado",
      icon: const Icon(Icons.delete, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFB91C1C),
      colorText: Colors.white,
    );
  }

  void deleteCourses() async {
    logInfo("CourseController: Delete all courses");
    isLoading.value = true;
    await courseUseCase.deleteCourses();
    await getTeacherCourses();
    await getStudentCourses();
    isLoading.value = false;
  }

  void enrollUser(String courseId) async {
    final user = authController.currentUser.value;
    if (user == null) {
      Get.snackbar(
        "Error",
        "Debes estar autenticado para inscribirte en un curso",
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF001D3D),
        colorText: Colors.white,
      );
      return;
    }

    logInfo("CourseController: Enroll user ${user.email} in course $courseId");
    await courseUseCase.enrollUser(courseId, user.email);
    await getTeacherCourses();
    await getStudentCourses();
  }

  void unenrollUser(String courseId) async {
    final user = authController.currentUser.value;
    if (user == null) {
      Get.snackbar(
        "Error",
        "Debes estar autenticado para desinscribirte de un curso",
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF001D3D),
        colorText: Colors.white,
      );
      return;
    }

    logInfo(
      "CourseController: Unenroll user ${user.email} from course $courseId",
    );
    await courseUseCase.unenrollUser(courseId, user.email);
    await getTeacherCourses();
    await getStudentCourses();

    Get.snackbar(
      "Desinscrito",
      "Te has desinscrito del curso exitosamente",
      icon: const Icon(Icons.exit_to_app, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFEAA7),
      colorText: Colors.black,
    );
  }

  List<String> getEnrolledUsers(String courseId) {
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
  
  /// Datos de prueba no usa repositorios
  void seedMockIfNeeded(String courseId) {
    if (!_categoriesByCourse.containsKey(courseId)) {
      _categoriesByCourse[courseId] = const [
        Category(id: 'cat-1', courseId: 'any', name: 'Investigación'),
        Category(id: 'cat-2', courseId: 'any', name: 'Prácticas'),
        Category(id: 'cat-3', courseId: 'any', name: 'Proyecto Final'),
      ];
    }

    // Actividades por categoría
    _activitiesByCategory.putIfAbsent('cat-1', () => const [
          Activity(id: 'a-1', categoryId: 'cat-1', name: 'Actividad 1'),
          Activity(id: 'a-2', categoryId: 'cat-1', name: 'Actividad 2'),
        ]);
    _activitiesByCategory.putIfAbsent('cat-2', () => const [
          Activity(id: 'a-3', categoryId: 'cat-2', name: 'Actividad 3'),
          Activity(id: 'a-4', categoryId: 'cat-2', name: 'Actividad 4'),
        ]);
    _activitiesByCategory.putIfAbsent('cat-3', () => const [
          Activity(id: 'a-5', categoryId: 'cat-3', name: 'Actividad 5'),
        ]);

    // Grupo fijo (predefinido)
    _myGroupByCourse[courseId] =
        GroupInfo(id: 'g-3', courseId: courseId, name: 'Grupo #3');

    // Lista de grupos de la clase
    _groupsByCourse[courseId] = [
      GroupInfo(id: 'g-1', courseId: courseId, name: 'Grupo #1'),
      GroupInfo(id: 'g-2', courseId: courseId, name: 'Grupo #2'),
      _myGroupByCourse[courseId]!,
      GroupInfo(id: 'g-4', courseId: courseId, name: 'Grupo #4'),
    ];

    // Miembros por grupo (solo visual)
    _membersByGroup.putIfAbsent('g-1', () => const [
          Member(id: 'u1', name: 'Ana Pérez'),
          Member(id: 'u2', name: 'Luis Gómez'),
        ]);
    _membersByGroup.putIfAbsent('g-2', () => const [
          Member(id: 'u3', name: 'María Rojas'),
          Member(id: 'u4', name: 'Camilo Díaz'),
        ]);
    _membersByGroup.putIfAbsent('g-3', () => const [
          Member(id: 'u5', name: 'Tú'),
          Member(id: 'u6', name: 'Carlos Silva'),
          Member(id: 'u7', name: 'Valeria Mora'),
        ]);
    _membersByGroup.putIfAbsent('g-4', () => const [
          Member(id: 'u8', name: 'Lucía Torres'),
        ]);
  }

  List<Category> getCategoriesForCourse(String courseId) {
    seedMockIfNeeded(courseId);
    return _categoriesByCourse[courseId] ?? const [];
  }

  List<Activity> getActivitiesForCategory(String categoryId) {
    return _activitiesByCategory[categoryId] ?? const [];
  }

  GroupInfo? getMyGroupForCourse(String courseId) {
    seedMockIfNeeded(courseId);
    return _myGroupByCourse[courseId];
  }

  List<GroupInfo> getGroupsForCourse(String courseId) {
    seedMockIfNeeded(courseId);
    return _groupsByCourse[courseId] ?? const [];
  }

  List<Member> getMembersByGroup(String groupId) {
    return _membersByGroup[groupId] ?? const [];
  }

    // 🔹 Curso actualmente seleccionado
  final Rx<Course?> _selectedCourse = Rx<Course?>(null);

  String? get currentCourseId => _selectedCourse.value?.id;

  void setCurrentCourse(Course course) {
    _selectedCourse.value = course;
  }

}


