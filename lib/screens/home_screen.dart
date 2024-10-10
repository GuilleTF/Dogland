import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Dogland!'),
      ),
      body: Center(
        child: Text(
          'Welcome, you are now logged in!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
