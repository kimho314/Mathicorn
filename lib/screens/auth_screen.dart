import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/unicorn_theme.dart';
import 'main_shell.dart';
import '../providers/settings_provider.dart';

class AuthScreen extends StatefulWidget {
  final bool showSignUp;
  const AuthScreen({this.showSignUp = false, super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.showSignUp ? 1 : 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _animationController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: UnicornDecorations.appBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: UnicornDecorations.cardGlass,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Text('Welcome to Mathicorn!', style: UnicornTextStyles.header.copyWith(fontSize: 28)),
                    const SizedBox(height: 16),
                    _buildCustomTabBar(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 320,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _LoginForm(),
                          _SignUpForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / 2;
        
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Stack(
            children: [
              // Animated indicator
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _tabController.index * tabWidth + 4,
                    top: 4,
                    bottom: 4,
                    width: tabWidth - 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Tab buttons
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Login', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('Sign Up', 1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          height: 48,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? UnicornColors.white : UnicornColors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _email,
          decoration: InputDecoration(
            labelText: 'Email',
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pw,
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          obscureText: true,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: UnicornButtonStyles.primary,
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _error = null; });
              
              // 로그인 시도
              final err = await auth.signIn(_email.text, _pw.text);
              
              if (err != null) {
                setState(() { _loading = false; _error = err; });
                return;
              }
              
              // 로그인 성공 후 settings 로드
              try {
                final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                await settingsProvider.loadSettings(auth);
                print('[AuthScreen] Settings loaded successfully');
              } catch (e) {
                print('[AuthScreen] Failed to load settings: $e');
                // settings 로드 실패해도 홈으로 이동
              }
              
              if (mounted) {
                setState(() { _loading = false; });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  MainShell.setTabIndex?.call(0);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                });
              }
            },
            child: _loading 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Loading...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                : const Text('Login'),
          ),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatefulWidget {
  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}
class _SignUpFormState extends State<_SignUpForm> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _nickname = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _email,
          decoration: InputDecoration(
            labelText: 'Email',
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pw,
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nickname,
          decoration: InputDecoration(
            labelText: 'Nickname',
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: UnicornButtonStyles.primary,
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _error = null; });
              
              // 회원가입 시도
              final err = await auth.signUp(_email.text, _pw.text, _nickname.text);
              
              if (err != null) {
                setState(() { _loading = false; _error = err; });
                return;
              }
              
              // 회원가입 성공 후 settings 로드
              try {
                final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                await settingsProvider.loadSettings(auth);
                print('[AuthScreen] Settings loaded successfully after signup');
              } catch (e) {
                print('[AuthScreen] Failed to load settings after signup: $e');
                // settings 로드 실패해도 홈으로 이동
              }
              
              if (mounted) {
                setState(() { _loading = false; });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  MainShell.setTabIndex?.call(0);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // 이메일 인증 다이얼로그 표시
                  MainShell.showEmailConfirmation?.call();
                });
              }
            },
            child: _loading 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Loading...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                : const Text('Sign Up'),
          ),
        ),
      ],
    );
  }
} 