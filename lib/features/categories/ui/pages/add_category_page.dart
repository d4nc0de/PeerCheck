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
              onPressed: () {
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

                // Aquí deberías pasar la lista de estudiantes del curso
                final students = <String>[]; // <-- Reemplaza con tu lista real

                // Crear categoría y generar grupos automáticamente
                controller.createCategoryWithGroups(
                  name: name,
                  method: method,
                  groupSize: groupSize,
                  students: students,
                );

                // Navegar a la lista de categorías
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
