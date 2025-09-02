import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';

class CourseEnrollmentPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  const CourseEnrollmentPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text('Estudiantes inscritos - $courseName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de estudiantes inscritos:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final enrolledUsers = courseController.getEnrolledUsers(
                  courseId,
                );

                if (enrolledUsers.isEmpty) {
                  return const Center(
                    child: Text('No hay estudiantes inscritos en este curso'),
                  );
                }

                return ListView.builder(
                  itemCount: enrolledUsers.length,
                  itemBuilder: (context, index) {
                    final userEmail = enrolledUsers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(userEmail),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            courseController.unenrollUser(courseId, userEmail);
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // Aquí se puede implementar la funcionalidad para invitar estudiantes
                      Get.snackbar(
                        'Próximamente',
                        'Función de invitación estará disponible pronto',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Text('Invitar Estudiantes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
