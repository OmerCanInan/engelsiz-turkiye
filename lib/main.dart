import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/supabase_config.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/employment_page.dart';
import 'presentation/pages/education_page.dart';
import 'presentation/pages/daily_life_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/admin_panel_page.dart';
import 'presentation/pages/talkback_main_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> accessibilityModeNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  accessibilityModeNotifier.value = prefs.getBool('accessibility_mode') ?? false;

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: kDebugMode,
    );
  } catch (e) {
    debugPrint('Supabase Başlatma Hatası: $e');
  }

  runApp(const ErisilebilirTurkiyeApp());
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<Map<String, dynamic>?>? _profileFuture;
  String? _lastUserId;

  void _fetchProfileIfNeeded(String userId) {
    if (userId != _lastUserId) {
      _lastUserId = userId;
      _profileFuture = Supabase.instance.client
          .from('profiles')
          .select('role, approval_status')
          .eq('id', userId)
          .maybeSingle();
    }
  }

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
          _fetchProfileIfNeeded(session.user.id);

          // Kullanıcı giriş yaptı ama Şirket/Kullanıcı onay durumu nedir?
          return FutureBuilder(
            future: _profileFuture,
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

                // Güvenli Admin Kontrolü
                if (role == 'admin') {
                  return const AdminPanelPage();
                }

                // SADECE şirketler için onay kontrolü yap
                if (role == 'company' && status == 'pending') {
                  return const PendingApprovalPage();
                }
                
                // Normal kullanıcılar veya onaylı şirketler ana menüye geçer
                return ValueListenableBuilder<bool>(
                  valueListenable: accessibilityModeNotifier,
                  builder: (context, isManualModeOn, child) {
                    bool isTalkBackOn = MediaQuery.accessibleNavigationOf(context) || isManualModeOn;
                    if (isTalkBackOn) {
                      return const TalkbackMainPage();
                    }
                    return const MainNavigationPage();
                  },
                );
              }
              
              // Veri yoksa (Eski kullanıcılar veya hata durumu)
              // Hackathon için kullanıcıyı engellemek yerine ana menüye alalım
              return ValueListenableBuilder<bool>(
                valueListenable: accessibilityModeNotifier,
                builder: (context, isManualModeOn, child) {
                  bool isTalkBackOn = MediaQuery.accessibleNavigationOf(context) || isManualModeOn;
                  if (isTalkBackOn) {
                    return const TalkbackMainPage();
                  }
                  return const MainNavigationPage();
                },
              );
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
