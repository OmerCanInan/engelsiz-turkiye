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
        // Eğer cihazda halihazırda aktif bir oturum (session) varsa beklemeye gerek yok
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const MainNavigationPage();
        }

        // Eğer veriler akmaya başladıysa veya hata varsa
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data?.session != null) {
            return const MainNavigationPage();
          } else {
            return const LoginPage();
          }
        }

        // Kısa süreli bir bekleme anında bile LoginPage'i göster, takılı kalmasın
        return const LoginPage();
      },
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

  // Sayfaları burada tanımlayarak her seferinde yeniden oluşmasını engelliyoruz
  final List<Widget> _pages = [
    const DashboardPage(),
    const EmploymentPage(),
    const EducationPage(),
    const DailyLifePage(),
    const ProfilePage(),
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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Panel'),
          NavigationDestination(icon: Icon(Icons.work), label: 'İşler'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Eğitim'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Harita'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
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
