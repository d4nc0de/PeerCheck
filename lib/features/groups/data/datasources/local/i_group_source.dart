import 'package:f_clean_template/features/groups/domain/models/group.dart';

abstract class IGroupSource {
  Future<List<Group>> getGroups();
  Future<void> addGroup(Group group);
  Future<void> updateGroup(Group updatedGroup);
  Future<void> removeGroup(String groupId);
}