import 'package:firebase_database/firebase_database.dart';
import 'package:tugaspab2noval/models/matakuliah_model.dart';
import 'package:tugaspab2noval/models/catatan_model.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // create MK
  Future<void> addMK(MKModel MK) async {
    await _dbRef.child('MKs').push().set(MK.toMap());
  }

  // retrieve MK
  Stream<List<MKModel>> getMKs() {
    return _dbRef.child('MKs').onValue.map((event) {
      final Map<dynamic, dynamic>? snapshotValue =
          event.snapshot.value as Map<dynamic, dynamic>?;

      List<MKModel> MKs = [];

      if (snapshotValue != null) {
        snapshotValue.forEach((key, value) {
          MKs.add(
            MKModel.fromMap(
              key,
              Map<String, dynamic>.from(value),
            ),
          );
        });
      }

      return MKs;
    });
  }

  // create Catatan
  Future<void> addCatatan(CatatanModel catatan) async {
    await _dbRef.child('catatan').push().set(catatan.toMap());
  }

  // retrieve Catatan
  Stream<List<CatatanModel>> getCatatan() {
    return _dbRef.child('catatan').onValue.map((event) {
      final Map<dynamic, dynamic>? snapshotValue =
          event.snapshot.value as Map<dynamic, dynamic>?;

      List<CatatanModel> catatan = [];

      if (snapshotValue != null) {
        snapshotValue.forEach((key, value) {
          catatan.add(
            CatatanModel.fromMap(
              key,
              Map<String, dynamic>.from(value),
            ),
          );
        });
      }

      catatan.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return catatan;
    });
  }
}