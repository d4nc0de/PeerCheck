
import 'package:f_clean_template/features/groups/domain/models/group.dart';

abstract class IGroupRepository {
  Future<List<Group>> getGroups();
  Future<List<Group>> getGroupsByCategory(String categoryId);
  Future<Group?> getGroupById(String groupId);
  Future<void> addGroup(Group group);
  Future<void> updateGroup(Group updatedGroup);
  Future<void> removeGroup(String groupId);
  Future<void> removeGroupsByCategory(String categoryId);
}