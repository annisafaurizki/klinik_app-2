class Akun {
  String? id;
  String username;
  String password;
  String nama;
  String role;

  Akun({
    this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.role,
  });

  factory Akun.fromJson(Map<String, dynamic> json) => Akun(
    id: json['id']?.toString(),
    username: json['username'] ?? '',
    password: json['password'] ?? '',
    nama: json['nama'] ?? '',
    role: json['role'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'nama': nama,
    'role': role,
  };
}
