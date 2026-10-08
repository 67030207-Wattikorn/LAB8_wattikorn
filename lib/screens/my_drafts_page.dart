import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../repositories/listing_draft_repository.dart';

class MyDraftsPage extends StatefulWidget {
  final ListingDraftRepository repository;

  const MyDraftsPage({
    super.key,
    required this.repository,
  });

  @override
  State<MyDraftsPage> createState() => _MyDraftsPageState();
}

class _MyDraftsPageState extends State<MyDraftsPage> {
  late Future<List<ListingDraftRow>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  void _loadDrafts() {
    _draftsFuture = widget.repository.getAllDrafts();
  }

  Future<void> _deleteDraft(int id) async {
    await widget.repository.deleteDraft(id);

    if (!mounted) return;

    setState(() {
      _loadDrafts();
    });
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();

    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ร่างประกาศของฉัน'),
      ),

      body: FutureBuilder<List<ListingDraftRow>>(
        future: _draftsFuture,

        builder: (context, snapshot) {
          // กำลังโหลด
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'เกิดข้อผิดพลาด\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final drafts = snapshot.data ?? [];

          // ไม่มีร่าง
          if (drafts.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีร่างประกาศ',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // มีร่าง
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,

            itemBuilder: (context, index) {
              final draft = drafts[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),

                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.description,
                    ),
                  ),

                  title: Text(
                    draft.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '${draft.category}\n'
                    'แก้ไขล่าสุด: '
                    '${_formatDate(draft.updatedAt)}',
                  ),

                  isThreeLine: true,

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),

                    onPressed: () async {
                      final confirm =
                          await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'ลบร่างประกาศ',
                            ),
                            content: const Text(
                              'ต้องการลบร่างประกาศนี้หรือไม่?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    false,
                                  );
                                },
                                child:
                                    const Text('ยกเลิก'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    true,
                                  );
                                },
                                child:
                                    const Text('ลบ'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await _deleteDraft(
                          draft.id,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}