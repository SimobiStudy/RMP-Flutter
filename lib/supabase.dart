import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePage extends StatefulWidget {
  const SupabasePage({super.key});

  @override
  State<SupabasePage> createState() => _SupabasePageState();
}


class _SupabasePageState extends State<SupabasePage> {
  int _counter = 0;

  final _formKey = GlobalKey<FormState>();
  final _usernameCont = TextEditingController();
  final _passwordCont = TextEditingController();

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _supabase = Supabase.instance.client;


  final StreamController<List<Map<String, dynamic>>> _streamController = StreamController.broadcast();

  String? serverError;

  late final _usersStream = Supabase.instance.client
      .from('Users')
      .stream(primaryKey: ['id'])
      .order('username');




    StreamSubscription? _streamSubscription;
    Future<void> fetchData() async {
    try {
      final data = await _supabase
          .from('Users')
          .select()
          .order('id', ascending: true);
      
      // Пушим данные в наш контроллер, чтобы StreamBuilder их подхватил
      _streamController.add(data);
    } catch (e) {
      setState(() {
        serverError = e.toString();
      });
    }
  }



  // Хочу оба
  void toggleRealtime(bool? value)
  {
    if (value == null){ 
      return;
    }

    setState(() {
      _isRealtimeEnabled = value;
    });

    if (_isRealtimeEnabled)
    {
      _streamSubscription = _supabase
          .from('Users')
          .stream(primaryKey: ['id'])
          .listen((data) {
            _streamController.add(data); 
          });
    } else {
      // Убиваю все
      _streamSubscription?.cancel();
      _streamSubscription = null;

      fetchData();
    }
  }

  @override
  void dispose()
  {
    _streamSubscription?.cancel();
    super.dispose();
  }

  //




  void _insertIntoTable() async {
    if (_usernameCont.text.trim().isEmpty) {
      return null;
    }
    if (_passwordCont.text.trim().isEmpty) {
      return null;
    }
    var _passwordHash = sha256
        .convert(utf8.encode(_passwordCont.text))
        .toString();

    await Supabase.instance.client.from('Users').insert({
      'username': _usernameCont.text,
      'password': _passwordHash,
    });

    _usernameCont.clear();
      _passwordCont.clear();
  }



  bool _isRealtimeEnabled = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Supabase страница'),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Column(
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
                    Container(
                      padding: EdgeInsetsGeometry.directional(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        spacing: 20,
                        children: [
                          Checkbox(value: _isRealtimeEnabled, onChanged: 
                          toggleRealtime),
                          Text("Realtime"),
                          ElevatedButton(
                            onPressed: !_isRealtimeEnabled ? fetchData : null, // блок при реалтайме
                            child: const Text("Fetch -_-"),
                          ),
                          ElevatedButton(
                            onPressed: _insertIntoTable,
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Text("Вывод: "),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 222, 222, 222),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color.fromARGB(255, 2, 2, 2)),
                  ),
                  clipBehavior: Clip.antiAlias,

                  margin: EdgeInsetsGeometry.directional(bottom: 50, top: 10),

                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final usersList = snapshot.data!;

                      if (usersList.isEmpty) {
                        return const Center(child: Text('Список пуст'));
                      }

                      return Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: usersList.length,
                          itemBuilder: (context, index) {
                            final user = usersList[index];
                            return ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: -5,
                              ),
                              title: Text(user['username'] ?? 'Без имени'),
                            );
                          },
                        ));
                    }
                  )
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
