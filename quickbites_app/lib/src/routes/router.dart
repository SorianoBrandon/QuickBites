import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/signin/role_no_screen.dart';
import 'package:quickbites_app/src/signin/role_screen.dart';
import 'package:quickbites_app/src/widgets/login_screen.dart';
import 'package:quickbites_app/src/widgets/redirect_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => RedirectScreen()),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      name: 'manager',
      path: '/manager',
      builder: (context, state) => ManagerScreen(),
    ),
    GoRoute(
      name: 'no-role',
      path: '/no-role',
      builder: (context, state) => NoRoleScreen(),
    ),
  ],
);
