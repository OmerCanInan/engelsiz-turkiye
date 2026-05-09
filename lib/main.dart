import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/employment_page.dart';
import 'presentation/pages/education_page.dart';
import 'presentation/pages/daily_life_page.dart';
import 'presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
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
        // Bağlantı hatası veya bekleyen durum kontrolü
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final session = snapshot.data?.session;
        if (session != null) {
          return const MainNavigationPage();
        }
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
