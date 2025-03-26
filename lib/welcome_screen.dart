import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class WelcomeScreen extends StatelessWidget {
  final void Function(int) onContinue;

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
                    style: TextStyle(fontSize: 32.0, fontFamily: 'Roboto'),
                    )
                  ),
            ),
          ),    
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: ElevatedButton(
              onPressed: () {
              Logger().i('Continue button pressed');
              onContinue(-1);
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

class WhatAreYou extends StatelessWidget {
  final void Function(int) onContinue;

  const WhatAreYou({super.key, required this.onContinue});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // stretches children horizontally
        children: [
          SafeArea(
            child: SizedBox(
              child: Text(
                'What are you???',
                style: TextStyle(fontSize: 32.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // makes buttons fill vertical space
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Left button action
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('Left'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Right button action
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('Right'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}