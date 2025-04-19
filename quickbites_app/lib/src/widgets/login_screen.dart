import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/widgets/column_login.dart';
import 'package:quickbites_app/src/widgets/column_register.dart';
import 'package:quickbites_app/src/controllers/login_controller.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController controller = Get.put(LoginController());
  final UserController userController = Get.find<UserController>();

  Widget _buildForm() {
    return Obx(
      () => controller.isLogin.value ? ColumnLogin() : ColumnRegister(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1D0),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: mediaInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Image.asset('assets/QuickBites_Logo.png', height: 180),
                      const SizedBox(height: 15),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Obx(
                          () => _AnimatedFormContainer(
                            controller: controller.controller,
                            heightFactor: controller.heightFactor,
                            child: KeyedSubtree(
                              key: ValueKey<bool>(controller.isLogin.value),
                              child: _buildForm(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      const _OrDivider(),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*_SocialButton(
                            img: Image.asset('assets/google.png'),
                            color: Colors.redAccent,
                            onTap: () {},
                          ),
                          const SizedBox(width: 20),*/
                          Obx(
                            () => _SocialButton(
                              icon:
                                  controller.isLogin.value
                                      ? Icons.person_add_alt_rounded
                                      : Icons.login,
                              color: const Color(0xFF5B2C1B),
                              onTap: controller.toggleForm,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedFormContainer extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> heightFactor;
  final Widget child;

  const _AnimatedFormContainer({
    required this.controller,
    required this.heightFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5A25D).withValues(alpha: 0.6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: controller,
            builder:
                (_, __) => ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: heightFactor.value,
                    child: child,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Divider(
            color: Color(0xFFf03c0f),
            thickness: 1.5,
            indent: 30,
            endIndent: 10,
          ),
        ),
        Text(
          'Ó',
          style: TextStyle(
            color: Color(0xFF6e2c13),
            fontWeight: FontWeight.w900,
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFf03c0f),
            thickness: 1.5,
            indent: 10,
            endIndent: 30,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  //final Image? img;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    this.icon,
    required this.color,
    required this.onTap,
    //this.img,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 25,
        child: /*img ?? */ Icon(icon, color: color, size: 26),
      ),
    );
  }
}
