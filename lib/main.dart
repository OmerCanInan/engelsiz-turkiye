import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/supabase_config.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/employment_page.dart';
import 'presentation/pages/education_page.dart';
import 'presentation/pages/daily_life_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/admin_panel_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
    );
  } catch (e) {
    debugPrint('Supabase Başlatma Hatası: $e');
  }

  runApp(const ProviderScope(child: ErisilebilirTurkiyeApp()));
}

class ErisilebilirTurkiyeApp extends StatelessWidget {
  const ErisilebilirTurkiyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erişilebilir Türkiye',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final session = snapshot.data?.session;
        if (session != null) {
          // ADMIN Kontrolü (Hızlı Check)
          if (session.user.email == 'admin@erisimturkiye.com') {
            return const AdminPanelPage();
          }

          // Kullanıcı giriş yaptı ama Şirket/Kullanıcı onay durumu nedir?
          return FutureBuilder(
            future: Supabase.instance.client.from('profiles').select('role, approval_status').eq('id', session.user.id).maybeSingle(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>?> profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              if (profileSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Veritabanı Şema Hatası: ${profileSnapshot.error} \n\nLütfen Supabase panelinden company_description ve approval_status sütunlarını eklediğinizden emin olun.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                );
              }
              
              if (profileSnapshot.hasData && profileSnapshot.data != null) {
                final role = profileSnapshot.data!['role'];
                final status = profileSnapshot.data!['approval_status'];

                // SADECE şirketler için onay kontrolü yap
                if (role == 'company' && status == 'pending') {
                  return const PendingApprovalPage();
                }
                
                // Normal kullanıcılar veya onaylı şirketler ana menüye geçer
                return const MainNavigationPage();
              }
              
              // Veri yoksa (Eski kullanıcılar veya hata durumu)
              // Hackathon için kullanıcıyı engellemek yerine ana menüye alalım
              return const MainNavigationPage();
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text('Onay Bekleniyor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Şirket hesabınız başarıyla oluşturuldu ancak henüz yönetici tarafından onaylanmadı. Onaylandığında bu ekrandan geçiş yapabileceksiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Farklı Bir Hesapla Gir'),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // Yeni sekmeler: İstihdam, Günlük Hayat, Eğitim
  final List<Widget> _pages = [
    const EmploymentPage(),
    const DailyLifePage(),
    const EducationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Seçili sayfayı göster
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'İstihdam'),
          NavigationDestination(icon: Icon(Icons.accessibility_new), label: 'Günlük Hayat'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Eğitim'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erişilebilir Türkiye')),
      body: const Center(
        child: Text('Dashboard Yüklendi. Lütfen menüden seçim yapın.'),
      ),
    );
  }
}
