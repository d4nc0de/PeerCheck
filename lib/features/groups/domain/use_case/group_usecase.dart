import 'dart:math';
import 'dart:math' as math;
import 'package:f_clean_template/features/groups/data/repositories/group_repository.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';

class GroupUseCase {
  final RemoteGroupRepository groupRepository;
  final CourseController courseController = Get.find();
  final AuthenticationController authController = Get.find();

  GroupUseCase({
    required this.groupRepository,
  });

  // -------------------- CRUD Grupos --------------------
  
  Future<List<Group>> getGroups() async {
    return await groupRepository.getGroups();
  }

  Future<List<Group>> getGroupsByCategory(String categoryId) async {
    return await groupRepository.getGroupsByCategory(categoryId);
  }

  Future<Group?> getGroupById(String groupId) async {
    return await groupRepository.getGroupById(groupId);
  }

    /// 🔹 Crear un grupo manualmente (nombre + lista de correos)
  Future<void> addGroupManual({
    required String categoryId,
    required String name,
    required List<String> memberEmails,
  }) async {
    await groupRepository.addGroupManual(
      categoryId: categoryId,
      name: name,
      memberEmails: memberEmails,
    );
  }


  Future<void> addGroup({
    required String categoryId,
    required int number,
    List<AuthenticationUser>? members,
  }) async {
    final newGroup = Group(
      id: "group_${DateTime.now().millisecondsSinceEpoch}_$number",
      number: number,
      categoryId: categoryId,
      members: members ?? [],
    );

    await groupRepository.addGroup(newGroup);
  }

  Future<void> updateGroup(Group group) async {
    await groupRepository.updateGroup(group);
  }

  Future<void> removeGroup(String groupId) async {
    await groupRepository.removeGroup(groupId);
  }

  Future<void> removeGroupsByCategory(String categoryId) async {
    await groupRepository.removeGroupsByCategory(categoryId);
  }

  // -------------------- Gestión de Miembros --------------------

  /// Agrega un miembro a un grupo específico
  Future<void> addMemberToGroup({
    required String groupId,
    required String studentEmail,
  }) async {
    final group = await groupRepository.getGroupById(groupId);
    
    if (group == null) {
      throw Exception('Grupo no encontrado');
    }

    // Verificar si el estudiante ya está en el grupo
    if (group.members.any((member) => member.email == studentEmail)) {
      throw Exception('El estudiante ya está en este grupo');
    }

    // Crear el estudiante
    final student = AuthenticationUser(
      id: studentEmail,
      email: studentEmail,
      name: _extractNameFromEmail(studentEmail), 
      password: '',
    );

    // Agregar el miembro
    final updatedMembers = [...group.members, student];
    final updatedGroup = group.copyWith(members: updatedMembers);
    
    await groupRepository.updateGroup(updatedGroup);
  }

  /// Remueve un miembro de un grupo específico
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String studentEmail,
  }) async {
    final group = await groupRepository.getGroupById(groupId);
    
    if (group == null) {
      throw Exception('Grupo no encontrado');
    }

    // Verificar si el estudiante está en el grupo
    if (!group.members.any((member) => member.email == studentEmail)) {
      throw Exception('El estudiante no está en este grupo');
    }

    // Remover el miembro
    final updatedMembers = group.members
        .where((member) => member.email != studentEmail)
        .toList();
    final updatedGroup = group.copyWith(members: updatedMembers);
    
    await groupRepository.updateGroup(updatedGroup);
  }

  /// Transfiere un estudiante de un grupo a otro (dentro de la misma categoría)
  Future<void> transferMemberBetweenGroups({
    required String fromGroupId,
    required String toGroupId,
    required String studentEmail,
  }) async {
    // Obtener ambos grupos
    final fromGroup = await groupRepository.getGroupById(fromGroupId);
    final toGroup = await groupRepository.getGroupById(toGroupId);

    if (fromGroup == null || toGroup == null) {
      throw Exception('Uno o ambos grupos no encontrados');
    }

    // Verificar que ambos grupos pertenezcan a la misma categoría
    if (fromGroup.categoryId != toGroup.categoryId) {
      throw Exception('Los grupos deben pertenecer a la misma categoría');
    }

    // Verificar que el estudiante está en el grupo origen
    final student = fromGroup.members
        .where((member) => member.email == studentEmail)
        .firstOrNull;

    if (student == null) {
      throw Exception('El estudiante no está en el grupo origen');
    }

    // Verificar que el estudiante no está ya en el grupo destino
    if (toGroup.members.any((member) => member.email == studentEmail)) {
      throw Exception('El estudiante ya está en el grupo destino');
    }

    // Remover del grupo origen
    final updatedFromMembers = fromGroup.members
        .where((member) => member.email != studentEmail)
        .toList();
    final updatedFromGroup = fromGroup.copyWith(members: updatedFromMembers);

    // Agregar al grupo destino
    final updatedToMembers = [...toGroup.members, student];
    final updatedToGroup = toGroup.copyWith(members: updatedToMembers);

    // Actualizar ambos grupos
    await groupRepository.updateGroup(updatedFromGroup);
    await groupRepository.updateGroup(updatedToGroup);
  }

  // -------------------- Creación masiva de grupos --------------------

  /// Crea grupos vacíos para autoasignación
  Future<void> createEmptyGroups({
    required String categoryId,
    required int totalGroups,
  }) async {
    for (int i = 1; i <= totalGroups; i++) {
      await addGroup(
        categoryId: categoryId,
        number: i,
        members: [],
      );
    }
  }

  /// Crea grupos con distribución aleatoria de estudiantes
  Future<void> createRandomGroups({
    required String categoryId,
    required List<AuthenticationUser> students,
    required int groupSize,
  }) async {
    final groups = _createRandomGroups(students, groupSize);
    
    for (int i = 0; i < groups.length; i++) {
      await addGroup(
        categoryId: categoryId,
        number: i + 1,
        members: groups[i],
      );
    }
  }

  // -------------------- Métodos auxiliares --------------------

  List<List<AuthenticationUser>> _createRandomGroups(
      List<AuthenticationUser> students, int groupSize) {
    final List<List<AuthenticationUser>> groups = [];
    final random = Random();
    final pool = List<AuthenticationUser>.from(students)..shuffle(random);

    while (pool.isNotEmpty) {
      final membersCount = math.min(groupSize, pool.length);
      final members = pool.take(membersCount).toList();
      pool.removeRange(0, membersCount);
      groups.add(members);
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

  // -------------------- Consultas específicas --------------------

  /// Obtiene todos los grupos de un curso específico
  Future<List<Group>> getGroupsByCourse(String courseId) async {
    final allGroups = await getGroups();
    final enrolledEmails = courseController.getEnrolledUsers(courseId).toSet();
    
    return allGroups
        .where((group) => 
            group.members.any((member) => enrolledEmails.contains(member.email)))
        .toList();
  }

  /// Obtiene el grupo al que pertenece un estudiante específico en una categoría
  Future<Group?> getStudentGroupInCategory({
    required String categoryId,
    required String studentEmail,
  }) async {
    final groups = await getGroupsByCategory(categoryId);
    
    try {
      return groups.firstWhere(
        (group) => group.members.any((member) => member.email == studentEmail)
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene estadísticas de grupos por categoría
  Future<Map<String, dynamic>> getGroupStatsByCategory(String categoryId) async {
    final groups = await getGroupsByCategory(categoryId);
    
    final totalGroups = groups.length;
    final totalMembers = groups.fold<int>(0, (sum, group) => sum + group.members.length);
    final averageMembersPerGroup = totalGroups > 0 ? totalMembers / totalGroups : 0.0;
    final groupsWithMembers = groups.where((group) => group.members.isNotEmpty).length;
    final emptyGroups = totalGroups - groupsWithMembers;

    return {
      'totalGroups': totalGroups,
      'totalMembers': totalMembers,
      'averageMembersPerGroup': averageMembersPerGroup,
      'groupsWithMembers': groupsWithMembers,
      'emptyGroups': emptyGroups,
    };
  }
}