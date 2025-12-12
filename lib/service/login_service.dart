import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../helpers/user_info.dart';

class LoginService {
  // pakai baseUrl pasien+akun
  final ApiClient _api = ApiClient(dioPasienAkun);

  Future<bool> login(String username, String password) async {
    try {
      // contoh URL: /akun?username=admin&password=admin
      final Response response = await _api.get(
        'akun?username=$username&password=$password',
      );

      final List data = response.data as List;

      if (data.isEmpty) {
        // username/password salah
        return false;
      }

      final Map<String, dynamic> user = data.first as Map<String, dynamic>;

      final info = UserInfo();
      await info.setToken(user['id'].toString());
      await info.setUserID(user['id'].toString());
      await info.setUsername(user['username']?.toString() ?? '');
      await info.setNama(user['nama']?.toString() ?? '');
      await info.setRole(user['role']?.toString() ?? '');

      return true;
    } catch (e) {
      // boleh kamu ganti jadi SnackBar / dialog kalau mau
      print("Login error: $e");
      return false;
    }
  }
}
