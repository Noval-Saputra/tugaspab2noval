import 'package:firebase_database/firebase_database.dart';
import 'package:tugaspab2noval/models/catatan_models.dart';
import 'package:tugaspab2noval/models/matakuliah_models.dart';

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // References
  DatabaseReference get coursesRef => _database.ref('courses');
  DatabaseReference get notesRef => _database.ref('notes');

  // ============ COURSES (MATA KULIAH) ============

  /// Create new mata kuliah
  Future<void> createCourse(MataKuliah course) async {
    try {
      final newCourseRef = coursesRef.push();
      await newCourseRef.set({
        'name': course.nama,
        'lecturer': course.dosen,
      });
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  /// Get all mata kuliah as stream
  Stream<List<MataKuliah>> getCoursesStream() {
    return coursesRef.onValue.map((event) {
      final courses = <MataKuliah>[];
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        data.forEach((key, value) {
          if (value is Map) {
            courses.add(MataKuliah(
              id: key,
              nama: value['name'] ?? '',
              dosen: value['lecturer'] ?? '',
            ));
          }
        });
      }
      return courses;
    });
  }

  /// Get all mata kuliah (one-time read)
  Future<List<MataKuliah>> getCourses() async {
    try {
      final snapshot = await coursesRef.get();
      final courses = <MataKuliah>[];
      if (snapshot.value != null) {
        final data = snapshot.value as Map;
        data.forEach((key, value) {
          if (value is Map) {
            courses.add(MataKuliah(
              id: key,
              nama: value['name'] ?? '',
              dosen: value['lecturer'] ?? '',
            ));
          }
        });
      }
      return courses;
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  // ============ NOTES (CATATAN) ============

  /// Create new catatan
  Future<void> createNote(Catatan note) async {
    try {
      final newNoteRef = notesRef.push();
      await newNoteRef.set({
        'courseId': note.courseId,
        'courseName': note.matakuliah,
        'title': note.title,
        'content': note.content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  /// Get all notes as stream
  Stream<List<Catatan>> getNotesStream() {
    return notesRef
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final notes = <Catatan>[];
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        // Convert to list and reverse to show newest first
        final entries = data.entries.toList()..sort((a, b) {
          final timeA = (a.value['timestamp'] ?? 0) as int;
          final timeB = (b.value['timestamp'] ?? 0) as int;
          return timeB.compareTo(timeA);
        });

        for (var entry in entries) {
          if (entry.value is Map) {
            final value = entry.value as Map;
            notes.add(Catatan(
              id: entry.key,
              courseId: value['courseId'] ?? '',
              matakuliah: value['courseName'] ?? '',
              title: value['title'] ?? '',
              content: value['content'] ?? '',
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                (value['timestamp'] ?? 0) as int,
              ),
            ));
          }
        }
      }
      return notes;
    });
  }

  /// Get all notes (one-time read)
  Future<List<Catatan>> getNotes() async {
    try {
      final snapshot = await notesRef.get();
      final notes = <Catatan>[];
      if (snapshot.value != null) {
        final data = snapshot.value as Map;
        final entries = data.entries.toList()..sort((a, b) {
          final timeA = (a.value['timestamp'] ?? 0) as int;
          final timeB = (b.value['timestamp'] ?? 0) as int;
          return timeB.compareTo(timeA);
        });

        for (var entry in entries) {
          if (entry.value is Map) {
            final value = entry.value as Map;
            notes.add(Catatan(
              id: entry.key,
              courseId: value['courseId'] ?? '',
              matakuliah: value['courseName'] ?? '',
              title: value['title'] ?? '',
              content: value['content'] ?? '',
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                (value['timestamp'] ?? 0) as int,
              ),
            ));
          }
        }
      }
      return notes;
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  /// Update catatan
  Future<void> updateNote(Catatan note) async {
    try {
      await notesRef.child(note.id).update({
        'title': note.title,
        'content': note.content,
        'courseName': note.matakuliah,
        'courseId': note.courseId,
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  /// Delete catatan
  Future<void> deleteNote(String noteId) async {
    try {
      await notesRef.child(noteId).remove();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Search notes by title
  Future<List<Catatan>> searchNotes(String query) async {
    final notes = await getNotes();
    if (query.isEmpty) return notes;
    return notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.matakuliah.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
