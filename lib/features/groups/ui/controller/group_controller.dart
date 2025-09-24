import 'package:f_clean_template/features/groups/domain/use_case/group_usecase.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';

class GroupController extends GetxController {
  final GroupUseCase _groupUseCase;

  GroupController(this._groupUseCase);

  // Estado observable
  final RxList<Group> _groups = <Group>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _selectedCategoryId = ''.obs;

  // Getters
  List<Group> get groups => _groups;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get selectedCategoryId => _selectedCategoryId.value;

  // Getters computados
  List<Group> get groupsForSelectedCategory => 
      _groups.where((group) => group.categoryId == _selectedCategoryId.value).toList();

  int get totalGroupsInCategory => groupsForSelectedCategory.length;
  int get totalMembersInCategory => 
      groupsForSelectedCategory.fold<int>(0, (sum, group) => sum + group.members.length);

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  // -------------------- CRUD Operations --------------------

  Future<void> loadGroups() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      final groups = await _groupUseCase.getGroups();
      _groups.assignAll(groups);
    } catch (e) {
      _errorMessage.value = 'Error al cargar grupos: ${e.toString()}';
      print('Error loading groups: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadGroupsByCategory(String categoryId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _selectedCategoryId.value = categoryId;
      
      final groups = await _groupUseCase.getGroupsByCategory(categoryId);
      _groups.assignAll(groups);
    } catch (e) {
      _errorMessage.value = 'Error al cargar grupos por categoría: ${e.toString()}';
      print('Error loading groups by category: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createGroup({
    required String categoryId,
    required int number,
    List<AuthenticationUser>? members,
  }) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.addGroup(
        categoryId: categoryId,
        number: number,
        members: members,
      );
      
      await loadGroupsByCategory(categoryId);
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al crear grupo: ${e.toString()}';
      print('Error creating group: $e');
      return false;
    }
  }

  Future<bool> updateGroup(Group group) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.updateGroup(group);
      await loadGroupsByCategory(group.categoryId);
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al actualizar grupo: ${e.toString()}';
      print('Error updating group: $e');
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      _errorMessage.value = '';
      
      // Obtener el grupo para saber la categoría
      final group = await _groupUseCase.getGroupById(groupId);
      if (group == null) {
        throw Exception('Grupo no encontrado');
      }
      
      await _groupUseCase.removeGroup(groupId);
      await loadGroupsByCategory(group.categoryId);
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al eliminar grupo: ${e.toString()}';
      print('Error deleting group: $e');
      return false;
    }
  }

  Future<bool> deleteGroupsByCategory(String categoryId) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.removeGroupsByCategory(categoryId);
      await loadGroups();
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al eliminar grupos por categoría: ${e.toString()}';
      print('Error deleting groups by category: $e');
      return false;
    }
  }

  // -------------------- Member Management --------------------

  Future<bool> addMemberToGroup({
    required String groupId,
    required String studentEmail,
  }) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.addMemberToGroup(
        groupId: groupId,
        studentEmail: studentEmail,
      );
      
      // Recargar grupos de la categoría actual
      if (_selectedCategoryId.value.isNotEmpty) {
        await loadGroupsByCategory(_selectedCategoryId.value);
      } else {
        await loadGroups();
      }
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al agregar miembro: ${e.toString()}';
      print('Error adding member: $e');
      return false;
    }
  }

  Future<bool> removeMemberFromGroup({
    required String groupId,
    required String studentEmail,
  }) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.removeMemberFromGroup(
        groupId: groupId,
        studentEmail: studentEmail,
      );
      
      // Recargar grupos de la categoría actual
      if (_selectedCategoryId.value.isNotEmpty) {
        await loadGroupsByCategory(_selectedCategoryId.value);
      } else {
        await loadGroups();
      }
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al remover miembro: ${e.toString()}';
      print('Error removing member: $e');
      return false;
    }
  }

  Future<bool> transferMember({
    required String fromGroupId,
    required String toGroupId,
    required String studentEmail,
  }) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.transferMemberBetweenGroups(
        fromGroupId: fromGroupId,
        toGroupId: toGroupId,
        studentEmail: studentEmail,
      );
      
      // Recargar grupos de la categoría actual
      if (_selectedCategoryId.value.isNotEmpty) {
        await loadGroupsByCategory(_selectedCategoryId.value);
      } else {
        await loadGroups();
      }
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al transferir miembro: ${e.toString()}';
      print('Error transferring member: $e');
      return false;
    }
  }

  // -------------------- Bulk Operations --------------------

  Future<bool> createEmptyGroups({
    required String categoryId,
    required int totalGroups,
  }) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.createEmptyGroups(
        categoryId: categoryId,
        totalGroups: totalGroups,
      );
      
      await loadGroupsByCategory(categoryId);
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al crear grupos vacíos: ${e.toString()}';
      print('Error creating empty groups: $e');
      return false;
    }
  }

  Future<bool> createRandomGroups({
    required String categoryId,
    required List<AuthenticationUser> students,
    required int groupSize,
  }) async {
    try {
      _errorMessage.value = '';
      
      await _groupUseCase.createRandomGroups(
        categoryId: categoryId,
        students: students,
        groupSize: groupSize,
      );
      
      await loadGroupsByCategory(categoryId);
      return true;
    } catch (e) {
      _errorMessage.value = 'Error al crear grupos aleatorios: ${e.toString()}';
      print('Error creating random groups: $e');
      return false;
    }
  }

  // -------------------- Utility Methods --------------------

  Group? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  List<Group> getGroupsWithMembers() {
    return _groups.where((group) => group.members.isNotEmpty).toList();
  }

  List<Group> getEmptyGroups() {
    return _groups.where((group) => group.members.isEmpty).toList();
  }

  Group? getStudentGroup(String studentEmail) {
    try {
      return groupsForSelectedCategory.firstWhere(
        (group) => group.members.any((member) => member.email == studentEmail)
      );
    } catch (e) {
      return null;
    }
  }

  bool isStudentInAnyGroup(String studentEmail) {
    return groupsForSelectedCategory.any(
      (group) => group.members.any((member) => member.email == studentEmail)
    );
  }

  int getAvailableGroupNumber(String categoryId) {
    final categoryGroups = _groups.where((g) => g.categoryId == categoryId).toList();
    if (categoryGroups.isEmpty) return 1;
    
    final usedNumbers = categoryGroups.map((g) => g.number).toList()..sort();
    
    // Buscar el primer número disponible
    for (int i = 1; i <= usedNumbers.length + 1; i++) {
      if (!usedNumbers.contains(i)) {
        return i;
      }
    }
    
    return usedNumbers.length + 1;
  }

  // -------------------- Clear Methods --------------------

  void clearError() {
    _errorMessage.value = '';
  }

  void clearGroups() {
    _groups.clear();
  }

  void setSelectedCategory(String categoryId) {
    _selectedCategoryId.value = categoryId;
  }
}