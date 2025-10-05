import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';

class GroupAutoAssignPage extends StatelessWidget {
  final String categoryId;
  final int groupSize;

  const GroupAutoAssignPage({
    super.key,
    required this.categoryId,
    required this.groupSize,
  });

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final groupController = Get.find<GroupController>();
    final courseId = courseController.currentCourseId;
    final students = courseController.getEnrolledUsers(courseId!);

    return Scaffold(
      appBar: AppBar(title: const Text("Generar grupos automáticamente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Se crearán grupos aleatorios con $groupSize integrantes cada uno.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generar grupos"),
              onPressed: () async {
                final random = Random();
                final shuffled = [...students]..shuffle(random);
                int groupCount = (students.length / groupSize).ceil();

                for (int i = 0; i < groupCount; i++) {
                  final groupMembers = shuffled.skip(i * groupSize).take(groupSize).toList();
                  await groupController.addGroupManual(
                    categoryId: categoryId,
                    name: "Grupo ${i + 1}",
                    memberEmails: groupMembers,
                  );
                }

                Get.snackbar("Éxito", "Grupos generados automáticamente.");
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }
}
