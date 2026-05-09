import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final _supabase = Supabase.instance.client;
  Future<List<dynamic>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _notificationsFuture = _supabase
            .from('notifications')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
      });
      // Tüm bildirimleri okundu olarak işaretle
      _supabase.from('notifications').update({'is_read': true}).eq('user_id', user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bildirimler yüklenemedi: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz bildiriminiz yok.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(notif['created_at']).toLocal());
              final isRead = notif['is_read'] == true;

              return Card(
                elevation: isRead ? 0 : 2,
                color: isRead ? Colors.grey.shade50 : Colors.blue.shade50,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isRead ? Colors.grey.shade300 : Colors.blue.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRead ? Colors.grey.shade300 : Colors.blue,
                    child: Icon(Icons.notifications, color: isRead ? Colors.grey.shade600 : Colors.white),
                  ),
                  title: Text(notif['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif['content'], style: const TextStyle(height: 1.3)),
                      const SizedBox(height: 8),
                      Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
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
