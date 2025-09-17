import 'package:f_clean_template/features/categories/ui/controller/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import '../controller/course_controller.dart';
import 'package:f_clean_template/features/categories/ui/pages/add_category_page.dart';
import 'package:f_clean_template/features/courses/domain/models/category.dart';
import 'package:f_clean_template/features/courses/domain/models/activity.dart';

class CourseEnrollmentPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String? courseCode;
  final bool isStudentView;

  const CourseEnrollmentPage({
    super.key,
    required this.courseId,
    required this.courseName,
    this.courseCode,
    this.isStudentView = false,
  });

  @override
  State<CourseEnrollmentPage> createState() => _CourseEnrollmentPageState();
}

class _CourseEnrollmentPageState extends State<CourseEnrollmentPage> {
  final CourseController courseController = Get.find();
  Category? _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    courseController.seedMockIfNeeded(widget.courseId);
    final cats = courseController.getCategoriesForCourse(widget.courseId);
    if (cats.isNotEmpty) _selectedCategory = cats.first;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCategoryCard({
    required Category category,
    required bool isSelected,
    required Color accent,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.1) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 2,
          ),
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
                Icon(
                  Icons.category,
                  color: isSelected ? accent : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? accent : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required Activity activity,
    required Color accent,
    required Color cardBg,
  }) {
    return Container(
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
              Icon(
                Icons.assignment_outlined,
                color: accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity.name,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.snackbar(
                      "Próximamente",
                      "Edición de actividades estará disponible pronto",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: accent,
                      colorText: Colors.white,
                    );
                  } else if (value == 'delete') {
                    _showDeleteActivityDialog(activity);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDeleteActivityDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Eliminar Actividad",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600),
        ),
        content: Text(
          "¿Estás seguro de que deseas eliminar '${activity.name}'?",
          style: const TextStyle(fontFamily: "Poppins", fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.snackbar(
                "Actividad Eliminada",
                "'${activity.name}' ha sido eliminada",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final Color accent = palette.profesorAccent;
    final Color cardBg = palette.profesorCard;
    final Color surface = palette.surfaceSoft;
    
    final bool showCode = widget.courseCode != null && !widget.isStudentView;
    final cats = courseController.getCategoriesForCourse(widget.courseId);
    final activities = _selectedCategory == null
        ? <Activity>[]
        : courseController.getActivitiesForCategory(_selectedCategory!.id);

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Collapsing Header
            SliverAppBar(
              expandedHeight: 200.0,
              collapsedHeight: 80.0,
              pinned: true,
              backgroundColor: accent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Calculate the collapse percentage
                  final double expandedHeight = 200.0;
                  final double collapsedHeight = 80.0;
                  final double currentHeight = constraints.maxHeight;
                  final double collapsePercentage = 
                      ((expandedHeight - currentHeight) / (expandedHeight - collapsedHeight))
                          .clamp(0.0, 1.0);
                  
                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(
                      left: 60.0, // Space for back button
                      bottom: 16.0 + (8.0 * (1 - collapsePercentage)),
                      right: 16.0,
                    ),
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: collapsePercentage > 0.5 ? 1.0 : 0.0,
                      child: Text(
                        widget.courseName,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    background: Container(
                      color: accent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40), // Space for status bar and app bar
                          AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: 1.0 - (collapsePercentage * 0.3),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: 1.0 - collapsePercentage,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.school_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.courseName,
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Gestión de Curso",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Code Section
                      if (showCode) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accent.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2, color: accent, size: 40),
                              const SizedBox(height: 12),
                              const Text(
                                'Código de Acceso',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF858597),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.courseCode!,
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: accent,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Comparte este código con los estudiantes',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12,
                                  color: Color(0xFF858597),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                                      // Categories Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Categorías',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(() => const AddCategoryPage());
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Agregar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Lista de categorías reactiva
                          Obx(() {
                            final cats = Get.find<CategoryController>().categories;
                            if (cats.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No hay categorías creadas',
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Crea tu primera categoría para organizar las actividades',
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: cats.length,
                                  itemBuilder: (context, index) {
                                    final category = cats[index];
                                    final isSelected = _selectedCategory?.name == category["name"];
                                    return Container(
                                      width: 200,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: _buildCategoryCard(
                                        category: Category(
                                          id: index.toString(),
                                          name: category["name"], courseId: '',
                                        ),
                                        isSelected: isSelected,
                                        accent: accent,
                                        cardBg: cardBg,
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = Category(
                                              id: index.toString(),
                                              name: category["name"], courseId: '',
                                            );
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          }),
                        ],
                      ),


                      // Activities Section
                      if (_selectedCategory != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Actividades - ${_selectedCategory!.name}',
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  "Próximamente",
                                  "Creación de actividades estará disponible pronto",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: accent,
                                  colorText: Colors.white,
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Actividad"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Activities List
                        if (activities.isEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.assignment_outlined, 
                                     size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay actividades en esta categoría',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega actividades para que los estudiantes puedan evaluarse',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildActivityCard(
                                  activity: activities[index],
                                  accent: accent,
                                  cardBg: cardBg,
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],

                      // Students Section
                      const Text(
                        'Estudiantes Inscritos',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Students List
                      Obx(() {
                        final enrolledUsers = courseController.getEnrolledUsers(widget.courseId);
                        
                        if (enrolledUsers.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.person_outline, 
                                     size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay estudiantes inscritos',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Comparte el código de acceso para que se inscriban',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: enrolledUsers.length,
                          itemBuilder: (context, index) {
                            final userEmail = enrolledUsers[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: accent.withOpacity(0.1),
                                    child: Icon(Icons.person, color: accent),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      userEmail,
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (!widget.isStudentView)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        courseController.unenrollUser(widget.courseId);
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}