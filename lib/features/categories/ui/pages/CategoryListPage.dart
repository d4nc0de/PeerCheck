import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/categories/ui/controller/category_controller.dart';
import 'add_category_page.dart';
import 'CategoryEditPage.dart';

class CategoryListPage extends StatelessWidget {
  final String courseId;
  final CategoryController controller = Get.find<CategoryController>();

  CategoryListPage({super.key, required this.courseId}) {
    controller.loadCategories(courseId);
  }

  String _methodText(String method) {
    switch (method) {
      case "1":
        return "Autoasignación";
      case "2":
        return "Aleatorio";
      default:
        return "Desconocido";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categorías")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categories.isEmpty) {
          return const Center(child: Text("No hay categorías creadas"));
        }

        return ListView.builder(
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(category.name),
                subtitle: Text(
                  "Método: ${_methodText(category.method)} | Grupos: ${category.groupSize}",
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => Get.to(() => CategoryEditPage(
                      category: category,
                      courseId: courseId,
                    )),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await Get.to(() => AddCategoryPage(courseId: courseId));
          controller.loadCategories(courseId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


