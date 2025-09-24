import 'package:f_clean_template/features/categories/ui/controller/category_controller.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/domain/models/activity.dart';
import 'package:f_clean_template/features/courses/ui/controller/course_controller.dart';
import 'package:f_clean_template/features/groups/ui/controller/group_controller.dart';
import 'package:f_clean_template/features/groups/domain/models/group.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/ui/controller/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f_clean_template/core/app_theme.dart';
import 'my_group_page.dart';
import 'group_list_page.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String teacherEmail;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.teacherEmail,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseController courseController = Get.find();
  final CategoryController categoryController = Get.find();
  final GroupController groupController = Get.find();
  final AuthenticationController authController = Get.find();
  Category? _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    courseController.seedMockIfNeeded(widget.courseId);
    _loadAndSelectCategories();
  }

  void _loadAndSelectCategories() {
    categoryController.loadCategoriesWithGroups(widget.courseId);
    
    ever<List<Category>>(categoryController.categories, (cats) {
      if (cats.isNotEmpty && _selectedCategory == null) {
        setState(() => _selectedCategory = cats.first);
        // Cargar grupos de la primera categoría
        groupController.loadGroupsByCategory(cats.first.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Método para obtener el usuario actual
  String _getCurrentUserEmail() {
    return authController.currentUser.value?.email ?? '';
  }

  Widget _buildNoGroupCard(Color accent, Color cardBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_off_outlined,
            size: 48,
            color: Colors.orange[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No perteneces a ningún grupo',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Debes formar parte de un grupo para poder ver y realizar las actividades de esta categoría.',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => GroupListPage(
                    courseId: widget.courseId,
                    courseName: widget.courseName,
                  ));
            },
            icon: const Icon(Icons.groups, size: 18),
            label: const Text(
              'Ver Grupos Disponibles',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGroupCard(Group userGroup, Color accent, Color cardBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Mi Grupo',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grupo ${userGroup.number}',
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${userGroup.members.length} miembro${userGroup.members.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => MyGroupPage(
                              courseId: widget.courseId,
                              courseName: widget.courseName,
                            ));
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text(
                        'Ver Mi Grupo',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(() => GroupListPage(
                              courseId: widget.courseId,
                              courseName: widget.courseName,
                            ));
                      },
                      icon: Icon(Icons.groups_2_outlined, color: accent, size: 16),
                      label: Text(
                        'Otros Grupos',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required Activity activity,
    required Color accent,
    required Color cardBg,
  }) {
    return Card(
      color: cardBg,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.snackbar(
            'Próximamente',
            'La evaluación de actividades estará disponible pronto.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: accent,
            colorText: Colors.white,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 24,
                      color: accent,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Actividad',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activity.name,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              const Spacer(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Próximamente',
                      'La evaluación de compañeros estará disponible pronto.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: accent,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                  label: const Text(
                    'Evaluar',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    final Color accent = palette.estudianteAccent;
    final Color cardBg = palette.estudianteCard;
    final Color surface = palette.surfaceSoft;

    final group = courseController.getMyGroupForCourse(widget.courseId);

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Collapsing Header
            SliverAppBar(
              expandedHeight: 160.0,
              collapsedHeight: 80.0,
              pinned: true,
              backgroundColor: accent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double expandedHeight = 160.0;
                  final double collapsedHeight = 80.0;
                  final double currentHeight = constraints.maxHeight;
                  final double collapsePercentage =
                      ((expandedHeight - currentHeight) / (expandedHeight - collapsedHeight))
                          .clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(
                      left: 60.0,
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
                          const SizedBox(height: 40),
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
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.courseName,
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Profesor: ${widget.teacherEmail}',
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
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
                color: surface,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Seleccionar Categoría',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category Dropdown
                      Obx(() {
                        final cats = categoryController.categories;
                        if (cats.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Text(
                              'No hay categorías disponibles',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accent.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Category>(
                              isExpanded: true,
                              value: cats.contains(_selectedCategory) ? _selectedCategory : null,
                              hint: Text(
                                'Selecciona una categoría',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: Colors.grey[600],
                                ),
                              ),
                              icon: Icon(Icons.keyboard_arrow_down, color: accent),
                              items: cats
                                  .map((c) => DropdownMenuItem<Category>(
                                        value: c,
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (c) {
                                setState(() => _selectedCategory = c);
                                if (c != null) {
                                  groupController.loadGroupsByCategory(c.id);
                                }
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // User Group Status Section
                      if (_selectedCategory != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estado del Grupo',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Group Status Card
                        Obx(() {
                          if (groupController.isLoading) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final userEmail = _getCurrentUserEmail();
                          final userGroup = groupController.getStudentGroup(userEmail);

                          if (userGroup == null) {
                            return _buildNoGroupCard(accent, cardBg);
                          } else {
                            return _buildUserGroupCard(userGroup, accent, cardBg);
                          }
                        }),
                        const SizedBox(height: 24),

                        // Activities Section (solo si tiene grupo)
                        Obx(() {
                          final userEmail = _getCurrentUserEmail();
                          final userGroup = groupController.getStudentGroup(userEmail);
                          
                          if (userGroup == null) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Activities Grid
                              Builder(
                                builder: (context) {
                                  final activities = _selectedCategory?.activities ?? [];
                                  if (activities.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(40),
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
                                            'No hay actividades disponibles en esta categoría',
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Las actividades aparecerán aquí cuando estén disponibles',
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

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: activities.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemBuilder: (context, index) {
                                      return _buildActivityCard(
                                        activity: activities[index],
                                        accent: accent,
                                        cardBg: cardBg,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        }),
                      ],
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