
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class TrainerDataScreen extends StatefulWidget{
  final void Function(int) onContinue;
  const TrainerDataScreen({super.key, required this.onContinue});

  @override
  State<TrainerDataScreen> createState() => _TrainerDataScreenState();
}

class _TrainerDataScreenState extends State<TrainerDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
            Logger().i('Back button pressed');
          }, 
          icon: const Icon(Icons.arrow_back),),
          ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top:15.0),
            child: Text('Generate your trainer ID', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            
          ),
        ],
      ),
    );
  }
}