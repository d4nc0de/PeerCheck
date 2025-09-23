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
  late int _groupingMethod;
  bool _isLoading = false;
  final CategoryController _categoryController = Get.find();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _groupingMethod = widget.category.groupingMethod;
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
      // Crear categoría actualizada
      final updatedCategory = Category(
        id: widget.category.id,
        name: _nameController.text.trim(),
        groupingMethod: _groupingMethod,
        courseId: widget.category.courseId,
        groups: widget.category.groups,
        activities: widget.category.activities,
        evaluations: widget.category.evaluations,
      );

      // Actualizar en el controller (necesitarás implementar este método)
      await _categoryController.updateCategory(updatedCategory);

      // Recargar categorías
      await _categoryController.loadCategoriesWithGroups(widget.courseId);

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
        'No se pudo actualizar la categoría: ${e.toString()}',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Eliminar Categoría",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "¿Estás seguro de que deseas eliminar '${widget.category.name}'?",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Esta acción no se puede deshacer. Se eliminarán todas las actividades y evaluaciones asociadas.",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await _categoryController.removeCategory(widget.category.id, widget.courseId);
        await _categoryController.loadCategoriesWithGroups(widget.courseId);

        Get.back(); // Salir de la página de edición
        Get.snackbar(
          'Categoría Eliminada',
          "'${widget.category.name}' ha sido eliminada",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'No se pudo eliminar la categoría: ${e.toString()}',
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
    final Color accent = palette.profesorAccent;
    final Color cardBg = palette.profesorCard;
    final Color surface = palette.surfaceSoft;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: const Text(
          'Editar Categoría',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isLoading ? null : _deleteCategory,
            tooltip: 'Eliminar categoría',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información básica
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: accent, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Información Básica',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nombre de la categoría
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la categoría *',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                      ),
                      style: const TextStyle(fontFamily: "Poppins"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Configuración de agrupación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group, color: accent, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Método de Agrupación',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Método de agrupación
                    DropdownButtonFormField<int>(
                      value: _groupingMethod,
                      decoration: InputDecoration(
                        labelText: 'Método de agrupación',
                        prefixIcon: const Icon(Icons.settings),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black87,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text("Autoasignación"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("Aleatorio"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _groupingMethod = value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}