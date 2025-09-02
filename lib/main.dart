import 'package:f_clean_template/features/courses/data/datasources/local/local_course_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'central.dart';
import 'core/app_theme.dart';

import 'features/auth/data/datasources/remote/authentication_source_service.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/use_case/authentication_usecase.dart';
import 'features/auth/ui/controller/authentication_controller.dart';
import 'features/courses/data/datasources/i_course_source.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/use_case/course_usecase.dart';
import 'features/courses/ui/controller/course_controller.dart';

void main() {
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  Get.put(http.Client(), tag: 'apiClient');

  // Auth
  Get.put<IAuthenticationSource>(AuthenticationSourceService());
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(AuthenticationUseCase(Get.find()));
  Get.put(AuthenticationController(Get.find()));

  // Course
  Get.put<ICourseSource>(LocalCourseSource());
  Get.put<ICourseRepository>(CourseRepository(Get.find()));
  Get.put(CourseUseCase(Get.find()));
  Get.lazyPut(() => CourseController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PeerCheck - Evaluación entre Pares',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const Central(),
    );
  }
}
