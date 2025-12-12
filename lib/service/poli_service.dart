import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';

class PoliService {
  // pakai base URL project 1 (poli & pegawai)
  final ApiClient _api = ApiClient(dioKlinikUtama);

  Future<List<Poli>> listData() async {
    final Response response = await _api.get(
      '/poli',
    ); // resource di MockAPI: poli
    final List data = response.data as List;
    return data.map((json) => Poli.fromJson(json)).toList();
  }

  Future<Poli> simpan(Poli poli) async {
    final Response response = await _api.post('/poli', poli.toJson());
    return Poli.fromJson(response.data);
  }

  Future<Poli> ubah(Poli poli, String id) async {
    final Response response = await _api.put('/poli/$id', poli.toJson());
    return Poli.fromJson(response.data);
  }

  Future<Poli> getById(String id) async {
    final Response response = await _api.get('/poli/$id');
    return Poli.fromJson(response.data);
  }

  Future<Poli> hapus(Poli poli) async {
    final Response response = await _api.delete('/poli/${poli.id}');
    return Poli.fromJson(response.data);
  }
}
