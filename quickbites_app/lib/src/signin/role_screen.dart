import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/signin/manager/local_tab.dart';
import 'package:quickbites_app/src/signin/manager/menu_tab.dart';
import 'package:quickbites_app/src/signin/manager/search_employee.dart';

class ManagerScreen extends StatelessWidget {
  ManagerScreen({super.key});

  final userController = Get.find<UserController>();
  final CollectionReference usuariosRef = FirebaseFirestore.instance.collection('usuarios');

  @override
  Widget build(BuildContext context) {
    Get.put(GerenteController(), permanent: true);
    print("ALOOOOOOOOOOOOOOOOOOOOOOOOOO + ${Get.put(GerenteController(), permanent: true)}");
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${userController.nombre} ${userController.apellido}"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Usuario"),
              Tab(text: "Local"),
              Tab(text: "Menú"),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.output_rounded),
                title: const Text('Cerrar Sesión'),
                onTap: () {
                  userController.signOut();
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SearchEmployee(usuariosRef: usuariosRef),
            LocalTab(establecimiento: userController.establecimiento, usuariosRef: usuariosRef),
            MenuTab(),
          ],
        ),
      ),
    );
  }
}