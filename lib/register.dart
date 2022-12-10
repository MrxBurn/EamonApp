import 'package:eamon_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String password = '';
  String email = '';

  _register(email, password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Register Page')),
      body: Center(
          child: Container(
        width: media.width * 0.5,
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
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
            TextFormField(
              validator: ((value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                } else if (value != password) {
                  return 'Make sure passwords match';
                }
                return null;
              }),
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm Password',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Loading, please wait')));
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const HomePage()));

                    _register(email, password);
                  }
                },
                child: const Text('Submit')),
          ]),
        ),
      )),
    );
  }
}
