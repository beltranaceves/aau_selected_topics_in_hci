import 'package:flutter/material.dart';

class PhoneThrowGamePage extends StatefulWidget {
  const PhoneThrowGamePage({super.key});

  @override
  State<PhoneThrowGamePage> createState() => _PhoneThrowGamePageState();
}

class _PhoneThrowGamePageState extends State<PhoneThrowGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Throw Game'),
        elevation: 4,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Phone Throw Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'This screen will be used to create a game that analyzes sensor data to determine how high you throw your phone in the air.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}