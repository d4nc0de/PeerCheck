import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/authentication_controller.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthenticationController controller = Get.find();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    final user = controller.currentUser.value;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final user = controller.currentUser.value;
    if (user == null) return;

    // 🔹 Actualiza los datos del usuario actual
    controller.currentUser.value = user.copyWith(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text.isNotEmpty
          ? passwordController.text
          : user.password,
    );

    Get.back(); // Regresar al perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Perfil actualizado correctamente ✅"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          "Editar Perfil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Actualiza tus datos personales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Campo de nombre
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de correo
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de contraseña (opcional)
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña (opcional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
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
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Extensión para poder actualizar datos del usuario fácilmente
extension AuthenticationUserCopy on AuthenticationUser {
  AuthenticationUser copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return AuthenticationUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
