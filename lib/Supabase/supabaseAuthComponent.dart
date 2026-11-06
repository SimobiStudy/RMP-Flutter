import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AdditionalComponents/AuthIcons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthPage extends StatefulWidget {
  const SupabaseAuthPage({super.key});

  @override
  State<SupabaseAuthPage> createState() => _SupabaseAuthState();
}

class _SupabaseAuthState extends State<SupabaseAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  bool _isLoading = false;
  bool _isRegistering = false;
  bool _obscurePassword = true;

  GoTrueClient get supabaseAuth => Supabase.instance.client.auth;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithEmailAndPassword() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final response = _isRegistering
          ? await supabaseAuth.signUp(email: email, password: password)
          : await supabaseAuth.signInWithPassword(
              email: email,
              password: password,
            );

      if (!mounted) return;
      if (response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email to confirm your account.'),
          ),
        );
        return;
      }
      Navigator.pushReplacementNamed(context, '/supabase');
    } on AuthException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool isLoggedIn() {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null || session.isExpired;
  }

  var redirectTo = "";
  @override
  void initState() {
    if (kIsWeb) {
      redirectTo = "https://simobistudy.github.io/RMP-Flutter/#/supabase";
    } else if (Platform.isAndroid) {
      redirectTo = "flutter-test-app://login-callback";
  }
    super.initState();
  }

  void loginFromGoogle() {
    supabaseAuth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo
    );

    if (isLoggedIn()) {
      Navigator.pushReplacementNamed(context, "/supabase");
    }
  }

  void loginFromGithub() {
    supabaseAuth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: redirectTo,
    );
    if (isLoggedIn()) {
      Navigator.pushReplacementNamed(context, "/supabase");
    }
  }

  void loginFromApple() {
    supabaseAuth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: redirectTo,
    );

    if (isLoggedIn()) {
      Navigator.pushReplacementNamed(context, "/supabase");
    }
  }

  void loginFromYandex() {
    supabaseAuth.signInWithOAuth(
      OAuthProvider('custom:yandex'),
      redirectTo: redirectTo,
    );

    if (isLoggedIn()) {
      Navigator.pushReplacementNamed(context, "/supabase");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Supabase auth"),),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 216, 216, 216),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Вход в аккаунт:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text("Вход с помощью:", textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: 280,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty || !email.contains('@')) {
                            return 'Введите корректный email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 280,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Показать пароль'
                                : 'Скрыть пароль',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return 'Пароль должен содержать минимум 6 символов';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _authenticateWithEmailAndPassword,
                      child: Text(_isRegistering ? 'Создать аккаунт' : 'Войти'),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(
                              () => _isRegistering = !_isRegistering,
                            ),
                      child: Text(
                        _isRegistering
                            ? 'Уже есть аккаунт? Войти'
                            : 'Нет аккаунта? Создать',
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 2),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AuthIcon(
                        onPressed: loginFromGoogle,
                        icon: FaIcon(FontAwesomeIcons.google, fill: 0.2),
                      ),
                      AuthIcon(
                        onPressed: loginFromGithub,
                        icon: FaIcon(FontAwesomeIcons.github, fill: 0.2),
                      ),
                      AuthIcon(
                        onPressed: loginFromYandex,
                        icon: FaIcon(FontAwesomeIcons.yandex, fill: 0.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
