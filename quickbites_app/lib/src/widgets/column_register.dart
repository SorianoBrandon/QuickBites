import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/auth/auth_register.dart';
import 'package:quickbites_app/src/widgets/text_field_login.dart';
import 'package:quickbites_app/src/controllers/login_controller.dart';

class ColumnRegister extends StatelessWidget {
  ColumnRegister({super.key});

  final LoginController logController = Get.find<LoginController>();

  Widget _buildTextField({
    required String keyName,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    void Function(String)? onChanged,
    Color? textColor,
  }) {
    return Column(
      children: [
        textField(
          controler: logController.controllers[keyName]!,
          texto: label,
          icono: icon,
          unseenText: obscure,
          boardType: type,
          onChanged: onChanged,
          textColor: textColor,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _handleRegister(BuildContext context) async {
    final emptyFields = logController.controllers.entries.any((e) {
      final name = e.key;
      return name != 'confirmPassword' &&
          name != 'establecimiento' &&
          e.value.text.trim().isEmpty;
    });

    if (emptyFields) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await AuthService().createUser(
      email: logController.controllers['email']!.text,
      password: logController.controllers['password']!.text,
      nombre: logController.controllers['name']!.text,
      apellido: logController.controllers['lastName']!.text,
      direccion: logController.controllers['address']!.text,
      telefono: logController.controllers['phone']!.text,
      context: context,
    );

    logController.clearFields();
    logController.toggleForm();
  }

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
        _buildTextField(
          keyName: 'email',
          label: 'Correo Electrónico',
          icon: Icons.email,
          type: TextInputType.emailAddress,
        ),
        _buildTextField(
          keyName: 'password',
          label: 'Contraseña',
          icon: Icons.lock_person_rounded,
          type: TextInputType.visiblePassword,
          obscure: true,
          onChanged: logController.validatePasswords,
        ),
        Obx(
          () => _buildTextField(
            keyName: 'confirmPassword',
            label: 'Conf. Contraseña',
            icon: Icons.lock_person_rounded,
            type: TextInputType.visiblePassword,
            obscure: true,
            onChanged: logController.validatePasswords,
            textColor: logController.confirmPasswordTextColor.value,
          ),
        ),
        _buildTextField(
          keyName: 'name',
          label: 'Nombre',
          icon: Icons.person_2_rounded,
          type: TextInputType.name,
        ),
        _buildTextField(
          keyName: 'lastName',
          label: 'Apellido',
          icon: Icons.person_2_rounded,
          type: TextInputType.name,
        ),
        _buildTextField(
          keyName: 'address',
          label: 'Dirección',
          icon: Icons.maps_home_work_rounded,
          type: TextInputType.streetAddress,
        ),
        _buildTextField(
          keyName: 'phone',
          label: 'Teléfono',
          icon: Icons.phone_android_rounded,
          type: TextInputType.phone,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: logController.toggleForm,
            child: Text(
              '¿Ya tienes una cuenta?',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _handleRegister(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf03c0f),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 10),
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
