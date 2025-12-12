class Kunjungan {
  String? id;
  String tanggal;
  String nomorRm;
  String namaPasien;
  String poli;
  String dokter;
  String keluhan;
  String diagnosa;
  String resep;

  // ====== REKAM MEDIS DETAIL ======
  String tekananDarah; // misal: 120/80
  String suhu; // misal: 36.7
  String berat; // kg
  String tinggi; // cm
  String alergi; // boleh kosong
  String catatan; // catatan tambahan dokter

  Kunjungan({
    this.id,
    required this.tanggal,
    required this.nomorRm,
    required this.namaPasien,
    required this.poli,
    required this.dokter,
    required this.keluhan,
    required this.diagnosa,
    required this.resep,
    required this.tekananDarah,
    required this.suhu,
    required this.berat,
    required this.tinggi,
    required this.alergi,
    required this.catatan,
  });

  factory Kunjungan.fromJson(Map<String, dynamic> json) {
    return Kunjungan(
      id: json['id'],
      tanggal: json['tanggal'] ?? '',
      nomorRm: json['nomor_rm'] ?? '',
      namaPasien: json['nama_pasien'] ?? '',
      poli: json['poli'] ?? '',
      dokter: json['dokter'] ?? '',
      keluhan: json['keluhan'] ?? '',
      diagnosa: json['diagnosa'] ?? '',
      resep: json['resep'] ?? '',

      // kalau data lama belum punya kolom ini, kasih default ''
      tekananDarah: json['tekanan_darah'] ?? '',
      suhu: json['suhu'] ?? '',
      berat: json['berat'] ?? '',
      tinggi: json['tinggi'] ?? '',
      alergi: json['alergi'] ?? '',
      catatan: json['catatan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tanggal": tanggal,
      "nomor_rm": nomorRm,
      "nama_pasien": namaPasien,
      "poli": poli,
      "dokter": dokter,
      "keluhan": keluhan,
      "diagnosa": diagnosa,
      "resep": resep,

      "tekanan_darah": tekananDarah,
      "suhu": suhu,
      "berat": berat,
      "tinggi": tinggi,
      "alergi": alergi,
      "catatan": catatan,
    };
  }
}
