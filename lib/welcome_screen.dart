import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'runner_start_screens.dart';
import 'trainer_start_screens.dart';

// Used to create a page transition effect when navigating between screens.
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

// WelcomeScreen widget to display the welcome screen
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
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: 
              ElevatedButton(
                onPressed: () {
                Logger().i('Continue button pressed');  
                  Navigator.push(
                    context,
                    pageTransSwipeLeft(WhatAreYou(onContinue: onContinue,)),
                  );
                },
                // style: ElevatedButton.styleFrom(
                //   padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                // ),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 60), // adjust width and height as needed
                ),
                child: Text('Continue', style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto')),
              ),
            ),
          )  
        ],
      ),
    );
  }
}

// To check if the user is a runner or a trainer
class WhatAreYou extends StatelessWidget {
final void Function(int) onContinue;
  const WhatAreYou({super.key, required this.onContinue});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
            Logger().i('Back button pressed');  
          }, 
          icon: const Icon(Icons.arrow_back, color: Colors.white)
          )
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min, // stretches children horizontally
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              'What are you???',
              style: TextStyle(fontSize: 32.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    margin: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {
                        Navigator.push(
                          context, 
                          pageTransSwipeLeft(DataScreen(onContinue: onContinue,)),
                        );
                      },
                      child: Center(
                        child: const Text(
                          'Runner',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Card(
                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    margin: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {
                        Navigator.push(
                          context, 
                          pageTransSwipeLeft(TrainerDataScreen(onContinue: onContinue,)),
                        );
                      },
                      child: Center(
                        child: const Text(
                          'Trainer',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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