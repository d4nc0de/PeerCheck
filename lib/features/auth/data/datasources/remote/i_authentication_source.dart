import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';

abstract class IAuthenticationSource {
  Future<AuthenticationUser> login(String email, String password);
  Future<AuthenticationUser> signup(String name, String email, String password);
  Future<void> logout();
  AuthenticationUser? getCurrentUser();
}
