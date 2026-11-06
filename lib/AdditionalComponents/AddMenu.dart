import 'dart:async';

import 'package:flutter/material.dart';

class AddMenu extends StatefulWidget {
  final FutureOr<void> Function(String? username, String? passwd) insert;
  const AddMenu({
    super.key,
    required this.insert,
  });


  @override
  State<StatefulWidget> createState()
    => AddMenuState();

}

class AddMenuState extends State<AddMenu>
{
  final _usernameCont = TextEditingController();
  final _passwordCont = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  Future<void> _submit() async {
    await widget.insert(_usernameCont.text, _passwordCont.text);
    if (!mounted) return;
    _usernameCont.clear();
    _passwordCont.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 205, 220, 201),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Добавить пользователя',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _usernameCont,
              focusNode: _usernameFocus,
              decoration: const InputDecoration(labelText: 'Имя пользователя'),
            ),
            TextFormField(
              controller: _passwordCont,
              focusNode: _passwordFocus,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCont.dispose();
    _passwordCont.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}