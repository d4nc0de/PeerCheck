import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import '../controller/course_controller.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final controllerName = TextEditingController();
  final controllerNrc = TextEditingController();
  final controllerMaxStudents = TextEditingController(text: '30');

  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _nrcFocusNode = FocusNode();
  final FocusNode _maxStudentsFocusNode = FocusNode();

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nrcFocusNode.dispose();
    _maxStudentsFocusNode.dispose();
    controllerName.dispose();
    controllerNrc.dispose();
    controllerMaxStudents.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF858597),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: "Poppins",
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find();
    final palette = Theme.of(context).extension<RolePalette>()!;
    final accentColor = palette.profesorAccent;
    final cardColor = palette.profesorCard;
    final surfaceColor = palette.surfaceSoft;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: accentColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with blue background
            Container(
              height: screenHeight * 0.25,
              width: screenWidth,
              color: accentColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // App bar
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        const Expanded(
                          child: Text(
                            "Crear Curso",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Header content
                    const Icon(
                      Icons.school_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Nuevo Curso",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form section
            Expanded(
              child: Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: 30,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          
                          // Subtitle
                          const Text(
                            "Completa los datos del curso para crearlo",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF858597),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Course Name Field
                          _buildTextField(
                            controller: controllerName,
                            focusNode: _nameFocusNode,
                            label: "Nombre del Curso",
                            accentColor: accentColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Ingrese el nombre del curso";
                              }
                              if (value.length < 3) {
                                return "Mínimo 3 caracteres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // NRC Field
                          _buildTextField(
                            controller: controllerNrc,
                            focusNode: _nrcFocusNode,
                            label: "NRC del Curso",
                            keyboardType: TextInputType.number,
                            accentColor: accentColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Ingrese el NRC del curso";
                              }
                              if (int.tryParse(value) == null) {
                                return "Debe ser un número válido";
                              }
                              if (value.length != 5) {
                                return "El NRC debe tener 5 dígitos";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Max Students Field
                          _buildTextField(
                            controller: controllerMaxStudents,
                            focusNode: _maxStudentsFocusNode,
                            label: "Límite de Estudiantes",
                            keyboardType: TextInputType.number,
                            accentColor: accentColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Ingrese el límite de estudiantes";
                              }
                              if (int.tryParse(value) == null) {
                                return "Debe ser un número válido";
                              }
                              final maxStudents = int.parse(value);
                              if (maxStudents < 1) {
                                return "Mínimo 1 estudiante";
                              }
                              if (maxStudents > 100) {
                                return "Máximo 100 estudiantes";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          // Create Course Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await courseController.addCourse(
                                      controllerName.text.trim(),
                                      int.parse(controllerNrc.text),
                                      'General',
                                      int.parse(controllerMaxStudents.text),
                                    );

                                    Get.back();

                                    Get.snackbar(
                                      "Curso Creado",
                                      "El curso '${controllerName.text}' se creó exitosamente",
                                      icon: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: accentColor,
                                      colorText: Colors.white,
                                    );
                                  } catch (err) {
                                    Get.snackbar(
                                      "Error",
                                      "No se pudo crear el curso: ${err.toString()}",
                                      icon: const Icon(
                                        Icons.error,
                                        color: Colors.white,
                                      ),
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Crear Curso",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cancel Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: accentColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Get.back(),
                              child: Text(
                                "Cancelar",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}