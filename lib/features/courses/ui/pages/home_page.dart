import 'package:f_clean_template/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../../auth/ui/controller/authentication_controller.dart';
import '../controller/course_controller.dart';
import 'add_course_page.dart';
import 'course_enrollment_page.dart';
import 'course_enroll_page.dart';

enum UserRole { profesor, estudiante }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CourseController courseController = Get.find();
  final AuthenticationController authController = Get.find();

  UserRole _role = UserRole.profesor;

  Future<void> _logout() async {
    try {
      await authController.logOut();
    } catch (e) {
      logInfo(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<RolePalette>()!;
    final bool isProfesor = _role == UserRole.profesor;

    final Color accent = isProfesor
        ? palette.profesorAccent
        : palette.estudianteAccent;
    final Color cardBg = isProfesor
        ? palette.profesorCard
        : palette.estudianteCard;
    final Color surface = palette.surfaceSoft;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        title: const Text(""),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black87),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.black87),
            onPressed: () => courseController.deleteCourses(),
            tooltip: 'Eliminar todos los cursos',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/Peertrack_LOGO.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "PeerCheck",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 12),
              child: Text(
                "Cursos",
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _RoleSegmented(
                role: _role,
                profesorColor: palette.profesorAccent,
                estudianteColor: palette.estudianteAccent,
                onChanged: (r) => setState(() => _role = r),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                ),
                child: Obx(
                  () => courseController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () async => courseController.getCourses(),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            children: [
                              for (final course
                                  in courseController.courses) ...[
                                _ClassCard(
                                  title: course.name,
                                  nrc: course.nrc,
                                  teacher: course.teacher,
                                  enrolledCount: course.enrolledCount,
                                  maxStudents: course.maxStudents,
                                  accent: accent,
                                  bg: cardBg,
                                  onTap: () {
                                    if (isProfesor) {
                                      Get.to(
                                        () => CourseEnrollmentPage(
                                          courseId: course.id,
                                          courseName: course.name,
                                          courseCode: course.nrc.toString(),
                                        ),
                                      );
                                    } else {
                                      Get.to(
                                        () => CourseEnrollmentPage(
                                          courseId: course.id,
                                          courseName: course.name,
                                          isStudentView: true,
                                        ),
                                      );
                                    }
                                  },
                                  onDismissed: () =>
                                      courseController.deleteCourse(course),
                                ),
                                const SizedBox(height: 18),
                              ],
                              _AddBigCard(
                                accentBg: cardBg,
                                onAdd: () {
                                  if (isProfesor) {
                                    Get.to(() => const AddCoursePage());
                                  } else {
                                    Get.to(() => const CourseEnrollPage());
                                  }
                                },
                                isProfesor: isProfesor,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: accent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Resultados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _RoleSegmented extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onChanged;
  final Color profesorColor;
  final Color estudianteColor;

  const _RoleSegmented({
    required this.role,
    required this.onChanged,
    required this.profesorColor,
    required this.estudianteColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProfesor = role == UserRole.profesor;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EAEE),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentBtn(
              label: 'Profesor',
              selected: isProfesor,
              selectedColor: profesorColor,
              onTap: () => onChanged(UserRole.profesor),
            ),
          ),
          Expanded(
            child: _SegmentBtn(
              label: 'Estudiante',
              selected: !isProfesor,
              selectedColor: estudianteColor,
              onTap: () => onChanged(UserRole.estudiante),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _SegmentBtn({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5B616E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String title;
  final int nrc;
  final String teacher;
  final int enrolledCount;
  final int maxStudents;
  final Color accent;
  final Color bg;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _ClassCard({
    required this.title,
    required this.nrc,
    required this.teacher,
    required this.enrolledCount,
    required this.maxStudents,
    required this.accent,
    required this.bg,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Text('Eliminando', style: TextStyle(color: Colors.white)),
      ),
      onDismissed: (_) => onDismissed(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Badge(
                    label: Text('$enrolledCount/$maxStudents'),
                    backgroundColor: accent,
                  ),
                  Container(
                    width: 18,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text('NRC: $nrc', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(teacher, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBigCard extends StatelessWidget {
  final Color accentBg;
  final VoidCallback onAdd;
  final bool isProfesor;

  const _AddBigCard({
    required this.accentBg,
    required this.onAdd,
    required this.isProfesor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: accentBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
            ),
            child: Icon(
              isProfesor ? Icons.add : Icons.search,
              size: 28,
              color: const Color(0xFF9EA4AE),
            ),
          ),
        ),
      ),
    );
  }
}
