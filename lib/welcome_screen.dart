import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the RAT!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Logger().i('Continue button pressed');
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}