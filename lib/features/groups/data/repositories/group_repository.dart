import 'dart:math';
import 'package:f_clean_template/features/groups/data/datasources/remote/remote_group_source.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart' as domain;
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import '../../domain/repositories/i_group_repository.dart';

/// Implementación REMOTA de IGroupRepository
class RemoteGroupRepository implements IGroupRepository {
  final RemoteGroupSource _src;

  RemoteGroupRepository(this._src);

  @override
  Future<List<domain.Group>> getGroups() async {
    // No se usa globalmente en UI; si lo necesitas, agréga un read sin filtro
    return [];
  }

  @override
  Future<List<domain.Group>> getGroupsByCategory(String categoryId) async {
    final rows = await _src.readGroupsByCategory(categoryId);
    return rows.map((r) {
      final id = r['_id'] as String;
      final number = (r['Quantity'] is num) ? (r['Quantity'] as num).toInt() : 0;
      return domain.Group(
        id: id,
        number: number,
        categoryId: categoryId,
        name: 'Grupo $number',
        members: const <AuthenticationUser>[], // si quieres, carga Rel y completa
      );
    }).toList();
  }

  @override
  Future<domain.Group?> getGroupById(String groupId) async {
    // opcional, no usado actualmente
    return null;
  }

  @override
  Future<void> addGroup(domain.Group group) async {
    // Mantén la vía manual como base
    await addGroupManual(
      categoryId: group.categoryId,
      name: group.name,
      memberEmails: group.members.map((m) => m.email).toList(),
    );
  }

  @override
  Future<void> updateGroup(domain.Group updatedGroup) async {
    // No requerido por ahora
    return;
  }

  @override
  Future<void> removeGroup(String groupId) async {
    await _src.deleteMembersByGroup(groupId);
    await _src.deleteGroupById(groupId);
  }

  @override
  Future<void> removeGroupsByCategory(String categoryId) async {
    final groups = await getGroupsByCategory(categoryId);
    for (final g in groups) {
      await _src.deleteMembersByGroup(g.id);
    }
    await _src.deleteGroupsByCategory(categoryId);
  }

  // ✅ creación manual (y base para aleatorio cuando se pasa members)
  Future<void> addGroupManual({
    required String categoryId,
    required String? name,
    required List<String> memberEmails,
  }) async {
    final existing = await getGroupsByCategory(categoryId);
    final nextNumber = (existing.isEmpty)
        ? 1
        : (existing.map((g) => g.number).reduce(max) + 1);

    final groupId = await _src.insertGroup(
      categoryId: categoryId,
      number: nextNumber,
      isRandomGroup: false,
    );

    if (memberEmails.isNotEmpty) {
      await _src.insertMembersBatch(
        groupId: groupId,
        studentIdsOrEmails: memberEmails,
      );
    }
  }
}
