class Penjadwalan {
  final String id;
  final String kandangId;
  final String kandangNama;
  final String jam;
  final String durasi;
  final String keterangan;
  final bool aktif;

  Penjadwalan({
    required this.id,
    required this.kandangId,
    required this.kandangNama,
    required this.jam,
    required this.durasi,
    required this.keterangan,
    required this.aktif,
  });

  factory Penjadwalan.fromJson(Map<String, dynamic> json) {
    return Penjadwalan(
      id: json['id'] ?? '',
      kandangId: json['kandangId'] ?? '',
      kandangNama: json['kandangNama'] ?? '',
      jam: json['jam'] ?? '09:00',
      durasi: json['durasi'] ?? '30 menit',
      keterangan: json['keterangan'] ?? '',
      aktif: json['aktif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kandangId': kandangId,
      'kandangNama': kandangNama,
      'jam': jam,
      'durasi': durasi,
      'keterangan': keterangan,
      'aktif': aktif,
    };
  }
}
