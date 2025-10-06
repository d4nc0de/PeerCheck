import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/features/evaluations/ui/pages/evaluate_peers_page.dart';
import '../../../activities/ui/controller/activity_controller.dart';

class EvaluationPage extends StatelessWidget {
  final String categoryId;

  const EvaluationPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Obx(() {
        final activities = activityController.activities;
        if (activities.isEmpty) {
          return const Center(child: Text('No hay actividades disponibles.'));
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(activity.name),
                subtitle: Text("Evaluar a tus compañeros"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Get.to(() => EvaluatePeersPage(activityId: activity.id));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
