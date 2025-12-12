class Jadwal {
  String? id;
  String namaDokter;
  String poli;
  String hari;
  String jamMulai;
  String jamSelesai;
  bool aktif;

  Jadwal({
    this.id,
    required this.namaDokter,
    required this.poli,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.aktif = true,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id']?.toString(), // ← PENTING: baca id dari MockAPI
      namaDokter: json['namaDokter'] ?? '',
      poli: json['poli'] ?? '',
      hari: json['hari'] ?? '',
      jamMulai: json['jamMulai'] ?? '',
      jamSelesai: json['jamSelesai'] ?? '',
      aktif: json['aktif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id sengaja tidak dikirim, karena MockAPI pakai id di URL
      'namaDokter': namaDokter,
      'poli': poli,
      'hari': hari,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'aktif': aktif,
    };
  }
}
