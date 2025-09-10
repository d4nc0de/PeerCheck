import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
import 'add_category_page.dart';
import 'CategoryDetailPage.dart';


class CategoryListPage extends StatelessWidget {
  final CategoryController controller = Get.find<CategoryController>();

  CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categorías")),
      body: Obx(() {
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
                title: Text(category["name"]),
                subtitle: Text("Método: ${category["method"]}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // 👇 solo pasamos el índice, no todo el mapa
                  Get.to(() => CategoryDetailPage(categoryIndex: index));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AddCategoryPage());
          if (result != null) {
            controller.addCategory(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
