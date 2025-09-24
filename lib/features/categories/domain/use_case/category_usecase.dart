import 'dart:math' as math;
import 'package:f_clean_template/features/groups/domain/use_case/group_usecase.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:f_clean_template/features/categories/data/repositories/category_repository.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';



class CategoryUseCase {
  final LocalCategoryRepository categoryRepository;
  final GroupUseCase groupUseCase; // ✅ Inyección por constructor
  final CourseController courseController = Get.find();
  final AuthenticationController authController = Get.find();

  CategoryUseCase({
    required this.categoryRepository,
    required this.groupUseCase, // ✅ Requerido en constructor
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
        name: _extractNameFromEmail(email), 
        password: '',
      )
    ).toList();

    // Crear la categoría primero
    final categoryId = "cat_${DateTime.now().millisecondsSinceEpoch}";
    
    final newCategory = Category(
      id: categoryId,
      name: name,
      groups: [], // Los grupos se crearán por separado
      activities: [],
      evaluations: [],
      groupingMethod: groupingMethod,
      courseId: courseId
    );

    // Guardar la categoría
    await categoryRepository.addCategory(newCategory);

    // Crear los grupos usando GroupUseCase
    if (groupingMethod == 1) {
      // Autoasignación: se crean grupos vacíos
      final totalGroups = (students.length / groupSize).ceil();
      await groupUseCase.createEmptyGroups(
        categoryId: categoryId,
        totalGroups: totalGroups,
      );
    } else if (groupingMethod == 2) {
      // Aleatorio: se crean grupos y se asignan estudiantes
      await groupUseCase.createRandomGroups(
        categoryId: categoryId,
        students: students,
        groupSize: groupSize,
      );
    }
  }

  Future<void> updateCategory(Category category) async {
    await categoryRepository.updateCategory(category);
  }

  Future<void> removeCategory(String categoryId) async {
    // Primero eliminar todos los grupos de esta categoría
    await groupUseCase.removeGroupsByCategory(categoryId);
    
    // Luego eliminar la categoría
    await categoryRepository.removeCategory(categoryId);
  }

  // -------------------- Métodos auxiliares --------------------

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

  /// Obtiene los grupos de todas las categorías de un curso
  Future<Map<Category, List<Group>>> getGroupsByCourse(String courseId) async {
    final allCategories = await getCategoriesWithGroupsByCourse(courseId);
    final Map<Category, List<Group>> result = {};

    for (final category in allCategories) {
      // Obtener grupos usando GroupUseCase
      final groups = await groupUseCase.getGroupsByCategory(category.id);
      if (groups.isNotEmpty) {
        result[category] = groups;
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
    // Obtener todos los grupos de la categoría
    final groups = await groupUseCase.getGroupsByCategory(categoryId);
    
    // Encontrar el grupo por número
    final targetGroup = groups.where((g) => g.number == groupNumber).firstOrNull;
    if (targetGroup == null) {
      throw Exception('Grupo no encontrado');
    }

    // Verificar si ya está en otro grupo de la misma categoría
    for (final group in groups) {
      if (group.members.any((m) => m.email == studentEmail)) {
        if (group.id != targetGroup.id) {
          // Remover del grupo actual
          await groupUseCase.removeMemberFromGroup(
            groupId: group.id,
            studentEmail: studentEmail,
          );
        } else {
          // Ya está en este grupo
          return;
        }
      }
    }

    // Agregar al nuevo grupo
    await groupUseCase.addMemberToGroup(
      groupId: targetGroup.id,
      studentEmail: studentEmail,
    );
  }
}