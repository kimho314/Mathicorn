import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/providers/settings_provider.dart';
import 'package:Mathicorn/providers/wrong_note_provider.dart';
import 'package:Mathicorn/providers/auth_provider.dart';
import 'package:Mathicorn/screens/home_screen.dart';
import 'package:Mathicorn/screens/auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_shell.dart';
import 'package:Mathicorn/providers/statistics_provider.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const FunnyCalcApp());
}

class FunnyCalcApp extends StatelessWidget {
  const FunnyCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = GameProvider();
            // 앱 시작 시 프로필 로드
            provider.loadUserProfile();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = SettingsProvider();
            // 앱 시작 시 설정 로드 (초기화 시점에서는 AuthProvider를 전달할 수 없으므로 호출하지 않음)
            // provider.loadSettings(); // 이 줄을 주석 처리 또는 삭제
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => WrongNoteProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // AuthProvider와 WrongNoteProvider 연결
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final wrongNoteProvider = context.read<WrongNoteProvider>();
            authProvider.setWrongNoteProvider(wrongNoteProvider);
          });
          
          return MaterialApp(
            title: 'Mathicorn',
            theme: ThemeData(
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: const Color(0xFF8B5CF6), // purple
                onPrimary: Colors.white,
                secondary: const Color(0xFF06B6D4), // cyan
                onSecondary: Colors.white,
                error: const Color(0xFFEC4899), // pink
                onError: Colors.white,
                background: const Color(0xFFF8FAFC), // lightGray
                onBackground: const Color(0xFF1E293B), // darkText
                surface: Colors.white,
                onSurface: const Color(0xFF64748B), // textGray
              ),
              scaffoldBackgroundColor: Colors.transparent,
              fontFamily: 'NotoSansKR',
              textTheme: GoogleFonts.baloo2TextTheme().copyWith(
                headlineLarge: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  shadows: [Shadow(offset: Offset(2,2), blurRadius: 4, color: Colors.black26)],
                ),
                titleLarge: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  shadows: [Shadow(offset: Offset(2,2), blurRadius: 4, color: Colors.black12)],
                ),
                bodyLarge: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                bodyMedium: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ).apply(
                fontFamilyFallback: ['NotoSansKR', 'sans-serif'],
              ),
              cardTheme: CardThemeData(
                color: Colors.white.withOpacity(0.25),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                shadowColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                margin: const EdgeInsets.all(8),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white.withOpacity(0.15),
                indicatorColor: const Color(0xFF8B5CF6).withOpacity(0.15),
                labelTextStyle: MaterialStateProperty.all(const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
                iconTheme: MaterialStateProperty.all(const IconThemeData(
                  color: Color(0xFF8B5CF6),
                  size: 28,
                )),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const _UnicornBackground(
              child: MainShell(),
            ),
            routes: {
              '/auth': (_) => const AuthScreen(),
            },
          );
        },
      ),
    );
  }
}

// App-wide unicorn/kawaii gradient background with decorative elements
class _UnicornBackground extends StatelessWidget {
  final Widget child;
  const _UnicornBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6), // purple
                Color(0xFFD946EF), // magenta
                Color(0xFFEC4899), // pink
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Decorative unicorn, star, and confetti Lottie animations
        IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                bottom: 60,
                right: 30,
                child: SizedBox(
                  width: 60,
                  child: Opacity(
                    opacity: 0.7,
                    child: Lottie.asset('assets/animations/star.json', repeat: true),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                right: 40,
                child: SizedBox(
                  width: 80,
                  child: Opacity(
                    opacity: 0.5,
                    child: Lottie.asset('assets/animations/confetti.json', repeat: true),
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
} 