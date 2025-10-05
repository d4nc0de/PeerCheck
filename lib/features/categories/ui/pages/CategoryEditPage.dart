import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/ui/controller/category_controller.dart';

class CategoryEditPage extends StatefulWidget {
  final Category category;
  final String courseId;

  const CategoryEditPage({
    super.key,
    required this.category,
    required this.courseId,
  });

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _method;
  late int _groupSize;
  bool _isLoading = false;
  final CategoryController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _method = widget.category.method;
    _groupSize = widget.category.groupSize;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updated = Category(
        id: widget.category.id,
        name: _nameController.text.trim(),
        method: _method,
        groupSize: _groupSize,
        courseId: widget.category.courseId,
      );

      await _controller.updateCategory(widget.courseId, updated);
      await _controller.loadCategories(widget.courseId);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Categoría actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la categoría: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Categoría"),
        content: Text(
            "¿Seguro que deseas eliminar '${widget.category.name}'? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _controller.removeCategory(widget.courseId, widget.category.id);
        await _controller.loadCategories(widget.courseId);

        Get.back();
        Get.snackbar(
          'Categoría Eliminada',
          "'${widget.category.name}' ha sido eliminada",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final accent = palette.profesorAccent;
    final cardBg = palette.profesorCard;

    return Scaffold(
      backgroundColor: palette.surfaceSoft,
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: const Text('Editar Categoría'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isLoading ? null : _deleteCategory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                      decoration:
                          const InputDecoration(labelText: 'Nombre categoría'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _method,
                      decoration:
                          const InputDecoration(labelText: 'Método agrupación'),
                      items: const [
                        DropdownMenuItem(value: "1", child: Text("Autoasignación")),
                        DropdownMenuItem(value: "2", child: Text("Aleatorio")),
                      ],
                      onChanged: (v) => setState(() => _method = v ?? "1"),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _groupSize.toString(),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Tamaño por grupo'),
                      onChanged: (v) =>
                          _groupSize = int.tryParse(v.trim()) ?? _groupSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("Guardar cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

