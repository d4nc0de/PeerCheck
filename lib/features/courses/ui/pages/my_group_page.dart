import 'package:f_clean_template/features/courses/domain/models/group.dart';
import 'package:f_clean_template/features/courses/domain/models/member.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';

class MyGroupPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  MyGroupPage({super.key, required this.courseId, required this.courseName});

  final CourseController courseController = Get.find();

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final Color accent = palette.estudianteAccent;
    final Color cardBg = palette.estudianteCard;
    final Color surface = palette.surfaceSoft;

    final GroupInfo? myGroup = courseController.getMyGroupForCourse(courseId);
    final List<Member> members =
        myGroup == null ? const [] : courseController.getMembersByGroup(myGroup.id);

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
              Text('Curso: $courseName',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
            Text('Grupo', style: Theme.of(context).textTheme.titleMedium),
            Text(myGroup?.name ?? '—',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            Card(
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
                        Text('Integrantes (${members.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Divider(),
                    if (members.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Sin integrantes.'),
                      )
                    else
                      ...members.map(
                        (m) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: accent.withOpacity(.15),
                            child: const Icon(Icons.person, color: Colors.black87),
                          ),
                          title: Text(m.name),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: null, // grupo fijo
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
