import 'package:flutter/material.dart';
import 'package:tugaspab2noval/models/matakuliah_models.dart';
import 'package:tugaspab2noval/services/firebase_service.dart';

class MataKuliahScreen extends StatefulWidget {
  const MataKuliahScreen({super.key});

  @override
  State<MataKuliahScreen> createState() => _MataKuliahScreenState();
}

class _MataKuliahScreenState extends State<MataKuliahScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dosenController = TextEditingController();

  Future<void> _addCourse() async {
    if (_namaController.text.isEmpty || _dosenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Dosen harus diisi')),
      );
      return;
    }

    try {
      final course = MataKuliah(
        id: '',
        nama: _namaController.text,
        dosen: _dosenController.text,
      );

      await _firebaseService.createCourse(course);
      _namaController.clear();
      _dosenController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata kuliah berhasil ditambahkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _dosenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5E35B1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelola Mata Kuliah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MataKuliah>>(
              stream: _firebaseService.getCoursesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E35B1)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final courses = snapshot.data ?? [];

                if (courses.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada mata kuliah'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dosen: ${course.dosen}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Tambah Mata Kuliah Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: 'Nama mata kuliah',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dosenController,
                  decoration: InputDecoration(
                    hintText: 'Nama dosen',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: _addCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'TAMBAH MATA KULIAH',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
