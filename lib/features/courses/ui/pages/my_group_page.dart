import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';

class MyGroupPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String? categoryId;

  const MyGroupPage({
    super.key, 
    required this.courseId, 
    required this.courseName,
    this.categoryId,
  });

  @override
  State<MyGroupPage> createState() => _MyGroupPageState();
}

class _MyGroupPageState extends State<MyGroupPage> {
  final GroupController groupController = Get.find();
  final AuthenticationController authController = Get.find();
  bool _isLeavingGroup = false;

  @override
  void initState() {
    super.initState();
    // Si tenemos categoryId, cargar grupos de esa categoría
    if (widget.categoryId != null) {
      groupController.loadGroupsByCategory(widget.categoryId!);
    }
  }

  String _getCurrentUserEmail() {
    return authController.currentUser.value?.email ?? '';
  }

  Future<void> _showLeaveGroupDialog(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dejar grupo'),
        content: Text('¿Estás seguro de que quieres dejar el grupo ${group.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Dejar grupo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _leaveGroup(group);
    }
  }

  Future<void> _leaveGroup(Group group) async {
    setState(() => _isLeavingGroup = true);
    
    final userEmail = _getCurrentUserEmail();
    final success = await groupController.removeMemberFromGroup(
      groupId: group.id,
      studentEmail: userEmail,
    );

    setState(() => _isLeavingGroup = false);

    if (success) {
      Get.snackbar(
        'Éxito',
        'Has dejado el grupo exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back(); // Volver a la página anterior
    } else {
      Get.snackbar(
        'Error',
        groupController.errorMessage.isNotEmpty 
            ? groupController.errorMessage 
            : 'No se pudo dejar el grupo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final Color accent = palette.estudianteAccent;
    final Color cardBg = palette.estudianteCard;
    final Color surface = palette.surfaceSoft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi grupo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        color: surface,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 18,
                height: 4,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('Curso: ${widget.courseName}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),

            // Contenido principal con Obx para reactividad
            Expanded(
              child: Obx(() {
                if (groupController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final userEmail = _getCurrentUserEmail();
                final userGroup = groupController.getStudentGroup(userEmail);

                if (userGroup == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No perteneces a ningún grupo',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Regresa a la lista de cursos para unirte a un grupo',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grupo', style: Theme.of(context).textTheme.titleMedium),
                    Text('Grupo ${userGroup.number}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),

                    // Tarjeta de integrantes
                    Expanded(
                      child: Card(
                        color: cardBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people_alt_outlined, color: accent),
                                  const SizedBox(width: 8),
                                  Text('Integrantes (${userGroup.members.length})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const Divider(),
                              Expanded(
                                child: userGroup.members.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text('Sin integrantes.'),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: userGroup.members.length,
                                        itemBuilder: (context, index) {
                                          final member = userGroup.members[index];
                                          final isCurrentUser = member.email == userEmail;
                                          
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isCurrentUser 
                                                  ? accent.withOpacity(.3)
                                                  : accent.withOpacity(.15),
                                              child: Icon(
                                                isCurrentUser ? Icons.person : Icons.person_outline,
                                                color: isCurrentUser ? accent : Colors.black87,
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    member.name.isNotEmpty ? member.name : member.email.split('@')[0],
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                                if (isCurrentUser)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, 
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: accent.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'Tú',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: accent,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            subtitle: Text(
                                              member.email,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLeavingGroup 
                                ? null 
                                : () => _showLeaveGroupDialog(userGroup),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _isLeavingGroup 
                                    ? Colors.grey 
                                    : Colors.red.withOpacity(.6),
                              ),
                              foregroundColor: _isLeavingGroup 
                                  ? Colors.grey 
                                  : Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLeavingGroup
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Dejar grupo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text('Volver'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}