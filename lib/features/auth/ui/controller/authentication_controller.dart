import 'package:get/get.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/use_case/authentication_usecase.dart';

class AuthenticationController extends GetxController {
  final AuthenticationUseCase useCase;

  AuthenticationController(this.useCase);

  final Rxn<AuthenticationUser> currentUser = Rxn<AuthenticationUser>();
  final RxBool isLoading = false.obs;

  bool get isLogged => currentUser.value != null;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await useCase.login(email, password);
      currentUser.value = user;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final user = await useCase.signup(name, email, password);
      currentUser.value = user;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    await useCase.logout();
    currentUser.value = null;
  }
}
