import 'package:flutter/material.dart';
import 'home.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String authError = '';
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    login(String email, String password) async {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        authError = e.message.toString();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authError)));
      }
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    }

    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
          child: Container(
        width: media.width * 0.5,
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: emailController,
              onChanged: (value) {
                email = value;
              },
              validator: ((value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Email',
              ),
            ),
            TextFormField(
              controller: passwordController,
              onChanged: (value) {
                password = value;
              },
              validator: ((value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.validate();

                  login(email, password);

                  emailController.clear();
                  passwordController.clear();
                  email = '';
                  password = '';
                },
                child: const Text('Submit')),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: (() => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  )),
              child: const Text('Not a user? Register'),
            ),
            TextButton(
              onPressed: (() => {FirebaseAuth.instance.signOut()}),
              child: const Text('Test'),
            )
          ]),
        ),
      )),
    );
  }
}
