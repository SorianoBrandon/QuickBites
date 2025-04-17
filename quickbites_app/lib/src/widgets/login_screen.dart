import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickbites_app/src/widgets/column_login.dart';
import 'package:quickbites_app/src/widgets/column_register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool isLogin = true;
  bool isAnimating = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState(); 

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _controller.value = 1; // empieza visible
  }

  Future<void> toggleForm() async {
    if (isAnimating) return;
    isAnimating = true;

    // Cierra
    await _controller.reverse();

    setState(() {
      isLogin = !isLogin;
    });

    // Espera un frame para que se reconstruya y pueda medir el nuevo contenido
    await Future.delayed(Duration(milliseconds: 30));

    await _controller.forward();
    isAnimating = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildContainerContent() {
    return isLogin ? ColumnLogin() : ColumnRegister( change: toggleForm, );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1D0),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Image.asset('assets/QuickBites_Logo.png', height: 180),
                      const SizedBox(height: 15),

                      // CONTENEDOR ANIMADO
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5A25D).withOpacity(0.6),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                ),
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
                                animation: _controller,
                                builder: (context, child) {
                                  return ClipRect(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      heightFactor: _heightFactor.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey<bool>(isLogin),
                                  child: _buildContainerContent(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // LÍNEAS + TEXTO "O"
                      Row(
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
                      ),
                      const SizedBox(height: 20),

                      // BOTONES INFERIORES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 25,
                              child: FaIcon(
                                FontAwesomeIcons.google,
                                color: Colors.redAccent,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: toggleForm,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 25,
                              child: Icon(
                                isLogin
                                    ? Icons.person_add_alt_rounded
                                    : Icons.login,
                                color: const Color(0xFF5B2C1B),
                                size: 26,
                              ),
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
