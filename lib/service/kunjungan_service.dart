import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/kunjungan.dart';

class KunjunganService {
  // sesuaikan dengan dio yang kamu pakai untuk base URL kunjungan
  final ApiClient _api = ApiClient(dioJadwal);

  Future<List<Kunjungan>> listData() async {
    final Response response = await _api.get('kunjungan');
    final List data = response.data as List;
    return data.map((e) => Kunjungan.fromJson(e)).toList();
  }

  Future<Kunjungan> simpan(Kunjungan k) async {
    final Response response = await _api.post('kunjungan', k.toJson());
    return Kunjungan.fromJson(response.data);
  }

  Future<Kunjungan> ubah(Kunjungan k, String id) async {
    final Response response = await _api.put('kunjungan/$id', k.toJson());
    return Kunjungan.fromJson(response.data);
  }

  Future<Kunjungan> getById(String id) async {
    final Response response = await _api.get('kunjungan/$id');
    return Kunjungan.fromJson(response.data);
  }

  Future<void> hapus(Kunjungan k) async {
    final id = k.id;
    if (id == null) throw Exception('Id kunjungan null');
    await _api.delete('kunjungan/$id');
  }

  /// Ambil daftar kunjungan berdasarkan nomor_rm.
  /// Kalau gagal (404 / error lain) → anggap belum pernah berkunjung → []
  Future<List<Kunjungan>> listByNomorRm(String nomorRm) async {
    try {
      // kalau ApiClient belum support queryParameters, pakai cara ini
      final Response response = await _api.get('kunjungan?nomor_rm=$nomorRm');

      if (response.data is List) {
        final List data = response.data as List;
        return data.map((e) => Kunjungan.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // Di mode debug boleh pakai print/debugPrint kalau mau lihat error
      // debugPrint('Error riwayat kunjungan ($nomorRm): $e');
      return [];
    }
  }
}
