import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AdditionalComponents/AddMenu.dart';

class FirebasePage extends StatefulWidget {
  const FirebasePage({super.key});

  @override
  State<FirebasePage> createState() => _FirebasePageState();
}

class _FirebasePageState extends State<FirebasePage> {
  final _usersController = StreamController<List<DataSnapshot>>.broadcast();
  StreamSubscription<List<DataSnapshot>>? _usersControllerSubscription;
  StreamSubscription<DatabaseEvent>? _realtimeSubscription;

  final String? username = FirebaseAuth.instance.currentUser?.email;

  List<DataSnapshot> _users = const [];
  String? _serverError;
  bool _isRealtimeEnabled = false;
  bool _isLoading = false;
  bool _isSaving = false;

  DatabaseReference get _usersRef => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://flutter-test-proj-8af95-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref('users');

  @override
  void initState() {
    super.initState();
    _usersControllerSubscription = _usersController.stream.listen((users) {
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
        _serverError = null;
      });
    });

    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/firebase/auth');
        }
      });
      return;
    }

    fetchData();
  }

  Future<void> fetchData() async {
    if (_isLoading || _isRealtimeEnabled) return;

    setState(() {
      _isLoading = true;
      _serverError = null;
    });
    try {
      final snapshot = await _usersRef.get();
      if (mounted) {
        _usersController.add(snapshot.children.toList(growable: false));
      }
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _serverError = error.message ?? error.toString();
      });
    }
  }

  void subscribe() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _usersRef.onValue.listen(
      (event) => _usersController.add(event.snapshot.children.toList()),
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _serverError = error.toString();
        });
      },
    );
  }

  void toggleRealtime(bool? value) {
    if (value == null) return;

    setState(() {
      _isRealtimeEnabled = value;
      _serverError = null;
      _isLoading = value;
    });

    if (value) {
      subscribe();
    } else {
      _realtimeSubscription?.cancel();
      _realtimeSubscription = null;
      fetchData();
    }
  }

  Future<void> _insertIntoTable(String? username, String? passwd) async {
    final trimmedUsername = username?.trim() ?? '';
    final password = passwd ?? '';
    if (trimmedUsername.isEmpty || password.trim().isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _serverError = null;
    });
    try {
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      await _usersRef.push().set({
        'username': trimmedUsername,
        'password': passwordHash,
      });
      if (mounted && !_isRealtimeEnabled) {
        await fetchData();
      }
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _serverError = error.message ?? error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _usersControllerSubscription?.cancel();
    _usersController.close();
    super.dispose();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/firebase/auth');
      }
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 160, 136),
        title: Row(
          spacing: 40,
          children: [
          Text(username ?? 'Error user', style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
          IconButton(onPressed: logout, icon: Icon(Icons.logout))],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Users',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 222, 222, 222),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _users.isEmpty
                        ? Center(child: Text(_serverError ?? 'List is empty'))
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final value = _users[index].value;
                                final user = value is Map ? value : null;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    user?['username']?.toString() ??
                                        'Unnamed user',
                                  ),
                                );
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isRealtimeEnabled,
                        onChanged: toggleRealtime,
                      ),
                      const Text('Realtime'),
                      const SizedBox(width: 24),
                      ElevatedButton(
                        onPressed: _isRealtimeEnabled || _isLoading
                            ? null
                            : fetchData,
                        child: const Text('Fetch'),
                      ),
                    ],
                  ),
                  AddMenu(insert: _insertIntoTable),

                  if (_serverError != null)
                    Text(
                      _serverError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
