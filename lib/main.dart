import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login.dart';
import 'selection1.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await SessionService.init();

  final box = Hive.box('userBox');
  final bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // If logged in → always show Selection1Page (user picks board+class every time)
      // If not logged in → LoginPage
      home: isLoggedIn ? const Selection1Page() : const LoginPage(),
    );
  }
}