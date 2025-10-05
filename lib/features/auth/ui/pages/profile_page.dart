import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Importa tu controlador real
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';

// Importa tu tema global
import 'package:f_clean_template/core/app_theme.dart';

// Importa el modelo de usuario
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class ProfilePage extends StatelessWidget {
  final AuthenticationController controller = Get.find<AuthenticationController>();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rolePalette = theme.extension<RolePalette>()!;

    return Obx(() {
      final user = controller.currentUser.value;

      if (user == null) {
        return const Scaffold(
          body: Center(child: Text("No hay usuario autenticado")),
        );
      }

      // 🔹 En tu modelo no existe 'role', así que lo manejamos localmente
      // (luego podrás obtenerlo desde Roble o el backend)
      final bool isProfesor = user.email.contains("profesor");

      final accentColor = isProfesor
          ? rolePalette.profesorAccent
          : rolePalette.estudianteAccent;

      final cardColor = isProfesor
          ? rolePalette.profesorCard
          : rolePalette.estudianteCard;

      return Scaffold(
        backgroundColor: rolePalette.surfaceSoft,
        appBar: AppBar(
          backgroundColor: accentColor,
          title: const Text("Perfil"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 50,
                backgroundColor: accentColor,
                child: const Icon(Icons.person, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isProfesor ? Icons.school : Icons.person_2,
                          color: accentColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isProfesor ? "Profesor" : "Estudiante",
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Cursos inscritos: 3", // 🔸 Luego se conectará con tus datos reales
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () async {
                    await controller.logOut();
                    Get.offAllNamed("/login");
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
