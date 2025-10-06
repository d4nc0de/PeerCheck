import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/activities/ui/controller/activity_controller.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';

// Páginas existentes
import 'package:f_clean_template/features/groups/ui/pages/group_admin_list_page.dart';
import 'package:f_clean_template/features/activities/ui/pages/activity_list_page.dart';

// 👉 Nueva importación
import 'package:f_clean_template/features/evaluations/ui/pages/evaluation_page.dart';

class CategoryOverviewPage extends StatelessWidget {
  final String courseId;
  final String courseName;
  final Category category;

  const CategoryOverviewPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final accent = palette.profesorAccent;
    final surface = palette.surfaceSoft;
    final cardBg = palette.profesorCard;

    final groupController = Get.find<GroupController>();
    final activityController = Get.find<ActivityController>();
    final authController = Get.find<AuthenticationController>();

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text(
          "Categoría: ${category.name}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: accent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // 🔹 Descripción general de la categoría
            Card(
              color: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Método de asignación: ${_methodText(category.method)}",
                      style: const TextStyle(fontFamily: "Poppins"),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tamaño de grupo: ${category.groupSize}",
                      style: const TextStyle(fontFamily: "Poppins"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Botones de navegación
            _buildActionTile(
              icon: Icons.group,
              title: "Grupos",
              description: "Crea y administra los grupos de esta categoría.",
              color: accent,
              onTap: () {
                Get.to(() => GroupAdminListPage(
                      categoryId: category.id,
                      categoryName: category.name,
                      groupSize: category.groupSize,
                      courseId: courseId,
                    ));
              },
            ),

            const SizedBox(height: 16),

            _buildActionTile(
              icon: Icons.assignment,
              title: "Actividades",
              description: "Crea actividades que pertenezcan a esta categoría.",
              color: Colors.orange.shade700,
              onTap: () {
                activityController.loadActivities(category.id);
                Get.to(() => ActivityListPage(
                      categoryId: category.id,
                      categoryName: category.name,
                    ));
              },
            ),

            const SizedBox(height: 16),

            // 🟣 Nuevo botón de Evaluaciones funcional
            _buildActionTile(
              icon: Icons.analytics,
              title: "Evaluaciones (Assessments)",
              description: "Gestiona las evaluaciones entre pares de esta categoría.",
              color: Colors.purple,
              onTap: () {
                // 🔹 Cargamos las actividades de la categoría
                activityController.loadActivities(category.id);

                // 🔹 Navegamos hacia la página de evaluaciones
                Get.to(() => EvaluationPage(categoryId: category.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Traductor de método (1: Autoasignación, 2: Aleatorio)
  String _methodText(String method) {
    switch (method) {
      case "1":
        return "Autoasignación";
      case "2":
        return "Aleatorio";
      default:
        return "Desconocido";
    }
  }

  /// Widget de tarjeta de acción reutilizable
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
