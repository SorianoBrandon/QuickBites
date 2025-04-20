import 'package:flutter/material.dart';

Widget buildSectionHeader(String title, {required IconData icon, required Color backgroundColor, required Color textColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    margin: const EdgeInsets.only(bottom: 8.0),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      children: [
        Icon(icon, color: textColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

Widget buildAddButton(BuildContext context, String label, VoidCallback onPressed, {required Color buttonColor}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.add, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
    ),
  );
}

void confirmDelete(BuildContext context, String message, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar Eliminación'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}