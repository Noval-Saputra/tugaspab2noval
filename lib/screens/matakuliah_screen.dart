import 'package:flutter/material.dart';
import 'package:tugaspab2noval/models/matakuliah_model.dart';
import 'package:tugaspab2noval/services/firebase_service.dart';



class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _dosenController = TextEditingController();

  void _submitCourse() async {
    if (_formKey.currentState!.validate()) {
      MKModel matakuliahbaru = MKModel(
        nama: _namaController.text.trim(),
        dosen: _dosenController.text.trim(),
      );

      await _firebaseService.addMK(matakuliahbaru);
      
      _namaController.clear();
      _dosenController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata Kuliah berhasil ditambahkan!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Mata Kuliah')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: 'Nama Mata Kuliah', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Nama mata kuliah tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dosenController,
                    decoration: const InputDecoration(labelText: 'Nama Dosen', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Nama dosen tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _submitCourse,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Mata Kuliah'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text('Daftar Mata Kuliah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<MKModel>>(
                stream: _firebaseService.getMKs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada mata kuliah.'));
                  }

                  final courses = snapshot.data!;
                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: Text(courses[index].nama),
                          subtitle: Text('Dosen: ${courses[index].dosen}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}