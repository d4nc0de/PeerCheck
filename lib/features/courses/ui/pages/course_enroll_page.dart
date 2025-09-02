import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';
import '../../domain/models/course.dart';
import 'package:f_clean_template/core/app_theme.dart';

class CourseEnrollPage extends StatefulWidget {
  const CourseEnrollPage({super.key});

  @override
  State<CourseEnrollPage> createState() => _CourseEnrollPageState();
}

class _CourseEnrollPageState extends State<CourseEnrollPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerCourseCode = TextEditingController();
  final CourseController courseController = Get.find();

  Future<void> _enrollWithCode() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUserEmail = "estudiante@ejemplo.com";

        final courses = courseController.courses;
        final courseToEnroll = courses.firstWhere(
          (course) => course.nrc.toString() == controllerCourseCode.text,
          orElse: () =>
              Course(id: '', name: '', nrc: 0, teacher: '', category: ''),
        );

        if (courseToEnroll.name.isNotEmpty) {
          courseController.enrollUser(courseToEnroll.id, currentUserEmail);
          Get.back();
          Get.snackbar(
            'Inscripción Exitosa',
            'Te has inscrito al curso: ${courseToEnroll.name}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'No se encontró un curso con ese código',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (err) {
        Get.snackbar(
          "Error",
          err.toString(),
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>();

    return Scaffold(
      appBar: AppBar(title: const Text('Inscribirse a Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa el código del curso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pide el código de acceso a tu profesor para inscribirte en el curso',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controllerCourseCode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Código del Curso (NRC)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código del curso';
                  }
                  if (int.tryParse(value) == null) {
                    return 'El código debe ser un número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _enrollWithCode,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: palette?.estudianteAccent,
                      ),
                      child: const Text('Ingresar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
