import 'package:f_clean_template/features/categories/ui/controller/category_controller.dart';
import 'package:f_clean_template/features/categories/ui/pages/CategoryEditPage.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/activities/ui/controller/activity_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // 👈 agregado para copiar al portapapeles
import 'package:f_clean_template/core/app_theme.dart';
import '../controller/course_controller.dart';
import 'package:f_clean_template/features/categories/ui/pages/add_category_page.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/activities/domain/models/activity.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';
import 'package:f_clean_template/features/categories/ui/pages/category_overview_page.dart';

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
  final CategoryController categoryController = Get.find();
  final GroupController groupController = Get.find();
  final ActivityController activityController = Get.find();

  Category? _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    courseController.seedMockIfNeeded(widget.courseId);
    _loadAndSelectCategories();
  }

  void _loadAndSelectCategories() {
    categoryController.loadCategories(widget.courseId);

    ever<List<Category>>(categoryController.categories, (cats) {
      if (cats.isNotEmpty && _selectedCategory == null) {
        setState(() {
          _selectedCategory = cats.first;
          groupController.loadGroupsByCategory(_selectedCategory!.id);
          activityController.loadActivities(_selectedCategory!.id);
        });
      }
    });
  }

  void _selectCategory(Category category) {
    setState(() => _selectedCategory = category);
    groupController.loadGroupsByCategory(category.id);
    activityController.loadActivities(category.id);
  }

  // 👇 NUEVO: función para copiar el ID del curso
  void _copyCourseId() {
    Clipboard.setData(ClipboardData(text: widget.courseId));
    Get.snackbar(
      'Copiado',
      'ID del curso copiado al portapapeles',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFD60A),
      colorText: Colors.black,
      duration: const Duration(seconds: 2),
    );
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
    required VoidCallback onEdit,
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
        child: Row(
          children: [
            Icon(Icons.category, color: isSelected ? accent : Colors.grey[600], size: 20),
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
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit, size: 18, color: isSelected ? accent : Colors.grey[600]),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required Activity activity,
    required Color accent,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.assignment, color: accent),
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
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required Group group,
    required Color accent,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.group, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                group.id,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final accent = palette.profesorAccent;
    final cardBg = palette.profesorCard;
    final surface = palette.surfaceSoft;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 👇 MODIFICADO: AppBar con visualización del ID del curso
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: accent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              title: Text(widget.courseName, style: const TextStyle(color: Colors.white)),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Código del curso (ID)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: SelectableText(
                                widget.courseId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _copyCourseId,
                            icon: const Icon(Icons.copy, color: Colors.white),
                            tooltip: 'Copiar ID',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
                child: Column(
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
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Get.to(() => AddCategoryPage(courseId: widget.courseId));
                            _loadAndSelectCategories();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Agregar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final cats = categoryController.categories;
                      if (cats.isEmpty) {
                        return const Text("No hay categorías creadas");
                      }
                      return SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cats.length,
                          itemBuilder: (context, index) {
                            final category = cats[index];
                            final isSelected = _selectedCategory?.id == category.id;
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => CategoryOverviewPage(
                                      category: category,
                                      courseName: widget.courseName,
                                      courseId: widget.courseId,
                                    ));
                              },
                              child: Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                child: _buildCategoryCard(
                                  category: category,
                                  isSelected: isSelected,
                                  accent: accent,
                                  cardBg: cardBg,
                                  onTap: () {
                                    Get.to(() => CategoryOverviewPage(
                                          courseId: widget.courseId,
                                          courseName: widget.courseName,
                                          category: category,
                                        ));
                                  },
                                  onEdit: () async {
                                    await Get.to(() => CategoryEditPage(
                                        category: category, courseId: widget.courseId));
                                    _loadAndSelectCategories();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        'Selecciona una categoría para gestionar grupos, actividades y evaluaciones',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: "Poppins",
                        ),
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
  }
}
