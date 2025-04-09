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
          const SizedBox(height: 100),
          Image.asset(
            'assets/rat_icon.png',
            height: 200, // adjust as needed
          ),
          Center(
            child: SizedBox(
              child: Text(
              'Welcome to the RAT!',
              style: TextStyle(fontSize: 32.0, fontFamily: 'Roboto'),
              )
            ),
          ),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
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
          ),
          title: Text('What are you???'),
      ),
      body: Center(
        child: Transform.translate(
          offset: Offset(0, -kToolbarHeight / 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      child: Text(
                        'Runner',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                      child: Text(
                        'Trainer',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}