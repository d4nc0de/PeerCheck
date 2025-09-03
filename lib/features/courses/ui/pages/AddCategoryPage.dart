import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  var categories = <String>[].obs;

  void addCategory(String name) {
    if (name.isNotEmpty) {
      categories.add(name);
    }
  }

  void deleteCategory(int index) {
    categories.removeAt(index);
  }

  void editCategory(int index, String newName) {
    if (newName.isNotEmpty) {
      categories[index] = newName;
      categories.refresh();
    }
  }
}

class AddCategoryPage extends StatelessWidget {
  const AddCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController = Get.put(CategoryController());
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Categorías"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input para nueva categoría
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: "Nombre de categoría",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    categoryController.addCategory(textController.text);
                    textController.clear();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (categoryController.categories.isEmpty) {
                  return const Center(
                    child: Text("No hay categorías registradas"),
                  );
                }

                return ListView.builder(
                  itemCount: categoryController.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryController.categories[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  categoryController,
                                  index,
                                  category,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                categoryController.deleteCategory(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    CategoryController controller,
    int index,
    String oldValue,
  ) {
    final TextEditingController editController =
        TextEditingController(text: oldValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar categoría"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: "Nuevo nombre",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.editCategory(index, editController.text);
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
