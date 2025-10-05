import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/activities/ui/controller/activity_controller.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/activities/ui/pages/activity_add_page.dart';
import 'package:f_clean_template/features/activities/ui/pages/activity_edit_page.dart';

class ActivityListPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ActivityListPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActivityController>();
    final rolePalette = Theme.of(context).extension<RolePalette>()!;
    controller.loadActivities(categoryId);

    return Scaffold(
      backgroundColor: rolePalette.surfaceSoft,
      appBar: AppBar(
        title: Text('Actividades - $categoryName'),
        backgroundColor: rolePalette.profesorAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: rolePalette.profesorAccent,
        onPressed: () => Get.to(() => ActivityAddPage(categoryId: categoryId)),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.activities.isEmpty) {
          return const Center(child: Text('No hay actividades registradas.'));
        }

        return ListView.builder(
          itemCount: controller.activities.length,
          itemBuilder: (context, index) {
            final activity = controller.activities[index];
            return Card(
              color: rolePalette.profesorCard,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(activity.name),
                subtitle: Text(activity.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        Get.to(() => ActivityEditPage(activity: activity));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await controller.removeActivity(
                          categoryId,
                          activity.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
