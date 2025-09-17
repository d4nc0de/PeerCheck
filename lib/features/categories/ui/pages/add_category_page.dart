import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/category_controller.dart';
import 'CategoryListPage.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final nameController = TextEditingController();
  final groupSizeController = TextEditingController();

  String method = "Random";

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                final newCategory = {
                  "name": nameController.text.trim(),
                  "method": method,
                  "groupSize": int.tryParse(groupSizeController.text) ?? 0,
                  "groups": [],
                };

                final controller = Get.find<CategoryController>();
                controller.addCategory(newCategory);

                // ✅ Navegar a la lista de categorías (y eliminar esta del stack)
                Get.to(() => CategoryListPage());
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
