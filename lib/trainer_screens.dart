import 'package:flutter/material.dart';

class TrainerScreensController extends StatelessWidget {
  const TrainerScreensController({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weee ur a trainer")),
      body: Column(children: [Text('first line'), Text('second line')]),
    );
  }
}
