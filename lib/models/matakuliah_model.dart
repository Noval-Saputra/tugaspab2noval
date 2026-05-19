class MKModel {
  String? id;
  String nama;
  String dosen;

  MKModel({this.id, required this.nama, required this.dosen});


  factory MKModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MKModel(
      id: id,
      nama: map['nama'] ?? '',
      dosen: map['dosen'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'dosen': dosen,
    };
  }
}