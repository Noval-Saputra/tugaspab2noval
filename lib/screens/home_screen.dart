import 'package:flutter/material.dart';
import 'package:tugaspab2noval/models/catatan_models.dart';
import 'package:tugaspab2noval/services/firebase_service.dart';
import 'package:tugaspab2noval/screens/catatan_screens.dart';
import 'package:tugaspab2noval/screens/matakuliah_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final List<Color> _iconColors = [
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.pink,
  ];

  Color _getColorForIndex(int index) {
    return _iconColors[index % _iconColors.length];
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (date == yesterday) {
      return 'Kemarin';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year % 100}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5E35B1),
        leading: PopupMenuButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Kelola Mata Kuliah'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MataKuliahScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        title: const Text(
          'Catatan Kuliah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CatatanSearchDelegate(_firebaseService),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Catatan>>(
        stream: _firebaseService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 187, 146, 33)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final catatanList = snapshot.data ?? [];

          if (catatanList.isEmpty) {
            return const Center(
              child: Text('Tidak ada catatan. Tambahkan catatan baru!'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: catatanList.length,
              itemBuilder: (context, index) {
                final catatan = catatanList[index];
                final color = _getColorForIndex(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CatatanDetailScreen(
                              catatan: catatan,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    catatan.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    catatan.matakuliah,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(catatan.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFAAAAAA),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Edit'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CatatanScreens(
                                          initialCatatan: catatan,
                                        ),
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
                                        content: const Text(
                                            'Apakah Anda yakin ingin menghapus catatan ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _firebaseService
                                                  .deleteNote(catatan.id);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Catatan berhasil dihapus'),
                                                ),
                                              );
                                            },
                                            child: const Text('Hapus',
                                                style: TextStyle(
                                                    color: Colors.red)),
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
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CatatanScreens(),
            ),
          );
        },
        backgroundColor: const Color(0xFF5E35B1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CatatanSearchDelegate extends SearchDelegate {
  final FirebaseService firebaseService;

  CatatanSearchDelegate(this.firebaseService);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Catatan>>(
      future: firebaseService.searchNotes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(child: Text('Tidak ada hasil'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final catatan = results[index];
            return ListTile(
              title: Text(catatan.title),
              subtitle: Text(catatan.matakuliah),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CatatanDetailScreen(
                      catatan: catatan,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox();
  }
}