import 'package:go_router/go_router.dart';
import 'package:quickbites_app/src/signin/role_no_screen.dart';
import 'package:quickbites_app/src/signin/role_screen.dart';
import 'package:quickbites_app/src/widgets/login_screen.dart';



final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/manager',
        name: 'manager',
        builder: (context, state) { 
          final user = state.extra as Map;
          return ManagerScreen(user: user); 
        },
      ),
      GoRoute(
        path: '/no-role',
        name: 'no-role',
        builder: (context, state) => NoRoleScreen(),
      ),
    ]);