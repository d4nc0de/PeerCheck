import 'package:f_clean_template/features/auth/ui/pages/login_page.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:f_clean_template/features/auth/data/datasources/remote/Remote_authentication_source_service.dart';

class RemoteLogoutService {
  final http.Client _client;
  final String _baseUrl;
  final String _dbName;
  final RemoteAuthenticationSourceService _auth;

  RemoteLogoutService({
    required http.Client client,
    required String baseUrl,
    required String dbName,
    required RemoteAuthenticationSourceService auth,
  })  : _client = client,
        _baseUrl = baseUrl,
        _dbName = dbName,
        _auth = auth;

  Uri _logoutUri() => Uri.parse('$_baseUrl/auth/$_dbName/logout');

  Future<void> logout() async {
    final token = await _auth.getAccessToken();
    if (token == null){
      Get.to(LoginPage());
       return;
    } 

    final response = await _client.post(
      _logoutUri(),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Fallo en logout remoto: ${response.statusCode} ${response.body}");
    }

    // Limpia tokens locales si aplica
    await _auth.logout();
  }
}
