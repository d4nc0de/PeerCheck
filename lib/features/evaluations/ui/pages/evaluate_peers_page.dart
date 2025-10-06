import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../groups/ui/controller/group_controller.dart';
import '../../../auth/ui/controller/authentication_controller.dart';
import '../../domain/models/evaluation.dart';
import '../controllers/evaluation_controller.dart';

class EvaluatePeersPage extends StatefulWidget {
  final String activityId;

  const EvaluatePeersPage({super.key, required this.activityId});

  @override
  State<EvaluatePeersPage> createState() => _EvaluatePeersPageState();
}

class _EvaluatePeersPageState extends State<EvaluatePeersPage> {
  final EvaluationController evalController = Get.find();
  final GroupController groupController = Get.find();
  final AuthenticationController authController = Get.find();

  int currentIndex = 0;
  double puntualidad = 3;
  double contribucion = 3;
  double compromiso = 3;
  double actitud = 3;

  @override
  Widget build(BuildContext context) {
    final currentUser = authController.currentUser.value!;
    final group = groupController.getStudentGroup(currentUser.email);

    if (group == null) {
      return const Scaffold(
        body: Center(child: Text("No perteneces a ningún grupo.")),
      );
    }

    final peers = group.members.where((m) => m.email != currentUser.email).toList();
    final peer = peers[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluar a ${peer.name}'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Evaluación ${currentIndex + 1}/${peers.length}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _slider("Puntualidad", puntualidad, (v) => setState(() => puntualidad = v)),
            _slider("Contribución", contribucion, (v) => setState(() => contribucion = v)),
            _slider("Compromiso", compromiso, (v) => setState(() => compromiso = v)),
            _slider("Actitud", actitud, (v) => setState(() => actitud = v)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0
                      ? () => setState(() => currentIndex--)
                      : null,
                  child: const Text("Anterior"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final eval = Evaluation.create(
                      evaluatorId: currentUser.id,
                      evaluatedId: peer.id,
                      groupId: group.id,
                      activityId: widget.activityId,
                      categoryId: group.categoryId,
                      puntualidad: puntualidad,
                      contribucion: contribucion,
                      compromiso: compromiso,
                      actitud: actitud,
                    );
                    await evalController.addEvaluation(eval);

                    if (currentIndex < peers.length - 1) {
                      setState(() => currentIndex++);
                    } else {
                      Get.back(); // volver al listado
                      Get.snackbar("Completado", "Has evaluado a todos tus compañeros");
                    }
                  },
                  child: Text(currentIndex < peers.length - 1 ? "Siguiente" : "Terminar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toStringAsFixed(1),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
