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
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              'Generate your trainer ID',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Trainer ID: ${trainerID ?? 'Loading'}'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onContinue(1);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
