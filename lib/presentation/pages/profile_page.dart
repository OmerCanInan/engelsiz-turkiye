import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(user?.email ?? 'E-posta bulunamadı', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Rol: Kullanıcı', style: TextStyle(color: Colors.grey)), // Gelecekte DB'den çekilecek
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => AuthService().signOut(),
                child: const Text('ÇIKIŞ YAP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
