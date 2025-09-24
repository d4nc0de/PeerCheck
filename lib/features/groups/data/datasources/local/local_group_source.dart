import 'dart:convert';
import 'package:f_clean_template/features/groups/data/datasources/local/i_group_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';

class LocalGroupSource implements IGroupSource {
  final String _storageKey = 'groups';

  @override
  Future<List<Group>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((g) => Group.fromJson(g)).toList();
    }
    return [];
  }

  @override
  Future<void> addGroup(Group group) async {
    final prefs = await SharedPreferences.getInstance();
    final groups = await getGroups();
    groups.add(group);

    final jsonString = json.encode(groups.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> updateGroup(Group updatedGroup) async {
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
}