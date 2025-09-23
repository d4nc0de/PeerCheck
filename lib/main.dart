import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'core/app_theme.dart';

// Auth
import 'features/auth/data/datasources/remote/authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/use_case/authentication_usecase.dart';
import 'features/auth/ui/controller/authentication_controller.dart';

// Courses
import 'features/courses/data/datasources/local/local_course_source.dart';
import 'features/courses/data/datasources/i_course_source.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/use_case/course_usecase.dart';
import 'features/courses/ui/controller/course_controller.dart';

// Categories
import 'features/categories/ui/controller/category_controller.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/categories/data/datasources/local/i_category_source.dart';
import 'package:f_clean_template/features/categories/data/datasources/local/local_category_source.dart';
import 'package:f_clean_template/features/categories/data/repositories/category_repository.dart';
import 'package:f_clean_template/features/categories/domain/use_case/category_usecase.dart';


void main() {

  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // Inicializar dependencias antes de correr la app
  initDependencies();

  runApp(const MyApp());
}

void initDependencies() {
  // Cliente HTTP
  Get.put(http.Client(), tag: 'apiClient');

  // Auth
  Get.put<IAuthenticationSource>(AuthenticationSourceService());
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(AuthenticationUseCase(Get.find()));
  Get.put(AuthenticationController(Get.find()));

  // Courses
  Get.put<LocalCourseSource>(LocalCourseSource());
  Get.put<ICourseSource>(Get.find<LocalCourseSource>());
  Get.put<ICourseRepository>(CourseRepository(Get.find()));
  Get.put(CourseUseCase(Get.find()));
  Get.lazyPut(() => CourseController());

  // Categories
  Get.put<LocalCategorySource>(LocalCategorySource());
  Get.put<ICategorySource>(Get.find<LocalCategorySource>());
  Get.put<LocalCategoryRepository>(
      LocalCategoryRepository(Get.find<ICategorySource>()));
  Get.put<CategoryUseCase>(
      CategoryUseCase(categoryRepository: Get.find<LocalCategoryRepository>()));
  Get.put<CategoryController>(
      CategoryController(Get.find<CategoryUseCase>()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PeerCheck - Evaluación entre Pares',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Central(),
    );
  }
}
