import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/evaluation.dart';
import '../controllers/evaluation_controller.dart';

class EvaluationPage extends StatefulWidget {
  final String evaluatorId;
  final String evaluatedId;
  final int currentIndex;
  final int total;

  const EvaluationPage({
    super.key,
    required this.evaluatorId,
    required this.evaluatedId,
    required this.currentIndex,
    required this.total,
  });

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  double puntualidad = 3;
  double contribucion = 3;
  double compromiso = 3;
  double actitud = 3;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EvaluationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evalúa a tus compañeros"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Clase 3", style: TextStyle(fontSize: 18)),
                const Text("Privado", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),

            CircleAvatar(radius: 25, child: Icon(Icons.person, size: 30)),
            const SizedBox(height: 8),
            Text("Estudiante ${widget.evaluatedId}", style: TextStyle(fontSize: 20)),
            Text("${widget.currentIndex}/${widget.total}",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            buildSlider("Puntualidad", puntualidad, (v) => setState(() => puntualidad = v)),
            buildSlider("Contribución", contribucion, (v) => setState(() => contribucion = v)),
            buildSlider("Compromiso", compromiso, (v) => setState(() => compromiso = v)),
            buildSlider("Actitud", actitud, (v) => setState(() => actitud = v)),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // volver al compañero anterior
                  },
                  child: const Text("Compañero anterior"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final evaluation = Evaluation(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      evaluatorId: widget.evaluatorId,
                      evaluatedId: widget.evaluatedId,
                      puntualidad: puntualidad.toInt(),
                      contribucion: contribucion.toInt(),
                      compromiso: compromiso.toInt(),
                      actitud: actitud.toInt(),
                    );
                    await controller.submitEvaluation(evaluation);
                    Get.snackbar("Éxito", "Evaluación guardada");
                  },
                  child: const Text("Terminar"),
                ),
              ],
            ),

            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Slider(
          value: value,
          min: 2,
          max: 5,
          divisions: 3,
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
