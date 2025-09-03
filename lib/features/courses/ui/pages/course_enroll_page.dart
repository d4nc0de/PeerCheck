import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/courses/data/datasources/local/local_course_source.dart';
import '../controller/course_controller.dart';
import 'package:f_clean_template/core/app_theme.dart';

class CourseEnrollPage extends StatefulWidget {
  const CourseEnrollPage({super.key});

  @override
  State<CourseEnrollPage> createState() => _CourseEnrollPageState();
}

class _CourseEnrollPageState extends State<CourseEnrollPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerCourseCode = TextEditingController();

  Future<void> _enrollWithCode() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUserEmail = 'estudiante@ejemplo.com';
        final nrcCode = int.tryParse(controllerCourseCode.text);

        if (nrcCode == null) {
          Get.snackbar(
            'Error',
            'Código NRC inválido',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        final courseSource = Get.find<LocalCourseSource>();
        final courseToEnroll = courseSource.findCourseByNrc(nrcCode);

        if (courseToEnroll != null) {
          if (courseToEnroll.enrolledUsers.contains(currentUserEmail)) {
            Get.snackbar(
              'Ya Inscrito',
              'Ya estás inscrito en este curso: ${courseToEnroll.name}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }

          if (!courseToEnroll.hasAvailableSpots) {
            Get.snackbar(
              'Cupo Lleno',
              'El curso ${courseToEnroll.name} no tiene cupos disponibles',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          final courseController = Get.find<CourseController>();
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
            'No se encontró un curso con el NRC: $nrcCode',
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
                'Ingresa el código NRC del curso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pide el código NRC a tu profesor para inscribirte en el curso',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cursos disponibles para prueba:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('• Programación Avanzada - NRC: 12345'),
                      Text('• Diseño de Interfaces - NRC: 67890'),
                      const SizedBox(height: 4),
                      const Text(
                        'Usa estos NRC para probar la inscripción',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controllerCourseCode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Código del Curso (NRC)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Ej: 12345',
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
