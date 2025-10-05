import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';
import 'package:f_clean_template/features/groups/ui/pages/group_add_page.dart';
import 'package:f_clean_template/features/groups/ui/pages/group_auto_assign_page.dart';

class GroupAdminListPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final int groupSize;

  const GroupAdminListPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.groupSize,
  });

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos de $categoryName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Crear grupo manualmente",
            onPressed: () {
              Get.to(() => GroupAddPage(categoryId: categoryId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            tooltip: "Generar grupos automáticamente",
            onPressed: () {
              Get.to(() => GroupAutoAssignPage(
                    categoryId: categoryId,
                    groupSize: groupSize,
                  ));
            },
          ),
        ],
      ),
      body: Obx(() {
        final groups = groupController.groups;
        if (groups.isEmpty) {
          return const Center(child: Text("No hay grupos creados aún."));
        }
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Card(
              child: ListTile(
                title: Text(group.name!),
                subtitle: Text("${group.members.length} miembros"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    groupController.removeGroup(groupId: group.id!, categoryId: categoryId);
                  },
                ),
                onTap: () {
                  _showGroupDetails(context, group);
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _showGroupDetails(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(group.name!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: group.members
              .map((m) => ListTile(title: Text(m.name ?? "Sin nombre")))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }
}
