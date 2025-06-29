import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9E5E8),
      appBar: AppBar(
        backgroundColor:Color(0xFFB9E5E8),
        title: const Text('Home', style: TextStyle(fontSize: 24, color: Color(0xFF102E50)),),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome! You have successfully logged in.',
                style: TextStyle(fontSize: 30, color: Color(0xFF102E50)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}