class Poli {
  String? id;
  String namaPoli;

  Poli({this.id, required this.namaPoli});

  factory Poli.fromJson(Map<String, dynamic> json) {
    return Poli(id: json["id"], namaPoli: json["nama_poli"]);
  }

  Map<String, dynamic> toJson() {
    return {"nama_poli": namaPoli};
  }
}
