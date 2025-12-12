import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/akun.dart';

class AkunService {
  // pakai baseUrl pasien/akun
  final ApiClient _api = ApiClient(dioPasienAkun);

  Future<List<Akun>> listData() async {
    final Response response = await _api.get('akun');
    final List data = response.data as List;
    return data.map((e) => Akun.fromJson(e)).toList();
  }

  Future<Akun> simpan(Akun akun) async {
    final Response response = await _api.post('akun', akun.toJson());
    return Akun.fromJson(response.data);
  }

  Future<Akun> ubah(Akun akun) async {
    if (akun.id == null) {
      throw Exception('ID akun tidak boleh null untuk update');
    }
    final Response response = await _api.put('akun/${akun.id}', akun.toJson());
    return Akun.fromJson(response.data);
  }

  Future<void> hapus(String id) async {
    await _api.delete('akun/$id');
  }

  Future<Akun> getById(String id) async {
    final Response response = await _api.get('akun/$id');
    return Akun.fromJson(response.data);
  }
}
