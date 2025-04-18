import 'package:flutter/material.dart';

class textField extends StatelessWidget {
  const textField({
    super.key,
    required this.controler,
    required this.texto,
    this.icono,
    required this.unseenText,
    required this.boardType,
    this.onChanged,
    this.textColor,
  });

  final TextEditingController controler;
  final IconData? icono;
  final String texto;
  final bool unseenText;
  final TextInputType boardType;
  final void Function(String)? onChanged;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: unseenText,
      keyboardType: boardType,
      controller: controler,
      onChanged: onChanged,
      style: TextStyle(
        color: textColor ?? Colors.grey[100],
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icono, color: const Color(0xFF6e2c13)),
        hintText: texto,
        hintStyle: TextStyle(
          color:
              textColor != null
                  ? textColor!.withValues(alpha: 0.6)
                  : Colors.grey[200]!.withValues(
                    alpha: 0.5,
                  ), // hintText no debe sobresalir
          fontWeight: FontWeight.w900,
          fontSize: 17,
        ),
        border: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFf03c0f), width: 3),
        ),
      ),
    );
  }
}
