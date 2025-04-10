import 'dart:math';

import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainerDataScreen extends StatefulWidget {
  final void Function(int) onContinue;
  const TrainerDataScreen({super.key, required this.onContinue});

  @override
  State<TrainerDataScreen> createState() => _TrainerDataScreenState();
}

class _TrainerDataScreenState extends State<TrainerDataScreen> {
  int? trainerID;
  //replaces the default initialisation to also call _generateTrainerPrefs
  @override
  void initState() {
    super.initState();
    _generateTrainerPrefs();
  }

  //gets local handle on prefs and adds trainerID field, filling it with 7 random numbers
  Future<void> _generateTrainerPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('trainerID')) {
      prefs.setInt('trainerID', Random().nextInt(10000000));
    }
    setState(() {
      trainerID = prefs.getInt('trainerID') ?? 1234567;
    });

  }
  //TODO Markup of the page, it looks kinda ugly
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Logger().i('Back button pressed');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Generate Trainer ID'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Your new Trainer ID!!!',
                style: TextStyle(fontSize: 20.0),
              ),
              
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${trainerID ?? 'Loading'}',
                style: TextStyle(fontSize: 20.0),
              ),
              
            ),
            const Spacer(),
            SafeArea(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onContinue(1);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 60), // adjust width and height as needed
                  ),
                  child: Text('Continue', style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
