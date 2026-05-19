import 'package:flutter/material.dart';
import 'package:tugaspab2noval/models/catatan_model.dart';
import 'package:tugaspab2noval/models/matakuliah_model.dart';
import 'package:tugaspab2noval/screens/matakuliah_screen.dart'; // Perhatikan nama class di dalam file ini
import 'package:tugaspab2noval/services/firebase_service.dart';

class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  MKModel? _selectedMK;

  void _submitNote() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMK == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih mata kuliah terlebih dahulu!')),
        );
        return;
      }

      CatatanModel newCatatan = CatatanModel(
        id: null,
        idMK: _selectedMK!.id!,
        namaMK: _selectedMK!.nama,
        judul: _judulController.text.trim(),
        isi: _isiController.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _firebaseService.addCatatan(newCatatan);

      _judulController.clear();
      _isiController.clear();

      setState(() {
        _selectedMK = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil disimpan!')),
        );
      }
    }
  }

  String _formatTimestamp(int timestamp) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kuliah Realtime'),
        actions: [
          IconButton(
            icon: const Icon(Icons.class_),
            tooltip: 'Kelola Mata Kuliah',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MatakuliahScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  StreamBuilder<List<MKModel>>(
                    stream: _firebaseService.getMKs(), // Pastikan nama method ini ada di firebase_service.dart
                    builder: (context, snapshot) {
                      List<MKModel> courses = snapshot.data ?? [];

                      return DropdownButtonFormField<MKModel>(
                        value: _selectedMK,
                        hint: const Text('Pilih Mata Kuliah'),
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: courses.map((MKModel course) {
                          return DropdownMenuItem<MKModel>(
                            value: course,
                            child: Text(course.nama),
                          );
                        }).toList(),
                        onChanged: (MKModel? value) {
                          setState(() {
                            _selectedMK = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Mata kuliah wajib dipilih' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _judulController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Catatan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _isiController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Isi Catatan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Isi catatan tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _submitNote,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Catatan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),           
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }
}