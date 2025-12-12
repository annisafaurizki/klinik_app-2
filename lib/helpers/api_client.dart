import 'package:dio/dio.dart';

// === BASE URL 1: poli & pegawai ===
final Dio dioKlinikUtama = Dio(
  BaseOptions(
    baseUrl: 'https://69204ebe31e684d7bfcc882e.mockapi.io/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ),
);

// === BASE URL 2: pasien & akun (login) ===
final Dio dioPasienAkun = Dio(
  BaseOptions(
    baseUrl: 'https://6932e5ade5a9e342d2713abb.mockapi.io/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ),
);
// 🔹 Base URL khusus JADWAL (TAMBAHAN BARU)
final Dio dioJadwal = Dio(
  BaseOptions(
    baseUrl: 'https://6933ad1d4090fe3bf01db9ff.mockapi.io/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ),
);

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(Uri.encodeFull(path));
      return response;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      final response = await _dio.post(Uri.encodeFull(path), data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      final response = await _dio.put(Uri.encodeFull(path), data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(Uri.encodeFull(path));
      return response;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
