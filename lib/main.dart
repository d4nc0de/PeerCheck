import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'core/app_theme.dart';
import 'central.dart';

// ==================== AUTH ====================
import 'features/auth/data/datasources/local/local_authentication_source_service.dart';
import 'features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/use_case/authentication_usecase.dart';
import 'features/auth/ui/controller/authentication_controller.dart';

// ==================== COURSES ====================
import 'features/courses/data/datasources/local/local_course_source.dart';
import 'features/courses/data/datasources/i_course_source.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/use_case/course_usecase.dart';
import 'features/courses/ui/controller/course_controller.dart';

// ==================== CATEGORIES ====================
import 'features/categories/ui/controller/category_controller.dart';
import 'features/categories/data/datasources/local/i_category_source.dart';
import 'features/categories/data/datasources/local/local_category_source.dart';
import 'features/categories/data/repositories/category_repository.dart';
import 'features/categories/domain/use_case/category_usecase.dart';

// ==================== GROUPS ====================
import 'features/groups/data/datasources/local/local_group_source.dart';
import 'features/groups/data/repositories/group_repository.dart';
import 'features/groups/domain/use_case/group_usecase.dart';
import 'features/groups/ui/controller/group_controller.dart';

// ==================== ACTIVITIES ====================
import 'features/activities/data/datasources/local/local_activity_source.dart';
import 'features/activities/data/datasources/i_activity_source.dart';
import 'features/activities/data/repositories/activity_repository.dart';
import 'features/activities/domain/repositories/i_activity_repository.dart';
import 'features/activities/domain/use_case/activity_usecase.dart';
import 'features/activities/ui/controller/activity_controller.dart';

// ==================== EVALUATIONS (solo lógica local sin data) ====================
import 'features/evaluations/domain/repository/evaluation_repository.dart';
import 'features/evaluations/domain/use_case/evaluation_usecase.dart';
import 'features/evaluations/ui/controllers/evaluation_controller.dart';

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://roble-api.openlab.uninorte.edu.co',
);

const String kApiDbName = String.fromEnvironment(
  'API_DB_NAME',
  defaultValue: 'peercheck_8b796c5f03',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));
  initDependencies();
  runApp(const MyApp());
}

void initDependencies() {
  // ===== HTTP Client =====
  Get.put(http.Client(), tag: 'apiClient');
  final client = Get.find<http.Client>(tag: 'apiClient');

  const useRemote = false; // 🔹 Cambia a true si usas API remota

  // ===== AUTH =====
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

  // ===== GROUPS =====
  final localGroupSource = LocalGroupSource();
  final groupRepository = LocalGroupRepository(localGroupSource);
  final groupUseCase = GroupUseCase(groupRepository: groupRepository);
  Get.put(GroupController(groupUseCase));

  // ===== CATEGORIES =====
  Get.put<LocalCategorySource>(LocalCategorySource());
  Get.put<ICategorySource>(Get.find<LocalCategorySource>());
  Get.put<LocalCategoryRepository>(
      LocalCategoryRepository(Get.find<ICategorySource>()));
  Get.put<CategoryUseCase>(CategoryUseCase(Get.find<LocalCategoryRepository>()));
  Get.put<CategoryController>(CategoryController(Get.find<CategoryUseCase>()));

  // ===== ACTIVITIES =====
  Get.put<LocalActivitySource>(LocalActivitySource());
  Get.put<IActivitySource>(Get.find<LocalActivitySource>());
  Get.put<IActivityRepository>(LocalActivityRepository(Get.find<IActivitySource>()));
  Get.put(ActivityUseCase(Get.find<IActivityRepository>()));
  Get.put(ActivityController(Get.find<ActivityUseCase>()));

  // ===== EVALUATIONS =====
  Get.put(EvaluationRepository()); // 👈 solo memoria temporal
  Get.put(EvaluationUseCase(Get.find<EvaluationRepository>()));
  Get.put(EvaluationController(Get.find<EvaluationUseCase>()));
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
