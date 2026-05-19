class CatatanModel {
  String? id;
  String idMK;
  String namaMK;
  String judul;
  String isi;
  int timestamp;

  CatatanModel({
    this.id,
    required this.idMK,
    required this.namaMK,
    required this.judul,
    required this.isi,
    required this.timestamp,
  });

  factory CatatanModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CatatanModel(
      id: id,
      idMK: map['idMK'] ?? '',
      namaMK: map['namaMK'] ?? '',
      judul: map['judul'] ?? '',
      isi: map['isi'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idMK': idMK,
      'namaMK': namaMK,
      'judul': judul,
      'isi': isi,
      'timestamp': timestamp,
    };
  }
}