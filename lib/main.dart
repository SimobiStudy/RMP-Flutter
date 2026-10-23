import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final _formKey = GlobalKey<FormState>();
  final _usernameCont = TextEditingController();
  final _passwordCont = TextEditingController();

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? serverError;

  late final _usersStream = Supabase.instance.client
    .from('Users')
    .stream(primaryKey: ['id'])
    .order('username');

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _insertIntoTable() async {
    if (_usernameCont.text.trim().isEmpty) {
      return null;
    } 
    if (_passwordCont.text.trim().isEmpty) {
      return null;
    } 
    var _passwordHash = sha256.convert(utf8.encode(_passwordCont.text)).toString();

    await Supabase.instance.client
      .from('Users').insert({
        'username': _usernameCont.text,
        'password': _passwordHash
    });
  }

  List<Map<String, dynamic>> _usersList = [];

  void fetchAndUpdate() async
  {
      final users = await Supabase.instance.client
      .from('Users').select('username');

      setState(() {
        _usersList = List<Map<String, dynamic>>.from(users);
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(width: 500, child: Column(
          mainAxisAlignment: .center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameCont,
                    focusNode: _usernameFocus,
                    decoration: InputDecoration(
                      labelText: "Логин",
                      errorText: serverError,
                    ),
                  ),
                  TextFormField(
                    controller: _passwordCont,
                    focusNode: _passwordFocus,
                    decoration: InputDecoration(
                      labelText: "Пароль",
                      errorText: serverError,
                    ),
                  ),
                  Container( padding: EdgeInsetsGeometry.directional(top:10, bottom: 10),
                  child: Row(spacing: 20,
                    children: [
                   ElevatedButton(onPressed: 
                    fetchAndUpdate, child: const Text("Fetch -_-")
                  ),
                  ElevatedButton(onPressed: 
                    _insertIntoTable, child: const Text("Add")
                  )]),
                  )
                ],
              ),
  
            ),
            
            Text("Вывод: "),
            Expanded(
            
            child: Container( 
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 222, 222, 222),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color.fromARGB(255, 2, 2, 2))
              ),
              clipBehavior: Clip.antiAlias,
              
              margin: EdgeInsetsGeometry.directional(bottom: 50, top: 10),
              
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
              
            itemCount: _usersList.length,
            itemBuilder: (context, index)
            {
              final user = _usersList[index];
              return ListTile(
                dense: true,
                visualDensity: VisualDensity(vertical: -4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: -5),
                title: Text(user['username']),
              );
            },)
            )
            )
            )
    
          
          ]),
        ),
      ),
    
    );
  }
}
