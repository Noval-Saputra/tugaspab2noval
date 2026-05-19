import 'package:flutter/material.dart';
import 'package:tugaspab2noval/models/catatan_models.dart';
import 'package:tugaspab2noval/models/matakuliah_models.dart';
import 'package:tugaspab2noval/services/firebase_service.dart';

class CatatanScreens extends StatefulWidget {
  final Catatan? initialCatatan;

  const CatatanScreens({super.key, this.initialCatatan});

  @override
  State<CatatanScreens> createState() => _CatatanScreensState();
}

class _CatatanScreensState extends State<CatatanScreens> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedCourseId;
  String? _selectedCourseName;
  final FirebaseService _firebaseService = FirebaseService();
  List<MataKuliah> _matakuliahList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialCatatan?.title ?? '');
    _contentController = TextEditingController(text: widget.initialCatatan?.content ?? '');
    _selectedCourseId = widget.initialCatatan?.courseId;
    _selectedCourseName = widget.initialCatatan?.matakuliah;
    _loadMatakuliah();
  }

  Future<void> _loadMatakuliah() async {
    try {
      final courses = await _firebaseService.getCourses();
      setState(() {
        _matakuliahList = courses;
        if (_selectedCourseId == null && courses.isNotEmpty) {
          _selectedCourseId = courses.first.id;
          _selectedCourseName = courses.first.nama;
        }
      });
    } catch (e) {
      print('Error loading matakuliah: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _saveCatatan() async {
    if (_titleController.text.isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Mata Kuliah harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final catatan = Catatan(
        id: widget.initialCatatan?.id ?? '',
        courseId: _selectedCourseId ?? '',
        title: _titleController.text,
        content: _contentController.text,
        matakuliah: _selectedCourseName ?? '',
        createdAt: widget.initialCatatan?.createdAt ?? DateTime.now(),
      );

      if (widget.initialCatatan == null) {
        // Create new
        await _firebaseService.createNote(catatan);
      } else {
        // Update existing
        await _firebaseService.updateNote(catatan);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialCatatan == null
                ? 'Catatan berhasil dibuat'
                : 'Catatan berhasil diperbarui'),
          ),
        );
      }
    } catch (e) {
      print('Error saving catatan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 181, 184, 50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initialCatatan == null ? 'Tambah Catatan' : 'Edit Catatan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Mata Kuliah',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: _selectedCourseId,
                    items: _matakuliahList.map((MataKuliah course) {
                      return DropdownMenuItem<String>(
                        value: course.id,
                        child: Text(course.nama),
                        onTap: () {
                          _selectedCourseName = course.nama;
                        },
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCourseId = newValue;
                      });
                    },
                    hint: const Text('Pilih Mata Kuliah'),
                  ),
                ),
              ),
              if (_matakuliahList.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tidak ada mata kuliah. Buat mata kuliah terlebih dahulu.',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Judul Catatan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul catatan',
                  filled: true,
                  fillColor: Colors.white,
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
                    borderSide: const BorderSide(color: Color.fromARGB(255, 211, 201, 60), width: 2),
                  ),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              const Text(
                'Isi Catatan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Masukkan isi catatan',
                  filled: true,
                  fillColor: Colors.white,
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
                maxLines: 6,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading || _matakuliahList.isEmpty ? null : _saveCatatan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Menyimpan...' : 'SIMPAN CATATAN',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatatanDetailScreen extends StatelessWidget {
  final Catatan catatan;
  final FirebaseService _firebaseService = FirebaseService();

  CatatanDetailScreen({super.key, required this.catatan});

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
          'Detail Catatan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CatatanScreens(initialCatatan: catatan),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Hapus'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Catatan'),
                      content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _firebaseService.deleteNote(catatan.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Catatan berhasil dihapus'),
                              ),
                            );
                          },
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catatan.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5E35B1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              catatan.matakuliah,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5E35B1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${catatan.createdAt.day}/${catatan.createdAt.month}/${catatan.createdAt.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Isi Catatan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        catatan.content.isEmpty ? 'Tidak ada isi catatan' : catatan.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}