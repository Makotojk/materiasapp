import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:materias_app/screens/auth/login_screen.dart';
import 'package:materias_app/screens/home.dart'; // O welcome_page.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Materias App',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return FutureBuilder<String>(
              future: getEmail(),
              builder: (context, snapshotEmail) {
                if (!snapshotEmail.hasData) {
                  return const CircularProgressIndicator();
                }
                return WelcomePage(email: snapshotEmail.data!);
              },
            );
          } else {
            return SignInScreen();
          }
        },
      ),
    );
  }
}
