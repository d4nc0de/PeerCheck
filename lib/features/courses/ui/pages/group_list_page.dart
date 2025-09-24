import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';

class GroupListPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String? categoryId;

  const GroupListPage({
    super.key, 
    required this.courseId, 
    required this.courseName,
    this.categoryId,
  });

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final GroupController groupController = Get.find();
  final AuthenticationController authController = Get.find();
  bool _isJoiningGroup = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      groupController.loadGroupsByCategory(widget.categoryId!);
    }
  }

  String _getCurrentUserEmail() {
    return authController.currentUser.value?.email ?? '';
  }

  Future<void> _showJoinGroupDialog(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unirse al grupo'),
        content: Text('¿Quieres unirte al grupo ${group.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unirme'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _joinGroup(group);
    }
  }

  Future<void> _joinGroup(Group group) async {
    setState(() => _isJoiningGroup = true);
    
    final userEmail = _getCurrentUserEmail();
    final success = await groupController.addMemberToGroup(
      groupId: group.id,
      studentEmail: userEmail,
    );

    setState(() => _isJoiningGroup = false);

    if (success) {
      Get.snackbar(
        'Éxito',
        'Te has unido al grupo ${group.number} exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        groupController.errorMessage.isNotEmpty 
            ? groupController.errorMessage 
            : 'No se pudo unir al grupo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showMembersDialog(Group group) {
    Get.defaultDialog(
      title: 'Integrantes - Grupo ${group.number}',
      titleStyle: const TextStyle(
        fontFamily: "Poppins",
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: group.members.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Grupo vacío',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Este grupo no tiene miembros aún',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: group.members.length,
                itemBuilder: (context, index) {
                  final member = group.members[index];
                  final userEmail = _getCurrentUserEmail();
                  final isCurrentUser = member.email == userEmail;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentUser 
                          ? Theme.of(context).primaryColor.withOpacity(.3)
                          : Colors.grey.withOpacity(.2),
                      child: Icon(
                        isCurrentUser ? Icons.person : Icons.person_outline,
                        color: isCurrentUser 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[600],
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name.isNotEmpty ? member.name : member.email.split('@')[0],
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
                              color: isCurrentUser 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tú',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      member.email,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
      ),
      textCancel: 'Cerrar',
      cancelTextColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final Color accent = palette.estudianteAccent;
    final Color cardBg = palette.estudianteCard;
    final Color surface = palette.surfaceSoft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de grupos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        color: surface,
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 16),
            
            Expanded(
              child: Obx(() {
                if (groupController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final userEmail = _getCurrentUserEmail();
                final allGroups = groupController.groupsForSelectedCategory;
                final userGroup = groupController.getStudentGroup(userEmail);
                final canJoinGroup = userGroup == null;

                if (allGroups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay grupos disponibles',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Los grupos aparecerán aquí cuando estén disponibles',
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
                    if (!canJoinGroup && userGroup != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ya perteneces al grupo ${userGroup.number}',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    Expanded(
                      child: ListView.separated(
                        itemCount: allGroups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final group = allGroups[index];
                          final isUserGroup = userGroup?.id == group.id;
                          
                          return Card(
                            color: isUserGroup ? accent.withOpacity(0.1) : cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: isUserGroup 
                                  ? BorderSide(color: accent.withOpacity(0.5), width: 2)
                                  : BorderSide.none,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isUserGroup ? Icons.group : Icons.group_outlined,
                                        color: isUserGroup ? accent : Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Grupo ${group.number}',
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 16,
                                            fontWeight: isUserGroup ? FontWeight.w700 : FontWeight.w600,
                                            color: isUserGroup ? accent : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isUserGroup)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: accent,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Mi Grupo',
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${group.members.length} miembro${group.members.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showMembersDialog(group),
                                          icon: const Icon(Icons.people_outline, size: 16),
                                          label: const Text(
                                            'Ver Integrantes',
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: accent.withOpacity(0.5)),
                                            foregroundColor: accent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      if (canJoinGroup && !isUserGroup)
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: _isJoiningGroup ? null : () => _showJoinGroupDialog(group),
                                            icon: _isJoiningGroup 
                                                ? const SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  )
                                                : const Icon(Icons.group_add, size: 16),
                                            label: Text(
                                              _isJoiningGroup ? 'Uniéndose...' : 'Unirse',
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: accent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'Volver',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
