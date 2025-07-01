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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, // TODO: 실제 프로젝트 URL로 변경
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, // TODO: 실제 anon public key로 변경
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
            // 앱 시작 시 설정 로드
            provider.loadSettings();
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => WrongNoteProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: MaterialApp(
        title: 'Mathicorn',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFFB388FF),
            brightness: Brightness.light,
            primary: Color(0xFFB388FF),
            secondary: Color(0xFFFFF176),
            background: Color(0xFFF3E5F5),
          ),
          textTheme: GoogleFonts.baloo2TextTheme(),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              textStyle: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            color: Color(0xFFFFFFFF),
            shadowColor: Color(0xFFB388FF).withOpacity(0.2),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
        routes: {
          '/auth': (_) => const AuthScreen(),
        },
      ),
    );
  }
} 