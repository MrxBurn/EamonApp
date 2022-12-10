import 'package:eamon_app/home.dart';
import 'package:eamon_app/jobForm.dart';
import 'package:eamon_app/login.dart';
import 'package:eamon_app/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyARJss_EoDoqO5oixp328AzKZV87d48zsk',
          appId: '1:778908630347:web:61edcf2953077290467cce',
          messagingSenderId: '778908630347',
          projectId: 'jobapp-30727'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _init = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Job App',
        routes: {
          'home': (context) => const HomePage(),
          'login': (context) => const LoginPage(),
          'register': (context) => const RegisterPage(),
          'form': ((context) => const JobForm())
        },
        theme: ThemeData.light(),
        home: FutureBuilder(
          future: _init,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("Error");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return LoginPage();
            }
            return CircularProgressIndicator();
          },
        ));
  }
}
