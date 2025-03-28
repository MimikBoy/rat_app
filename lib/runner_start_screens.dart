import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'welcome_screen.dart';

InputDecoration fieldDecoration(String hintText, String suffixText, bool showFieldError) {
  return InputDecoration(
    hintText: hintText,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    border: const OutlineInputBorder(),
    errorText: showFieldError ? 'Please enter a valid number' : null,
  );
}

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _imuToKneeController = TextEditingController();
  final TextEditingController _kneeToHipController = TextEditingController();

  bool showError = false;

  bool get formValid =>
    _weightController.text.isNotEmpty &&
    _imuToKneeController.text.isNotEmpty &&
    _kneeToHipController.text.isNotEmpty;
  

  @override

  void dispose() {
    _weightController.dispose();
    _imuToKneeController.dispose();
    _kneeToHipController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context){

    bool weightError = showError && _weightController.text.isEmpty;
    bool imuToKneeError = showError && _imuToKneeController.text.isEmpty;
    bool kneeToHipError = showError && _kneeToHipController.text.isEmpty;

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              'Give us your data!!!',
              style: TextStyle(fontSize: 32.0),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              '(You can change this later)',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text('Weight: ')
                ),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: fieldDecoration("Enter your weight", "kg", weightError),
                    onChanged: (_){
                      setState(() {});
                    },
                  )
                ),
                
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text('IMU to Knee: ')
                ),
                Expanded(
                  child: TextField(
                    controller: _imuToKneeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: fieldDecoration("Enter IMU to Knee Length", "cm", imuToKneeError),
                    onChanged: (_){
                      setState(() {});
                    },
                  )
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text('Knee to Hip: ')
                ),
                Expanded(
                  child: TextField(
                    controller: _kneeToHipController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: fieldDecoration("Enter length from Knee to Hip", "cm", kneeToHipError),
                    onChanged: (_){
                      setState(() {});
                    },
                  )
                ),
              ],
            ),
          ),
          const Spacer(),
          SafeArea(
            child: ElevatedButton(
              onPressed: formValid
              ? () {
              Logger().i('Continue button pressed');  
                Navigator.push(
                  context,
                  pageTransSwipeLeft(Placeholder()),
                );
              }
              : () {
                setState(() {
                  showError = true;
                });
              },
              child: Text('Continue'),
            ),
          )
        ],
      ),
    );
  }
}