import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://revpnbmjfygzeniwgndu.supabase.co',
    publishableKey: 'sb_publishable_Sh7Hpa5DOfHfMg-gdl-oFA_dQFYVwif',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/',
      routes: {
        '/':(context) => const MyHomePage(),
        '/supabase':(context) => const SupabasePage()
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
    Widget build(BuildContext context)  
    {
      return Scaffold(appBar: AppBar(title: const Text('Гл. меню')),
      body: Center(child: 
        ElevatedButton(onPressed: ()
        => Navigator.pushNamed(context, '/supabase'), child: 
        Text('Supabase')),));

    }
}
