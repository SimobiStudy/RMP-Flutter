import 'package:flutter/material.dart';

class AuthIcon extends StatelessWidget
{
  final VoidCallback onPressed;
  final Icon icon;

  const AuthIcon({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return 
      Container(decoration: BoxDecoration(color: Color.fromARGB(255, 240, 240, 240), borderRadius: BorderRadius.all(Radius.circular(10))), child:
      IconButton(
        onPressed: onPressed, icon: icon));

  }
}
