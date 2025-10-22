import 'package:f_clean_template/features/groups/data/datasources/remote/remote_group_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'core/app_theme.dart';
import 'central.dart';

// ===== HTTP helper (manejo de token + 401) =====
import 'core/net/auth_http_client.dart';

// ==================== AUTH ====================
import 'features/auth/data/datasources/local/local_authentication_source_service.dart';
import 'features/auth/data/datasources/remote/Remote_authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/datasources/remote/remote_logout_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/use_case/authentication_usecase.dart';
import 'features/auth/ui/controller/authentication_controller.dart';

// ==================== COURSES ====================
import 'features/courses/data/datasources/i_course_source.dart';
import 'features/courses/data/datasources/local/local_course_source.dart';
import 'features/courses/data/datasources/remote/remote_course_source.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/use_case/course_usecase.dart';
import 'features/courses/ui/controller/course_controller.dart';

// ==================== CATEGORIES ====================
import 'features/categories/data/datasources/local/i_category_source.dart';
import 'features/categories/data/datasources/local/local_category_source.dart';
import 'features/categories/data/datasources/remote/remote_source_adapter.dart';
import 'features/categories/data/repositories/category_repository.dart';
import 'features/categories/domain/repositories/i_category_repository.dart';
import 'features/categories/domain/use_case/category_usecase.dart';
import 'features/categories/ui/controller/category_controller.dart';

// ==================== GROUPS ====================
import 'features/groups/data/datasources/local/local_group_source.dart';
import 'features/groups/data/repositories/group_repository.dart';
import 'features/groups/domain/use_case/group_usecase.dart';
import 'features/groups/ui/controller/group_controller.dart';

// ==================== ACTIVITIES ====================
import 'features/activities/data/datasources/i_activity_source.dart';
import 'features/activities/data/datasources/local/local_activity_source.dart';
import 'features/activities/data/datasources/remote/remote_activity_source.dart';
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
  const useRemote = true; // Cambia a false para modo local

  if (useRemote) {
    // ========== HTTP clients ==========
    final rawClient = http.Client();

    // Auth primero (usa raw client)
    final authSvc = RemoteAuthenticationSourceService(
      client: rawClient,
      baseUrl: kApiBaseUrl,
      dbName: kApiDbName,
    );
    Get.put<IAuthenticationSource>(authSvc);

    // Cliente protegido que agrega token y redirige al login en 401
    final guardedClient = AuthHttpClient(
      inner: rawClient,
      auth: authSvc,
      onUnauthorized: () => authSvc.handleUnauthorized(),
    );
    Get.put<http.Client>(guardedClient, tag: 'apiClient');
    Get.put<http.Client>(rawClient, tag: 'rawClient');

    // Servicios remotos base
    Get.put(RemoteLogoutService(
      client: guardedClient,
      baseUrl: kApiBaseUrl,
      dbName: kApiDbName,
      auth: authSvc,
    ));

    // ===== AUTH repo + controller (AHORA ANTES QUE TODO LO DEMÁS) =====
    Get.put<IAuthRepository>(AuthRepository(Get.find<IAuthenticationSource>()));
    Get.put(AuthenticationUseCase(Get.find<IAuthRepository>()));
    Get.put(AuthenticationController(
      Get.find<AuthenticationUseCase>(),
      Get.find<RemoteLogoutService>(),
    ));

    // Base del módulo DB
    const dbBase = '$kApiBaseUrl/database';

    // Sources remotos
    Get.put<ICourseSource>(RemoteCourseSource(
      client: guardedClient,
      baseUrl: dbBase,
      dbName: kApiDbName,
      auth: authSvc,
    ));
    Get.put<ICategorySource>(RemoteCategorySourceAdapter(
      client: guardedClient,
      baseUrl: dbBase,
      dbName: kApiDbName,
      auth: authSvc,
    ));
    Get.put<IActivitySource>(RemoteActivitySource(
      client: guardedClient,
      baseUrl: dbBase,
      dbName: kApiDbName,
      auth: authSvc,
    ));

    // ===== COURSES =====
    Get.put<ICourseRepository>(CourseRepository(Get.find<ICourseSource>()));
    Get.put(CourseUseCase(Get.find<ICourseRepository>()));
    Get.put(CourseController()); // ya puede resolverse AuthenticationController

    // ===== GROUPS (remoto) =====
    final remoteGroupSource = RemoteGroupSource(
      client: guardedClient,
      baseDb: dbBase,
      dbName: kApiDbName,
      auth: authSvc,
    );
    final groupRepository = RemoteGroupRepository(remoteGroupSource);
    final groupUseCase = GroupUseCase(groupRepository: groupRepository);
    Get.put(GroupController(groupUseCase));

  } else {
    // ===== Modo local =====
    final localClient = http.Client();
    Get.put<http.Client>(localClient, tag: 'apiClient');

    Get.put<IAuthenticationSource>(LocalAuthenticationSourceService());

    // ===== AUTH repo + controller (también antes) =====
    Get.put<IAuthRepository>(AuthRepository(Get.find<IAuthenticationSource>()));
    Get.put(AuthenticationUseCase(Get.find<IAuthRepository>()));
    // En local no tienes RemoteLogoutService real; pasa un dummy si hace falta
    Get.put(AuthenticationController(
      Get.find<AuthenticationUseCase>(),
      RemoteLogoutService(
        client: localClient,
        baseUrl: kApiBaseUrl,
        dbName: kApiDbName,
        auth: Get.find<IAuthenticationSource>()
            as RemoteAuthenticationSourceService,
      ),
    ));

    Get.put<LocalCourseSource>(LocalCourseSource());
    Get.put<ICourseSource>(Get.find<LocalCourseSource>());
    Get.put<LocalCategorySource>(LocalCategorySource());
    Get.put<ICategorySource>(Get.find<LocalCategorySource>());
    Get.put<LocalActivitySource>(LocalActivitySource());
    Get.put<IActivitySource>(Get.find<LocalActivitySource>());

    Get.put<ICourseRepository>(CourseRepository(Get.find<ICourseSource>()));
    Get.put(CourseUseCase(Get.find<ICourseRepository>()));
    Get.put(CourseController());

    final localGroupSource = LocalGroupSource();
    // final groupRepository = LocalGroupRepository(localGroupSource);
    // final groupUseCase = GroupUseCase(groupRepository: groupRepository);
    // Get.put(GroupController(groupUseCase));
  }

  // ===== CATEGORIES =====
  Get.put<ICategoryRepository>(
    LocalCategoryRepository(Get.find<ICategorySource>()),
  );
  Get.put<CategoryUseCase>(CategoryUseCase(Get.find<ICategoryRepository>()));
  Get.put(CategoryController(Get.find<CategoryUseCase>()));

  // ===== ACTIVITIES =====
  Get.put<IActivityRepository>(
    LocalActivityRepository(Get.find<IActivitySource>()),
  );
  Get.put(ActivityUseCase(Get.find<IActivityRepository>()));
  Get.put(ActivityController(Get.find<ActivityUseCase>()));

  // ===== EVALUATIONS =====
  Get.put(EvaluationRepository()); // solo memoria temporal
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
      // routes: {'/login': (_) => const LoginPage()},
      home: const Central(),
    );
  }
}
