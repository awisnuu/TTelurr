class Kandang {
  final String id;
  final String nama;
  final int jumlahAyam;
  final DateTime dibuat;
  final String? infraPath;

  Kandang({
    required this.id,
    required this.nama,
    required this.jumlahAyam,
    required this.dibuat,
    this.infraPath,
  });

  factory Kandang.fromJson(Map<String, dynamic> json) {
    return Kandang(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      jumlahAyam: json['jumlahAyam'] ?? 0,
      dibuat: DateTime.parse(json['dibuat'] ?? DateTime.now().toString()),
      infraPath: json['infraPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jumlahAyam': jumlahAyam,
      'dibuat': dibuat.toIso8601String(),
      'infraPath': infraPath,
    };
  }
}
