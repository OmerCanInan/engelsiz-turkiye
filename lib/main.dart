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
import 'package:flutter_localizations/flutter_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class ErisilebilirTurkiyeApp extends StatefulWidget {
  const ErisilebilirTurkiyeApp({super.key});

  @override
  State<ErisilebilirTurkiyeApp> createState() => _ErisilebilirTurkiyeAppState();
}

class _ErisilebilirTurkiyeAppState extends State<ErisilebilirTurkiyeApp> with WidgetsBindingObserver {
  bool _isTalkBackOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkTalkBackState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    _checkTalkBackState();
  }

  void _checkTalkBackState() {
    final bool isAccessible = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.accessibleNavigation;
    if (_isTalkBackOn != isAccessible) {
      setState(() {
        _isTalkBackOn = isAccessible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TalkBack açıksa global olarak kapkaranlık, yüksek kontrastlı ve dev fontlu tema uygula
    final talkbackTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white, size: 48),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 80),
          textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white, width: 4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 3),
        ),
      ),
    );

    return MaterialApp(
      title: 'Engelsiz Türkiye',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _isTalkBackOn ? talkbackTheme : AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  Future<Map<String, dynamic>?>? _profileFuture;
  String? _lastUserId;
  bool _isTalkBackOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkTalkBackState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    _checkTalkBackState();
  }

  void _checkTalkBackState() {
    final bool isAccessible = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.accessibleNavigation;
    if (_isTalkBackOn != isAccessible) {
      setState(() {
        _isTalkBackOn = isAccessible;
      });
    }
  }

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
          // ÖNCELİKLİ: E-posta bazlı admin kontrolü (RLS engeline takılmaz)
          final email = session.user.email?.toLowerCase() ?? '';
          if (email == 'admin@erisimturkiye.com') {
            return const AdminPanelPage();
          }

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

                // Güvenli Admin Kontrolü (DB'den gelen rol)
                if (role == 'admin') {
                  return const AdminPanelPage();
                }

                // SADECE şirketler için onay kontrolü yap
                if (role == 'company' && status == 'pending') {
                  return const PendingApprovalPage();
                }
                
                // Normal kullanıcılar veya onaylı şirketler ana menüye geçer
                // MediaQuery fallback
                final bool isAccessibleNav = MediaQuery.accessibleNavigationOf(context);
                if (_isTalkBackOn || isAccessibleNav) {
                  return const TalkbackMainPage();
                }
                return const MainNavigationPage();
              }
              
              // Veri yoksa (Eski kullanıcılar veya hata durumu)
              // Hackathon için kullanıcıyı engellemek yerine ana menüye alalım
              final bool isAccessibleNav = MediaQuery.accessibleNavigationOf(context);
              if (_isTalkBackOn || isAccessibleNav) {
                return const TalkbackMainPage();
              }
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
      appBar: AppBar(title: const Text('Engelsiz Türkiye')),
      body: const Center(
        child: Text('Dashboard Yüklendi. Lütfen menüden seçim yapın.'),
      ),
    );
  }
}
