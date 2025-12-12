import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';

class PasienService {
  // pakai baseUrl pasien + akun
  final ApiClient _api = ApiClient(dioPasienAkun);

  Future<List<Pasien>> listData() async {
    final Response response = await _api.get('pasien');
    final List data = response.data as List;
    final List<Pasien> result = data
        .map((json) => Pasien.fromJson(json))
        .toList();
    return result;
  }

  Future<Pasien> simpan(Pasien pasien) async {
    final body = pasien.toJson();
    final Response response = await _api.post('pasien', body);
    final Pasien result = Pasien.fromJson(response.data);
    return result;
  }

  Future<Pasien> ubah(Pasien pasien, String id) async {
    final body = pasien.toJson();
    final Response response = await _api.put('pasien/$id', body);
    final Pasien result = Pasien.fromJson(response.data);
    return result;
  }

  Future<Pasien> getById(String id) async {
    final Response response = await _api.get('pasien/$id');
    final Pasien result = Pasien.fromJson(response.data);
    return result;
  }

  Future<Pasien> hapus(Pasien pasien) async {
    final Response response = await _api.delete('pasien/${pasien.id}');
    final Pasien result = Pasien.fromJson(response.data);
    return result;
  }
}
