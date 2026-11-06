import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AdditionalComponents/AuthIcons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FirebaseAuthPage extends StatefulWidget {
  const FirebaseAuthPage({super.key});

  @override
  State<FirebaseAuthPage> createState() => _FirebaseAuthPageState();
}

class _FirebaseAuthPageState extends State<FirebaseAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSigningIn = false;
  bool _isRegistering = false;
  bool _obscurePassword = true;


var redirectTo = "";
  @override
  void initState() {
    if (kIsWeb) {
      redirectTo = "https://localhost:20983/supabase";
    } else if (Platform.isAndroid) {
      redirectTo = "flutter-test-app://login-callback";
  }
    super.initState();
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_isSigningIn || !_formKey.currentState!.validate()) return;

    setState(() => _isSigningIn = true);
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        throw UnsupportedError(
          'Firebase Authentication is not supported on Windows desktop. '
          'Run the app on Android, iOS, macOS, or the web.',
        );
      }

      final auth = FirebaseAuth.instance;
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isRegistering) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/firebase');
      }
    } on FirebaseAuthException catch (error) {
      _showError(error.message ?? error.code);
    } on UnsupportedError catch (error) {
      _showError(error.message ?? error.toString());
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signIn(BuildContext context, AuthProvider provider) async {
    if (_isSigningIn) return;

    setState(() => _isSigningIn = true);
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        throw UnsupportedError(
          'Firebase Authentication is not supported on Windows desktop. '
          'Run the app on Android, iOS, macOS, or the web.',
        );
      }

      final auth = FirebaseAuth.instance;
      if (kIsWeb) {
        await auth.signInWithPopup(provider);
      } else {
        await auth.signInWithProvider(provider);
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/firebase');
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? error.toString())),
        );
      }
    } on UnsupportedError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message ?? error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase auth"),),
      body: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 216, 216),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Text('Sign in with:'),
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
                            return 'Enter a valid email';
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
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
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
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isSigningIn
                          ? null
                          : _signInWithEmailAndPassword,
                      child: Text(_isRegistering ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _isSigningIn
                          ? null
                          : () => setState(
                                () => _isRegistering = !_isRegistering,
                              ),
                      child: Text(
                        _isRegistering
                            ? 'Already have an account? Sign in'
                            : 'Need an account? Create one',
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
                        onPressed: () => _signIn(context, GoogleAuthProvider()),
                        icon: FaIcon(FontAwesomeIcons.google, fill: 0.2),
                      ),
                      AuthIcon(
                        onPressed: () => _signIn(context, GithubAuthProvider()),
                        icon: FaIcon(FontAwesomeIcons.github, fill: 0.2),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
