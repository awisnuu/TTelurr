class Panen {
  final String id;
  final String kandangId;
  final String kandangNama;
  final int jumlahTelur;
  final DateTime tanggalPanen;
  final String jam;
  final String catatan;
  final String? jenisPanen; // 'pagi' atau 'sore'
  final int? panenSebelumnya; // Panen session sebelumnya (untuk hitung delta)
  final int? sensorSnapshot; // Raw sensor value saat capture

  Panen({
    required this.id,
    required this.kandangId,
    required this.kandangNama,
    required this.jumlahTelur,
    required this.tanggalPanen,
    required this.jam,
    required this.catatan,
    this.jenisPanen,
    this.panenSebelumnya,
    this.sensorSnapshot,
  });

  factory Panen.fromJson(Map<String, dynamic> json) {
    return Panen(
      id: json['id'] ?? '',
      kandangId: json['kandangId'] ?? '',
      kandangNama: json['kandangNama'] ?? '',
      jumlahTelur: json['jumlahTelur'] ?? 0,
      tanggalPanen: DateTime.parse(
        json['tanggalPanen'] ?? DateTime.now().toString(),
      ),
      jam: json['jam'] ?? '',
      catatan: json['catatan'] ?? '',
      jenisPanen: json['jenisPanen'],
      panenSebelumnya: json['panenSebelumnya'],
      sensorSnapshot: json['sensorSnapshot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kandangId': kandangId,
      'kandangNama': kandangNama,
      'jumlahTelur': jumlahTelur,
      'tanggalPanen': tanggalPanen.toIso8601String(),
      'jam': jam,
      'catatan': catatan,
      'jenisPanen': jenisPanen,
      'panenSebelumnya': panenSebelumnya,
      'sensorSnapshot': sensorSnapshot,
    };
  }
}
