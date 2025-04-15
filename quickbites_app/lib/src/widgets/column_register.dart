import 'package:flutter/material.dart';
import 'package:quickbites_app/src/widgets/text_field_login.dart';

class ColumnRegister extends StatelessWidget {
  ColumnRegister({super.key});

  final TextEditingController emailController =
      TextEditingController(); //--------------
  final TextEditingController passwordController =
      TextEditingController(); //-------------------

  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController establecimientoController =
      TextEditingController(); //------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Nuevo Usuario',
            style: TextStyle(
              color: Colors.orange[50],
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Establecimiento
        Center(
          child: textField(
            controler: establecimientoController,
            texto: 'Establecimiento',
          ),
        ),
        const SizedBox(height: 20),

        // Email
        textField(
          controler: emailController,
          texto: 'Correo Electrónico',
          icono: Icons.email,
        ),
        const SizedBox(height: 20),

        // Contraseña
        textField(
          controler: passwordController,
          texto: 'Contraseña',
          icono: Icons.lock_person_rounded,
        ),
        const SizedBox(height: 20),

        // Confirm Contraseña
        textField(
          controler: confirmPasswordController,
          texto: 'Confirmar Contraseña',
          icono: Icons.lock_person_rounded,
        ),
        const SizedBox(height: 20),

        // Nombre
        textField(
          controler: nameController,
          texto: 'Nombre',
          icono: Icons.lock_person_rounded,
        ),
        const SizedBox(height: 20),

        // Apellido
        textField(
          controler: lastNameController,
          texto: 'Apellido',
          icono: Icons.lock_person_rounded,
        ),
        const SizedBox(height: 20),

        // Direccion
        textField(
          controler: addressController,
          texto: 'Direccion',
          icono: Icons.lock_person_rounded,
        ),
        const SizedBox(height: 20),

        // Telefono
        textField(
          controler: phoneController,
          texto: 'Teléfono',
          icono: Icons.lock_person_rounded,
        ),
        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              '¿Ya tienes una cuenta?',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Botón Entrar
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf03c0f),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 67, vertical: 10),
          ),
          child: Text(
            '¡Bienvenido!',
            style: TextStyle(
              color: Colors.grey[100],
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
