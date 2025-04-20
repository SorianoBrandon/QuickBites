import 'package:flutter/material.dart';
import 'package:quickbites_app/src/routes/router.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/user_controller.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userController = Get.put(UserController(), permanent: true);

  await GetStorage.init();
  await userController.initUserDataOnAppStart();

  runApp(
    GetMaterialApp(debugShowCheckedModeBanner: false, home: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'QuickBites',
      routerConfig: router,
    );
  }
}
