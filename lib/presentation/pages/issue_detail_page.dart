import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class IssueDetailPage extends StatefulWidget {
  final Map<String, dynamic> issue;

  const IssueDetailPage({super.key, required this.issue});

  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  Future<List<dynamic>>? _commentsFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = _supabase
          .from('issue_comments')
          .select('*, profiles(full_name)')
          .eq('issue_id', widget.issue['id'])
          .order('created_at', ascending: true);
    });
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yorum yapmak için giriş yapmalısınız.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _supabase.from('issue_comments').insert({
        'issue_id': widget.issue['id'],
        'user_id': user.id,
        'content': content,
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yorum gönderilemedi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorName = widget.issue['profiles']?['full_name'] ?? 'İsimsiz Kullanıcı';
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(widget.issue['created_at']).toLocal());

    return Scaffold(
      appBar: AppBar(title: const Text('Sorun Detayı')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ana Sorun Kartı
                  Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green.shade200,
                                child: const Icon(Icons.person, color: Colors.green),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(widget.issue['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          const SizedBox(height: 12),
                          Text(widget.issue['content'], style: const TextStyle(fontSize: 16, height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Yorumlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  
                  // Yorumlar Listesi
                  FutureBuilder<List<dynamic>>(
                    future: _commentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Yorumlar yüklenemedi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                        );
                      }

                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: Text('İlk yorumu siz yapın!', style: TextStyle(color: Colors.grey))),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final commentAuthor = comment['profiles']?['full_name'] ?? 'İsimsiz Kullanıcı';
                          final commentDate = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(comment['created_at']).toLocal());

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blueGrey,
                                  child: Icon(Icons.person, size: 16, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(commentAuthor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            Text(commentDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(comment['content']),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Yorum Yazma Alanı
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuzu yazın...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green,
                  child: _isSubmitting
                      ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _addComment,
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
