import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';
import 'package:f_clean_template/features/activities/ui/pages/activity_list_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final int categoryIndex;

  const CategoryDetailPage({super.key, required this.categoryIndex});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            "Categoría: ${controller.categories[categoryIndex].name}",
          ),
        ),
        actions: [
    IconButton(
      icon: const Icon(Icons.assignment),
      tooltip: 'Ver actividades',
      onPressed: () {
        final category = controller.categories[categoryIndex];
        Get.to(() => ActivityListPage(
              categoryId: category.id,
              categoryName: category.name,
            ));
      },
    ),
  ],
      ),
      body: Obx(() {
        final Category category = controller.categories[categoryIndex];
        final List<Group> groups = category.groups;

        if (groups.isEmpty) {
          return const Center(child: Text("No hay grupos creados aún"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final students = group.members;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.group),
                title: Text("Grupo ${group.number}"),
                subtitle: Text("Estudiantes: ${students.length}"),
                trailing: students.isEmpty
                    ? null
                    : PopupMenuButton<String>(
                        onSelected: (studentEmail) {
                          // Aquí puedes implementar mover o eliminar estudiante
                        },
                        itemBuilder: (_) => students
                            .map(
                              (s) => PopupMenuItem(
                                value: s.email,
                                child: Text(s.email),
                              ),
                            )
                            .toList(),
                      ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí podrías abrir un diálogo para crear un nuevo grupo si lo deseas
          // O implementar la lógica en el controlador para agregar un grupo vacío
          // Ejemplo:
          // controller.addEmptyGroupToCategory(categoryIndex);
        },
        child: const Icon(Icons.group_add),
        tooltip: "Agregar grupo",
      ),
    );
  }
}
