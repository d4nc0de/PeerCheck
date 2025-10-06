import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/authentication_controller.dart';
import 'edit_profile_page.dart';
import 'package:f_clean_template/features/courses/ui/pages/home_page.dart ';

class ProfilePage extends StatelessWidget {
  final AuthenticationController controller = Get.find();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(child: Text("No hay usuario autenticado"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Imagen del perfil
              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey,
                backgroundImage:
                    AssetImage('assets/images/default_profile.png'),
              ),
              const SizedBox(height: 20),

              // Nombre actualizado
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1),

              // Información adicional del perfil
              _ProfileInfoTile(
                icon: Icons.person_outline,
                title: "Nombre completo",
                subtitle: user.name,
              ),
              _ProfileInfoTile(
                icon: Icons.email_outlined,
                title: "Correo electrónico",
                subtitle: user.email,
              ),
              _ProfileInfoTile(
                icon: Icons.badge_outlined,
                title: "ID de usuario",
                subtitle: user.id,
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1),

              // Botón para editar perfil
              _ProfileOption(
                icon: Icons.edit_outlined,
                title: "Editar perfil",
                onTap: () {
                  Get.to(() => const EditProfilePage());
                },
              ),

              const SizedBox(height: 10),

              // 🔹 Botón para regresar al Home
              ElevatedButton.icon(
                onPressed: () {
                   Get.offAll(() => const HomePage()); // Vuelve al Home
                },
                icon: const Icon(Icons.home),
                label: const Text("Volver al inicio"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// 🔹 Info del perfil
class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }
}

// 🔹 Opción de acción
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
