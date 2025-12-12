import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/jadwal.dart';

class JadwalService {
  // pakai dioJadwal dari api_client.dart
  final ApiClient _api = ApiClient(dioJadwal);

  // GET /jadwal
  Future<List<Jadwal>> listData() async {
    final Response response = await _api.get('jadwal');
    final List data = response.data as List;
    return data
        .map((json) => Jadwal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // POST /jadwal
  Future<Jadwal> simpan(Jadwal jadwal) async {
    final body = jadwal.toJson();
    final Response response = await _api.post('jadwal', body);
    return Jadwal.fromJson(response.data as Map<String, dynamic>);
  }

  // PUT /jadwal/{id}
  Future<Jadwal> ubah(Jadwal jadwal, String id) async {
    final body = jadwal.toJson();
    final Response response = await _api.put('jadwal/$id', body);
    return Jadwal.fromJson(response.data as Map<String, dynamic>);
  }

  // GET /jadwal/{id}
  Future<Jadwal> getById(String id) async {
    final Response response = await _api.get('jadwal/$id');
    return Jadwal.fromJson(response.data as Map<String, dynamic>);
  }

  // DELETE /jadwal/{id}
  Future<void> hapus(Jadwal jadwal) async {
    final id = jadwal.id;
    if (id == null) {
      throw Exception('Id jadwal null');
    }
    await _api.delete('jadwal/$id');
  }
}
