import 'dart:math';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:f_clean_template/features/categories/data/repositories/category_repository.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/domain/models/group.dart';

class CategoryUseCase {
  final LocalCategoryRepository categoryRepository;
  final CourseController courseController = Get.find();
  final AuthenticationController authController = Get.find();

  CategoryUseCase({
    required this.categoryRepository,
  });

  // -------------------- CRUD Categorías --------------------
  
  Future<List<Category>> getCategories() async {
    return await categoryRepository.getCategories();

  }

  Future<void> addCategory({
    required String name,
    required String courseId,
    required int groupingMethod, // 1 = auto, 2 = aleatorio
    required int groupSize,
  }) async {
    // Obtener usuarios inscritos usando el método del CourseController
    final enrolledEmails = courseController.getEnrolledUsers(courseId);
    
    if (enrolledEmails.isEmpty) {
      throw Exception('No hay estudiantes inscritos en el curso');
    }

    // Convertir emails a objetos AuthenticationUser simples
    final students = enrolledEmails.map((email) => 
      AuthenticationUser(
        id: email,
        email: email,
        name: _extractNameFromEmail(email), password: '',
      )
    ).toList();

    // Crear los grupos según el groupingMethod
    final groups = <Group>[];

    //if (groupingMethod == 1) {
      // Autoasignación: se crean grupos vacíos
     // final totalGroups = (students.length / groupSize).ceil();
     // for (int i = 0; i < totalGroups; i++) {
      //  groups.add(_createGroup(i + 1, []));
    //  }
   // } else if (groupingMethod == 2) {
      // Aleatorio: se crean grupos y se asignan estudiantes
    //  groups.addAll(_createRandomGroups(students, groupSize));
    //}

    final newCategory = Category(
      id: "cat_${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      groups: groups,
      activities: [],
      evaluations: [],
      groupingMethod: groupingMethod,
      courseId: courseId
    );

    await categoryRepository.addCategory(newCategory);
  }

  Future<void> updateCategory(Category category) async {
    await categoryRepository.updateCategory(category);
  }

  Future<void> removeCategory(String categoryId) async {
    await categoryRepository.removeCategory(categoryId);
  }

  // -------------------- Lógica de grupos --------------------

  Group _createGroup(int number, List<AuthenticationUser> members) {
    return Group(
      number: number, 
      members: members, 
      id: 'group_${DateTime.now().millisecondsSinceEpoch}_$number'
    );
  }

  List<Group> _createRandomGroups(List<AuthenticationUser> students, int groupSize) {
    final List<Group> groups = [];
    final random = Random();
    final pool = List<AuthenticationUser>.from(students)..shuffle(random);

    int groupNumber = 1;
    while (pool.isNotEmpty) {
      final membersCount = math.min(groupSize, pool.length);
      final members = pool.take(membersCount).toList();
      pool.removeRange(0, membersCount);
      groups.add(_createGroup(groupNumber, members));
      groupNumber++;
    }

    return groups;
  }

  /// Extrae un nombre del email para crear usuarios
  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isEmpty) return email;
    
    final username = parts[0];
    return username
        .replaceAll(RegExp(r'[._-]'), ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' 
            : word)
        .join(' ');
  }

  // -------------------- Categorías y Grupos por Curso --------------------

  Future<List<Category>> getCategoriesWithGroupsByCourse(String courseId) async {
    final allCategories = await categoryRepository.getCategories();
    return allCategories.where((c) => c.courseId == courseId).toList();
  }

  /// Obtiene los grupos de todas las categorías que tienen miembros inscritos en el curso dado
  Future<Map<Category, List<Group>>> getGroupsByCourse(String courseId) async {
    final allCategories = await categoryRepository.getCategories();
    final enrolledEmails = courseController.getEnrolledUsers(courseId).toSet();
    final Map<Category, List<Group>> result = {};

    for (final category in allCategories) {
      final groupsInCourse = category.groups
          .where((group) => group.members.any((u) => enrolledEmails.contains(u.email)))
          .toList();

      if (groupsInCourse.isNotEmpty) {
        result[category] = groupsInCourse;
      }
    }

    return result;
  }

  /// Obtiene los miembros de cada grupo que están inscritos en el curso dado
  Future<Map<Group, List<AuthenticationUser>>> getMembersByCourse(String courseId) async {
    final groupsByCategory = await getGroupsByCourse(courseId);
    final enrolledEmails = courseController.getEnrolledUsers(courseId).toSet();
    final Map<Group, List<AuthenticationUser>> result = {};

    groupsByCategory.forEach((category, groups) {
      for (final group in groups) {
        final membersInCourse =
            group.members.where((u) => enrolledEmails.contains(u.email)).toList();
        if (membersInCourse.isNotEmpty) {
          result[group] = membersInCourse;
        }
      }
    });

    return result;
  }

  /// Asigna un estudiante a un grupo específico (para autoasignación)
  Future<void> assignStudentToGroup({
    required String categoryId,
    required int groupNumber,
    required String studentEmail,
  }) async {
    final categories = await categoryRepository.getCategories();
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    
    if (categoryIndex == -1) {
      throw Exception('Categoría no encontrada');
    }

    final category = categories[categoryIndex];
    final groupIndex = category.groups.indexWhere((g) => g.number == groupNumber);
    
    if (groupIndex == -1) {
      throw Exception('Grupo no encontrado');
    }

    // Crear el estudiante
    final student = AuthenticationUser(
      id: studentEmail,
      email: studentEmail,
      name: _extractNameFromEmail(studentEmail), password: '',
    );

    // Verificar si ya está en otro grupo de la misma categoría
    for (int i = 0; i < category.groups.length; i++) {
      final existingGroup = category.groups[i];
      if (existingGroup.members.any((m) => m.email == studentEmail)) {
        if (i != groupIndex) {
          // Remover del grupo actual
          existingGroup.members.removeWhere((m) => m.email == studentEmail);
        } else {
          // Ya está en este grupo
          return;
        }
      }
    }

    // Agregar al nuevo grupo
    category.groups[groupIndex].members.add(student);
    
    await categoryRepository.updateCategory(category);
  }
}