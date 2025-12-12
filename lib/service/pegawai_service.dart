import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/pegawai.dart';

class PegawaiService {
  final ApiClient _api = ApiClient(dioKlinikUtama); // sama dengan Poli

  Future<List<Pegawai>> listData() async {
    final Response response = await _api.get(
      '/pegawai',
    ); // nama resource di MockAPI
    final List data = response.data as List;
    return data.map((json) => Pegawai.fromJson(json)).toList();
  }

  Future<Pegawai> simpan(Pegawai pegawai) async {
    final Response response = await _api.post('/pegawai', pegawai.toJson());
    return Pegawai.fromJson(response.data);
  }

  Future<Pegawai> ubah(Pegawai pegawai, String id) async {
    final Response response = await _api.put('/pegawai/$id', pegawai.toJson());
    return Pegawai.fromJson(response.data);
  }

  Future<Pegawai> getById(String id) async {
    final Response response = await _api.get('/pegawai/$id');
    return Pegawai.fromJson(response.data);
  }

  Future<Pegawai> hapus(Pegawai pegawai) async {
    final Response response = await _api.delete('/pegawai/${pegawai.id}');
    return Pegawai.fromJson(response.data);
  }
}
