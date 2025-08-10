import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/unicorn_theme.dart';
import 'main_shell.dart';
import '../providers/settings_provider.dart';

class AuthScreen extends StatefulWidget {
  final bool showSignUp;
  final VoidCallback? onAuthenticated;
  const AuthScreen({this.showSignUp = false, this.onAuthenticated, super.key});
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

  void _showNetworkErrorDialog() {
    print('[AuthScreen] _showNetworkErrorDialog called');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Network Error',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to connect to the server.\nPlease check your internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    MainShell.setTabIndex?.call(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                    Container(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(), // 스와이핑 비활성화
                    children: [
                      SingleChildScrollView(
                        child: _LoginForm(
                          onNetworkError: _showNetworkErrorDialog,
                          onAuthenticated: widget.onAuthenticated,
                        ),
                      ),
                      SingleChildScrollView(
                        child: _SignUpForm(
                          onNetworkError: _showNetworkErrorDialog,
                          onAuthenticated: widget.onAuthenticated,
                        ),
                      ),
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
  final VoidCallback? onNetworkError;
  final VoidCallback? onAuthenticated;
  
  const _LoginForm({this.onNetworkError, this.onAuthenticated});
  
  @override
  State<_LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Column(
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
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
                setState(() { _loading = false; });
                print('[AuthScreen] Login error: $err');
                if (err == 'Network Error') {
                  print('[AuthScreen] Network error detected in login form');
                  widget.onNetworkError?.call();
                } else {
                  setState(() { _error = err; });
                }
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
                  // 인증 완료 콜백 호출 (결과 화면 복귀 등)
                  if (widget.onAuthenticated != null) {
                    widget.onAuthenticated!();
                  }
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
  final VoidCallback? onNetworkError;
  final VoidCallback? onAuthenticated;
  
  const _SignUpForm({this.onNetworkError, this.onAuthenticated});
  
  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}
class _SignUpFormState extends State<_SignUpForm> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _nickname = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Column(
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          obscureText: _obscurePassword,
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
          Text(
            _error!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
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
                setState(() { _loading = false; });
                print('[AuthScreen] Signup error: $err');
                if (err == 'Network Error') {
                  print('[AuthScreen] Network error detected in signup form');
                  widget.onNetworkError?.call();
                } else {
                  setState(() { _error = err; });
                }
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
                  // 인증 완료 콜백 호출
                  if (widget.onAuthenticated != null) {
                    widget.onAuthenticated!();
                  }
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