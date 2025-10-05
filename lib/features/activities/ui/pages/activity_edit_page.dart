import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/activities/ui/controller/activity_controller.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';

class ActivityEditPage extends StatefulWidget {
  final Activity activity;

  const ActivityEditPage({super.key, required this.activity});

  @override
  State<ActivityEditPage> createState() => _ActivityEditPageState();
}

class _ActivityEditPageState extends State<ActivityEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late DateTime _dueDate;
  late double _score;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.name);
    _descController = TextEditingController(text: widget.activity.description);
    _dueDate = widget.activity.dueDate;
    _score = widget.activity.score;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActivityController>();
    final rolePalette = Theme.of(context).extension<RolePalette>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Actividad'),
        backgroundColor: rolePalette.profesorAccent,
      ),
      backgroundColor: rolePalette.surfaceSoft,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Entrega: ${_dueDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              Slider(
                value: _score,
                min: 0,
                max: 100,
                divisions: 20,
                label: 'Puntaje: ${_score.round()}',
                onChanged: (v) => setState(() => _score = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: rolePalette.profesorAccent,
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updated = widget.activity.copyWith(
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      dueDate: _dueDate,
                      score: _score,
                    );
                    await controller.updateActivity(updated);
                    Get.back();
                  }
                },
                child: const Text('Guardar cambios'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
