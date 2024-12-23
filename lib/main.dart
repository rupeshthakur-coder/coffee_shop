import 'package:coffee_shop/features/admin/admin_dashboard/admin_dashbard_page.dart';
import 'package:coffee_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_shop/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:coffee_shop/features/auth/presentation/pages/log_in_page.dart';
import 'package:coffee_shop/features/auth/presentation/pages/sign_up_page.dart';
import 'package:coffee_shop/features/user/cart/bloc/cart_bloc.dart';
import 'package:coffee_shop/features/user/cart/cart_page.dart';
import 'package:coffee_shop/features/user/profile/profile_page.dart';
import 'package:coffee_shop/features/user/user_dashboard/pages/dashboard_page.dart';
import 'package:coffee_shop/firebase_options.dart';
import 'package:coffee_shop/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  init();
  final auth = FirebaseAuth.instance;
  final initialRoute = auth.currentUser != null ? '/home' : '/login';
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => sl<AuthBloc>(),
            ),
            BlocProvider<CartBloc>(
              create: (context) => CartBloc(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: initialRoute,
            routes: {
              '/login': (context) => const LogInPage(),
              '/signup': (context) => const SignUpPage(),
              '/home': (context) => const DashboardPage(),
              '/forgot-password': (context) => const ForgotPasswordPage(),
              '/cart': (context) => const CartPage(),
              '/profile': (context) => const ProfilePage(),
              '/admin': (context) => const AdminDashboardPage(),
            },
          ),
        );
      },
    );
  }
}
