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
      final Map<dynamic, dynamic>? snapshotValue = event.snapshot.value as Map<dynamic, dynamic>?;
      List<MKModel> MKs = [];
      if (snapshotValue != null) {
        snapshotValue.forEach((key, value) {
          MKs.add(MKModel.fromMap(
            key,
            value));
        });
      }
      return MKs;
    });
  }

  // create Catatan
  Future<void> addCatatan(CatatanModel note) async {
    await _dbRef.child('notes').push().set(note.toMap());
  }

  // retrieve Catatan 
  Stream<List<CatatanModel>> getNotes() {
    return _dbRef.child('notes').onValue.map((event) {
      final Map<dynamic, dynamic>? snapshotValue = event.snapshot.value as Map<dynamic, dynamic>?;
      List<CatatanModel> notes = [];
      if (snapshotValue != null) {
        snapshotValue.forEach((key, value) {
          notes.add(CatatanModel.fromMap(
            key,
            value));
        });
      }

      notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notes;
    });
  }
}