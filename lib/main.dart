import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Supabase/supabaseAuthComponent.dart';
import 'package:flutter_application_1/firebase.dart';
import 'package:flutter_application_1/firebaseAuthComponent.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/Supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://revpnbmjfygzeniwgndu.supabase.co',
    publishableKey: 'sb_publishable_Sh7Hpa5DOfHfMg-gdl-oFA_dQFYVwif',
  );


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


 @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp>
{
  final _appLinks = AppLinks();

@override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  void initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      print("Ошибка initialUri: $e");
    }

    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) async {
    if (uri.scheme == 'flutter-test-app' && uri.host == 'login-callback') {
      try {
        await supabase.auth.getSessionFromUrl(uri);
        navigatorKey.currentState?.pushReplacementNamed('/supabase');
      } catch (e) {
        log("Deeplink error: $e");
      }
    }
  }

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/supabase': (context) => const SupabasePage(),
        '/supabase/auth': (context) => const SupabaseAuthPage(),
        '/firebase': (context) => const FirebasePage(),
        '/firebase/auth': (context) => const FirebaseAuthPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Гл. меню')),
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/supabase'),
              child: Text('Supabase'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/firebase'),
              child: Text('Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
