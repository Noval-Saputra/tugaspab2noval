import 'package:flutter/material.dart';
import 'package:tugaspab2noval/models/catatan_model.dart';
import 'package:tugaspab2noval/models/matakuliah_model.dart';
import 'package:tugaspab2noval/screens/matakuliah_screen.dart';
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
        id: _selectedMK!.id!,
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
              MaterialPageRoute(builder: (context) => const CourseScreen()),
            ),
          )
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
                    stream: _firebaseService.getMKs(),
                    builder: (context, snapshot) {
                      List<MKModel> courses = snapshot.data ?? [];
                      return DropdownButtonFormField<MKModel>(
                        value: _selectedMK,
                        hint: const Text('Pilih Mata Kuliah'),
                        isExpanded: true,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
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
                        validator: (value) => value == null ? 'Mata kuliah wajib dipilih' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _judulController,
                    decoration: const InputDecoration(labelText: 'Judul Catatan', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _isiController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Isi Catatan', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Isi catatan tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _submitNote,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Catatan'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text('Daftar Catatan Kuliah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<CatatanModel>>(
                stream: _firebaseService.getCatatan(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada catatan kuliah.'));
                  }

                  final notes = snapshot.data!;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(notes[index].judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notes[index].isi),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(notes[index].namaMK, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.teal.withOpacity(0.1),
                                  ),
                                  Text(
                                    _formatTimestamp(notes[index].timestamp),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
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