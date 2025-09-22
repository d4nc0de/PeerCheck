import 'package:f_clean_template/features/auth/data/datasources/local/local_authentication_source_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'core/app_theme.dart';

// Auth
import 'features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
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


const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://roble-api.openlab.uninorte.edu.co',
);

const String kApiDbName = String.fromEnvironment(
  'API_DB_NAME',
  defaultValue: 'peercheck_8b796c5f03', // <-- cámbialo por tu dbName real
);
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
  final client = Get.find<http.Client>(tag: 'apiClient');

  const useRemote = true; // 👈 cambia a false para usar local

  if (useRemote) {
    Get.put<IAuthenticationSource>(
      RemoteAuthenticationSourceService(
        client: client,
        baseUrl: kApiBaseUrl,
        dbName: kApiDbName,
      ),
    );
  } else {
    Get.put<IAuthenticationSource>(LocalAuthenticationSourceService());
  }
  Get.put<IAuthRepository>(AuthRepository(Get.find<IAuthenticationSource>()));
  Get.put(AuthenticationUseCase(Get.find<IAuthRepository>()));
  Get.put(AuthenticationController(Get.find<AuthenticationUseCase>()));

  // ===== COURSES =====
  Get.put<LocalCourseSource>(LocalCourseSource());
  Get.put<ICourseSource>(Get.find<LocalCourseSource>());
  Get.put<ICourseRepository>(CourseRepository(Get.find<ICourseSource>()));
  Get.put(CourseUseCase(Get.find<ICourseRepository>()));
  Get.lazyPut(() => CourseController());

  // ===== CATEGORIES =====
  Get.put(CategoryController());
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
