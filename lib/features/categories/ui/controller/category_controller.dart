import 'package:get/get.dart';
import 'package:f_clean_template/features/categories/domain/use_case/category_usecase.dart';
import 'package:f_clean_template/features/categories/domain/models/category.dart';
import 'package:f_clean_template/features/categories/domain/models/group.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

class CategoryController extends GetxController {
  final CategoryUseCase useCase;

  CategoryController(this.useCase);

  final RxList<Category> categories = <Category>[].obs;
  final RxMap<Category, List<Group>> groupsByCourse = <Category, List<Group>>{}.obs;
  final RxMap<Group, List<AuthenticationUser>> membersByCourse = <Group, List<AuthenticationUser>>{}.obs;
  final RxBool isLoading = false.obs;

  Future<void> loadCategoriesWithGroups(String courseId) async {
    isLoading.value = true;
    try {
      categories.value = await useCase.getCategoriesWithGroupsByCourse(courseId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupsByCourse(String courseId) async {
    isLoading.value = true;
    try {
      groupsByCourse.value = await useCase.getGroupsByCourse(courseId);
    } finally {
      isLoading.value = false;
    }
  }
  

  Future<void> loadMembersByCourse(String courseId) async {
    isLoading.value = true;
    try {
      membersByCourse.value = await useCase.getMembersByCourse(courseId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory({
    required String name,
    required String courseId,
    required int groupingMethod,
    required int groupSize,
  }) async {
    isLoading.value = true;
    try {
      await useCase.addCategory(
        name: name,
        courseId: courseId,
        groupingMethod: groupingMethod,
        groupSize: groupSize,
      );
      await loadCategoriesWithGroups(courseId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(Category category) async {
    isLoading.value = true;
    try {
      await useCase.updateCategory(category);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeCategory(String categoryId, String courseId) async {
    isLoading.value = true;
    try {
      await useCase.removeCategory(categoryId);
      await loadCategoriesWithGroups(courseId);
    } finally {
      isLoading.value = false;
    }
  }
}