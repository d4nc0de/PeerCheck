import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import '../controller/course_controller.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';

class CourseEnrollPage extends StatefulWidget {
  const CourseEnrollPage({super.key});

  @override
  State<CourseEnrollPage> createState() => _CourseEnrollPageState();
}

class _CourseEnrollPageState extends State<CourseEnrollPage> {
  final _formKey = GlobalKey<FormState>();
  final controllerCourseCode = TextEditingController();
  final FocusNode _courseCodeFocusNode = FocusNode();

  @override
  void dispose() {
    _courseCodeFocusNode.dispose();
    controllerCourseCode.dispose();
    super.dispose();
  }

  Future<void> _enrollWithCode() async {
    if (!_formKey.currentState!.validate()) return;

    final courseController = Get.find<CourseController>();
    final auth = Get.find<AuthenticationController>();
    final currentUser = auth.currentUser.value;

    if (currentUser == null) {
      Get.snackbar(
        "Error",
        "Debes iniciar sesión para inscribirte",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF001D3D),
        colorText: Colors.white,
      );
      return;
    }

    final courseId = controllerCourseCode.text.trim(); // 👈 usar como ID

    try {
      await courseController.courseUseCase.enrollUser(courseId, currentUser.email);
      await courseController.getStudentCourses();

      Get.back();
      Get.snackbar(
        'Inscripción Exitosa',
        'Te has inscrito al curso.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFD60A),
        colorText: Colors.black,
      );
    } catch (err) {
      Get.snackbar(
        "Error",
        err.toString(),
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEAA7),
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscribirse a Curso'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF000814),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa el código del curso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000814),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pide el código a tu profesor. Es el ID del curso.',
                style: TextStyle(color: Color(0xFF5B616E)),
              ),
              const SizedBox(height: 16),

              // Campo: Código del Curso (ID)
              TextFormField(
                controller: controllerCourseCode,
                focusNode: _courseCodeFocusNode,
                keyboardType: TextInputType.text, // 👈 ya no forzamos número
                decoration: InputDecoration(
                  labelText: 'Código del Curso (ID)',
                  labelStyle: TextStyle(
                    color: _courseCodeFocusNode.hasFocus
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFF858597),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF001D3D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFD4AF37),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF000814)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el código del curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: const Color(0xFFD4AF37),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _enrollWithCode,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFFD60A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
