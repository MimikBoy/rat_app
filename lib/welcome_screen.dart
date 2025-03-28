import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

PageRouteBuilder<dynamic> pageTransSwipeLeft(Widget page) {
  return PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 150),
                reverseTransitionDuration: const Duration(milliseconds: 150),
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  final tween = Tween(begin: begin, end: end);
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              );
}
class WelcomeScreen extends StatelessWidget {

  const WelcomeScreen({super.key});
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
                Navigator.push(
                  context,
                  pageTransSwipeLeft(WhatAreYou()),
                );
              },
              // style: ElevatedButton.styleFrom(
              //   padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              // ),
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatAreYou extends StatelessWidget {

  const WhatAreYou({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
            Logger().i('Back button pressed');
          }, 
          icon: const Icon(Icons.arrow_back))
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // stretches children horizontally
        children: [
          SafeArea(
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Text(
                  'What are you???',
                  style: TextStyle(fontSize: 32.0),
                  textAlign: TextAlign.center,
                ),
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text('Runner'), 
                      ],
                    ),
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text('Trainer'), 
                      ],
                    ),
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