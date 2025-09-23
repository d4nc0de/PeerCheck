import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
import 'CategoryListPage.dart';

class AddCategoryPage extends StatefulWidget {
  final String courseId; // <-- Asegúrate de pasar el courseId

  const AddCategoryPage({super.key, required this.courseId});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final nameController = TextEditingController();
  final groupSizeController = TextEditingController();

  String method = "Random";

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Categoría")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la categoría",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: method,
              items: const [
                DropdownMenuItem(value: "Random", child: Text("Random")),
                DropdownMenuItem(
                  value: "Self-assigned",
                  child: Text("Self-assigned"),
                ),
              ],
              onChanged: (value) => setState(() => method = value!),
              decoration: const InputDecoration(
                labelText: "Método de agrupación",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groupSizeController,
              decoration: const InputDecoration(labelText: "Tamaño por grupo"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final groupSize = int.tryParse(groupSizeController.text) ?? 0;

                if (name.isEmpty || groupSize <= 0) {
                  Get.snackbar(
                    'Error',
                    'Debe ingresar nombre y tamaño válido',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                final groupingMethod = method == "Random" ? 2 : 1;

                await controller.addCategory(
                  name: name,
                  courseId: widget.courseId,
                  groupingMethod: groupingMethod,
                  groupSize: groupSize,
                );

                // Navegar a la lista de categorías
                Get.to(() => CategoryListPage(courseId: widget.courseId));
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
