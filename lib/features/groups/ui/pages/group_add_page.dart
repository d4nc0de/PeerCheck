import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';

class GroupAddPage extends StatefulWidget {
  final String categoryId;
  const GroupAddPage({super.key, required this.categoryId});

  @override
  State<GroupAddPage> createState() => _GroupAddPageState();
}

class _GroupAddPageState extends State<GroupAddPage> {
  final nameController = TextEditingController();
  final selectedMembers = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final courseController = Get.find<CourseController>();

    // Obtenemos lista de usuarios del curso actual
    final courseId = courseController.currentCourseId;
    final students = courseController.getEnrolledUsers(courseId!);

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
              child: Obx(() => ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, index) {
                      final student = students[index];
                      final isSelected = selectedMembers.contains(student);
                      return ListTile(
                        title: Text(student),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            if (value == true) {
                              selectedMembers.add(student);
                            } else {
                              selectedMembers.remove(student);
                            }
                          },
                        ),
                      );
                    },
                  )),
            ),
            ElevatedButton(
              onPressed: () async {
                await groupController.addGroupManual(
                  categoryId: widget.categoryId,
                  name: nameController.text,
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
