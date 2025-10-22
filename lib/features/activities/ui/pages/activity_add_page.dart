import 'package:f_clean_template/features/activities/ui/pages/activity_list_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/activities/ui/controller/activity_controller.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';

class ActivityAddPage extends StatefulWidget {
  final String categoryId;

  const ActivityAddPage({super.key, required this.categoryId});

  @override
  State<ActivityAddPage> createState() => _ActivityAddPageState();
}

class _ActivityAddPageState extends State<ActivityAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  double _score = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActivityController>();
    final rolePalette = Theme.of(context).extension<RolePalette>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Actividad'),
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
                  _dueDate == null
                      ? 'Seleccionar fecha de entrega'
                      : 'Entrega: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                  if (_formKey.currentState!.validate() && _dueDate != null) {
                    final activity = Activity.create(
                      categoryId: widget.categoryId,
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      dueDate: _dueDate!,
                      score: _score,
                    );
                    await controller.addActivity(activity);
                    Get.to(ActivityListPage);
                  }
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
