import 'package:go_router/go_router.dart';
import 'package:quickbites_app/screens/caja/caja_screen.dart';
import 'package:quickbites_app/screens/kitchen/homepage_kitchen.dart';
import 'package:quickbites_app/screens/waiter/HomePage_waiter.dart';
import 'package:quickbites_app/src/signin/role_no_screen.dart';
import 'package:quickbites_app/src/signin/role_screen.dart';
import 'package:quickbites_app/src/widgets/login_screen.dart';
import 'package:quickbites_app/src/widgets/redirect_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => RedirectScreen()),
    GoRoute(
      name: 'login'.toUpperCase(),
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      name: 'manager'.toUpperCase(),
      path: '/manager',
      builder: (context, state) => ManagerScreen(),
      //routes: [GoRoute(name: 'employee'.toUpperCase(), path: 'employee')],
    ),
    GoRoute(
      name: 'no-role'.toUpperCase(),
      path: '/no-role',
      builder: (context, state) => NoRoleScreen(),
    ),
    GoRoute(
      name: 'kitchen'.toUpperCase(),
      path: '/kitchen',
      builder: (context, state) => HomePageKitchen(),
    ),
    GoRoute(
      name: 'waiter'.toUpperCase(),
      path: '/waiter',
      builder: (context, state) => const HomePageWaiter(),
    ),
    GoRoute(
      name: 'caja'.toUpperCase(),
      path: '/caja',
      builder: (context, state) => CajaScreen(),
    ),
  ],
);
