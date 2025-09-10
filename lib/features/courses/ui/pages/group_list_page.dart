import 'package:f_clean_template/features/courses/domain/models/group.dart';
import 'package:f_clean_template/features/courses/domain/models/member.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';

class GroupListPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  GroupListPage({super.key, required this.courseId, required this.courseName});

  final CourseController courseController = Get.find();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final Color accent = palette.estudianteAccent;
    final Color cardBg = palette.estudianteCard;
    final Color surface = palette.surfaceSoft;

    final List<GroupInfo> groups = courseController.getGroupsForCourse(courseId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi grupo · Lista de grupos'),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Curso: $courseName',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final g = groups[index];
                  return Card(
                    color: cardBg,
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Icon(Icons.group_outlined, color: accent),
                      title: Text(g.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent.withOpacity(.15),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final List<Member> members =
                              courseController.getMembersByGroup(g.id);
                          Get.defaultDialog(
                            title: 'Integrantes',
                            titleStyle: const TextStyle(fontWeight: FontWeight.w700),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: Column(
                                children: members.isEmpty
                                    ? [const Text('Sin integrantes')]
                                    : members
                                        .map((m) => ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    accent.withOpacity(.15),
                                                child: const Icon(Icons.person,
                                                    color: Colors.black87),
                                              ),
                                              title: Text(m.name),
                                            ))
                                        .toList(),
                              ),
                            ),
                            textCancel: 'Cerrar',
                          );
                        },
                        child: const Text('Integrantes'),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: null, // sin acción en V1
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent.withOpacity(.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Dejar grupo'),
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
        ),
      ),
    );
  }
}
