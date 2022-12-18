import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: (() {
              Navigator.of(context).pushNamed('form');
            }),
            child: const Text('New Job'),
          ),
          ElevatedButton(
            onPressed: (() {
              FirebaseAuth.instance.signOut();
            }),
            child: const Text('Sign Out'),
          ),
          ElevatedButton(
            onPressed: (() {
              Navigator.of(context).pushNamed('sqmReport');
            }),
            child: const Text('SQM Report'),
          )
        ],
      )),
    );
  }
}
