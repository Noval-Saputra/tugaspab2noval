class MataKuliah {
  final String id;
  final String nama;
  final String dosen;

  MataKuliah({
    required this.id,
    required this.nama,
    required this.dosen,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      id: json['id'] ?? '',
      nama: json['nama'] ?? json['name'] ?? '',
      dosen: json['dosen'] ?? json['lecturer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nama,
      'lecturer': dosen,
    };
  }
}