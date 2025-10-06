import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';

class GroupAddPage extends StatefulWidget {
  final String categoryId;
  final String courseId;

  const GroupAddPage({
    super.key,
    required this.categoryId,
    required this.courseId,
  });

  @override
  State<GroupAddPage> createState() => _GroupAddPageState();
}

class _GroupAddPageState extends State<GroupAddPage> {
  final nameController = TextEditingController();
  final selectedMembers = <String>[]; // ✅ Cambiar de RxList a List normal

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final courseController = Get.find<CourseController>();

    final students = courseController.getEnrolledUsers(widget.courseId);

    return Scaffold(
      appBar: AppBar(title: const Text("Crear grupo manualmente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del grupo",
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder( // ✅ Eliminar Obx aquí
                itemCount: students.length,
                itemBuilder: (_, index) {
                  final student = students[index];
                  final isSelected = selectedMembers.contains(student);
                  return ListTile(
                    title: Text(student),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() { // ✅ Usar setState para actualizar la UI
                          if (value == true) {
                            selectedMembers.add(student);
                          } else {
                            selectedMembers.remove(student);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar(
                    "Error",
                    "Debes ingresar un nombre para el grupo",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return;
                }

                await groupController.addGroupManual(
                  categoryId: widget.categoryId,
                  name: nameController.text.trim(),
                  memberEmails: selectedMembers.toList(),
                );
                Get.back();
              },
              child: const Text("Guardar grupo"),
            )
          ],
        ),
      ),
    );
  }
}

