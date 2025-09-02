import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/course_controller.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final controllerName = TextEditingController();
  final controllerNrc = TextEditingController();
  final controllerTeacher = TextEditingController();
  final controllerCategory = TextEditingController();
  final controllerMaxStudents = TextEditingController(text: '30');

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    CourseController courseController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controllerName,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Curso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllerNrc,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NRC del Curso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el NRC del curso';
                  }
                  if (int.tryParse(value) == null) {
                    return 'El NRC debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllerTeacher,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Profesor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del profesor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllerCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la categoría del curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllerMaxStudents,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Límite de Estudiantes',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el límite de estudiantes';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await courseController.addCourse(
                              controllerName.text,
                              int.parse(controllerNrc.text),
                              controllerTeacher.text,
                              controllerCategory.text,
                              int.parse(controllerMaxStudents.text),
                            );
                            Get.back();
                          } catch (err) {
                            Get.snackbar(
                              "Error",
                              err.toString(),
                              icon: const Icon(Icons.error, color: Colors.red),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      child: const Text("Crear Curso"),
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
