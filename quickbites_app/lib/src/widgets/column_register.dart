import 'package:flutter/material.dart';
import 'package:quickbites_app/src/auth/auth_register.dart';
import 'package:quickbites_app/src/widgets/text_field_login.dart';

class ColumnRegister extends StatefulWidget {
  const ColumnRegister({super.key});

  @override
  State<ColumnRegister> createState() => _ColumnRegisterState();
}

class _ColumnRegisterState extends State<ColumnRegister> {
  final TextEditingController emailController = TextEditingController(); 
 //--------------
  final TextEditingController passwordController = TextEditingController(); 
 //-------------------
  final TextEditingController confirmPasswordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController establecimientoController = TextEditingController(); 
 //------------------------
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
          icono: Icons.password_rounded,
        ),
        const SizedBox(height: 20),

        // Confirm Contraseña
        textField(
          controler: confirmPasswordController,
          texto: 'Confirmar Contraseña',
          icono: Icons.password_outlined,
        ),
        const SizedBox(height: 20),

        // Nombre
        textField(
          controler: nameController,
          texto: 'Nombre',
          icono: Icons.arrow_forward_ios_rounded,
        ),
        const SizedBox(height: 20),

        // Apellido
        textField(
          controler: lastNameController,
          texto: 'Apellido',
          icono: Icons.arrow_forward_ios_rounded,
        ),
        const SizedBox(height: 20),

        // Direccion
        textField(
          controler: addressController,
          texto: 'Direccion',
          icono: Icons.directions_outlined,
        ),
        const SizedBox(height: 20),

        // Telefono
        textField(
          controler: phoneController,
          texto: 'Teléfono',
          icono: Icons.phone,
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
          onPressed: () async {

            if (emailController.text.trim().isEmpty ||
                passwordController.text.trim().isEmpty ||
                nameController.text.trim().isEmpty ||
                lastNameController.text.trim().isEmpty ||
                addressController.text.trim().isEmpty ||
                phoneController.text.trim().isEmpty ||
                establecimientoController.text.trim().isEmpty) {
              // Mostrar un mensaje de error si algún campo está vacío
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, completa todos los campos.'),
                  backgroundColor: Colors.red,
                ),
              );
              return; // Salir de la función si la validación falla
            }

            if (passwordController.text != confirmPasswordController.text) {
              // Mostrar un mensaje de error si no coinciden las contraseñas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Las contraseñas deben coincidir'),
                  backgroundColor: Colors.red,
                ),
              );
              return; // Salir de la función si la validación falla
            }

            await AuthService().createUser(
              email: emailController.text, 
              password: passwordController.text, 
              nombre: nameController.text, 
              apellido: lastNameController.text, 
              direccion: addressController.text, 
              telefono: phoneController.text, 
              establecimiento: establecimientoController.text, 
              context: context,
            );

            emailController.text = "";
            passwordController.text = "";
            nameController.text = "";
            lastNameController.text = "";
            addressController.text = "";
            phoneController.text = "";
            establecimientoController.text = "";
            confirmPasswordController.text = "";
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf03c0f),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 67, vertical: 10),
          ),
          child: Text(
            '¡Registrarse!',
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
