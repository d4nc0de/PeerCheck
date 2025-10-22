import 'package:get/get.dart';
import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:f_clean_template/features/auth/domain/use_case/authentication_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController extends GetxController {
  final AuthenticationUseCase useCase;

  AuthenticationController(this.useCase);

  final Rxn<AuthenticationUser> currentUser = Rxn<AuthenticationUser>();
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;

  String? rememberedEmail;
  String? rememberedPassword;

  bool get isLogged => currentUser.value != null;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await useCase.login(email, password);
      currentUser.value = user;

      if (rememberMe.value) {
        await saveRememberedCredentials(email, password);
      } else {
        await clearRememberedCredentials();
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthenticationUser?> signup(String name, String email, String password) async {
    try {
      return await useCase.signup(name, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    await useCase.logout();
    currentUser.value = null;
    await clearRememberedCredentials();
  }

  Future<void> loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool("remember_me") ?? false;

    if (remember) {
      rememberedEmail = prefs.getString("remembered_email");
      rememberedPassword = prefs.getString("remembered_password");
      rememberMe.value = true;
    }
  }

  Future<void> saveRememberedCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("remember_me", true);
    await prefs.setString("remembered_email", email);
    await prefs.setString("remembered_password", password);
  }

  Future<void> clearRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("remember_me");
    await prefs.remove("remembered_email");
    await prefs.remove("remembered_password");
  }

  String get currentUserEmail => currentUser.value?.email ?? '';
  String get currentUserName => currentUser.value?.name ?? '';
}
