import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final bool showSignUp;
  const AuthScreen({this.showSignUp = false, super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.showSignUp ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Sign Up'), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')])),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoginForm(),
          _SignUpForm(),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pw, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _error = null; });
              final err = await auth.signIn(_email.text, _pw.text);
              setState(() { _loading = false; _error = err; });
              if (err == null && mounted) Navigator.pop(context);
            },
            child: _loading ? const CircularProgressIndicator() : const Text('Login'),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _pw, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: _nickname, decoration: const InputDecoration(labelText: 'Nickname')),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _error = null; });
              final err = await auth.signUp(_email.text, _pw.text, _nickname.text);
              setState(() { _loading = false; _error = err; });
              if (err == null && mounted) Navigator.pop(context);
            },
            child: _loading ? const CircularProgressIndicator() : const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
} 