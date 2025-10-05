import 'dart:convert';
import 'package:f_clean_template/features/groups/data/datasources/local/i_group_source.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart' as domain;
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/i_group_repository.dart';

class LocalGroupRepository implements IGroupRepository {
  final String _storageKey = 'groups';
  final IGroupSource _groupSource;

  LocalGroupRepository(this._groupSource);

  @override
  Future<List<domain.Group>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((g) => domain.Group.fromJson(g)).toList();
    }

    print("📂 Leyendo grupos desde storage:");
    print(jsonString);
    return [];
  }

  @override
  Future<List<domain.Group>> getGroupsByCategory(String categoryId) async {
    final groups = await getGroups();
    return groups.where((g) => g.categoryId == categoryId).toList();
  }

  @override
  Future<domain.Group?> getGroupById(String groupId) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addGroup(domain.Group group) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getGroups();
    groups.add(group);

    final jsonString = json.encode(groups.map((g) => g.toJson()).toList());
    print("📦 Guardando grupos en storage:");
    print(jsonString);
    await prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> updateGroup(domain.Group updatedGroup) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getGroups();

    final index = groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      groups[index] = updatedGroup;
      final jsonString = json.encode(groups.map((g) => g.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    }
  }

  @override
  Future<void> removeGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getGroups();
    groups.removeWhere((g) => g.id == groupId);

    final jsonString = json.encode(groups.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> removeGroupsByCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getGroups();
    groups.removeWhere((g) => g.categoryId == categoryId);

    final jsonString = json.encode(groups.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // ✅ Agregado: creación manual de grupos (modo profesor)
  Future<void> addGroupManual({
    required String categoryId,
    required String name,
    required List<String> memberEmails,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getGroups();

    // Convertir emails a AuthenticationUser
    final members = memberEmails
        .map(
          (email) => AuthenticationUser(
            id: email,
            email: email,
            name: email.split('@')[0],
            password: '',
          ),
        )
        .toList();

    final newGroup = domain.Group(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      number: groups.length + 1,
      categoryId: categoryId,
      name: name,
      members: members,
    );

    groups.add(newGroup);

    final jsonString = json.encode(groups.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}

