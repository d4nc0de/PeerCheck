import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/categories/ui/controller/category_controller.dart';

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
            "Categoría: ${controller.categories[categoryIndex]["name"]}",
          ),
        ),
      ),
      body: Obx(() {
        final category = controller.categories[categoryIndex];
        final List groups = category["groups"];

        if (groups.isEmpty) {
          return const Center(child: Text("No hay grupos creados aún"));
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final students = group["students"] as List;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.group),
                title: Text(group["name"]),
                subtitle: Text("Estudiantes: ${students.length}"),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentCategory = controller.categories[categoryIndex];
          final newGroupIndex = (currentCategory["groups"] as List).length + 1;

          controller.addGroup(categoryIndex, {
            "name": "Grupo $newGroupIndex",
            "students": [],
          });
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
