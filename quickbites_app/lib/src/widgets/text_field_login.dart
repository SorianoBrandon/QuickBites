import 'package:flutter/material.dart';

class textField extends StatelessWidget {
  textField({
    super.key,
    required this.controler,
    required this.texto,
    this.icono,
  });

  final TextEditingController controler;
  final IconData? icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controler,
      style: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.w900),
      decoration: InputDecoration(
        prefixIcon: Icon(icono, color: Color(0xFF6e2c13)),
        hintText: texto,
        hintStyle: TextStyle(
          color: icono != null ? Colors.grey[100] : Color(0xFF6e2c13),
          fontWeight: FontWeight.w900,
          fontSize: 17,
        ),
        border: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFf03c0f), width: 3),
        ),
      ),
    );
  }
}
