import 'package:flutter/material.dart';

class MesaCard extends StatelessWidget {
  final String numero;
  final String capacidad;
  final bool disponible;
  final VoidCallback onTap;

  const MesaCard({
    super.key,
    required this.numero,
    required this.capacidad,
    required this.disponible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: disponible ? Colors.white : Colors.grey[300],
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: disponible ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesa $numero',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: disponible ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capacidad: $capacidad personas',
                style: TextStyle(
                  fontSize: 16,
                  color: disponible ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: disponible ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: disponible ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  disponible ? 'DISPONIBLE' : 'OCUPADA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: disponible ? Colors.green[800] : Colors.red[800],
                    fontSize: 14,
                  ),
                ),
              ),
              if (!disponible)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'RESERVADO',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}