import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeScreen({super.key, required this.onContinue});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                  child: Text(
                    'Welcome to the RAT!',
                    style: TextStyle(fontSize: 32.0),)
                  ),
            ),
          ),    
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: ElevatedButton(
              onPressed: () {
              Logger().i('Continue button pressed');
              onContinue();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              ),
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}