import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creates a page transition effect when navigating between screens.
///
/// This function returns a [PageRouteBuilder] that slides the new page
/// from the right to the left.
///
/// Parameters: 
/// - [page]: The widget to navigate to.
/// 
/// Returns:
/// - A [PageRouteBuilder] that defines the transition animation.
InputDecoration fieldDecoration(String hintText, String suffixText, bool showFieldError) {
  return InputDecoration(
    hintText: hintText,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    border: const OutlineInputBorder(),
    errorText: showFieldError ? 'Please enter a valid number' : null,
  );
}

/// DataScreen is a StatefulWidget that collects user data for the app. It also saves the data to shared preferences.
///
/// Parameters: 
/// - [onContinue]: A callback function that is triggered when the user presses the "Continue" button.
/// 
/// Returns:
/// - [Scaffold] widget that contains the form for user data input.
class DataScreen extends StatefulWidget {
  final void Function(int) onContinue;
  const DataScreen({super.key, required this.onContinue});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  // Used to check if the form is valid
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _imuToKneeController = TextEditingController();
  final TextEditingController _kneeToHipController = TextEditingController();
  final TextEditingController _trainerIDController = TextEditingController();

  bool showError = false;
  bool showErrorSkip = false;

  bool get formValid =>
    _weightController.text.isNotEmpty &&
    _imuToKneeController.text.isNotEmpty &&
    _kneeToHipController.text.isNotEmpty &&
    _trainerIDController.text.isNotEmpty;
  
  // Dispose the controllers when the widget is removed from the widget tree
  @override
  void dispose() {
    _weightController.dispose();
    _imuToKneeController.dispose();
    _kneeToHipController.dispose();
    _trainerIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    bool weightError = showError && _weightController.text.isEmpty;
    bool imuToKneeError = showError && _imuToKneeController.text.isEmpty;
    bool kneeToHipError = showError && _kneeToHipController.text.isEmpty;
    bool trainerIDError = (showError && _trainerIDController.text.isEmpty) || (showErrorSkip && _trainerIDController.text.isEmpty);

    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
            Logger().i('Back button pressed');
          }, 
          icon: const Icon(Icons.arrow_back)),
        title: const Text('Give us your data!!!'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              '(You can change this later)',
              style: TextStyle(fontSize: 15.0),
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
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text('Trainer ID: ')
                ),
                Expanded(
                  child: TextField(
                    controller: _trainerIDController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: fieldDecoration("Enter your trainers ID", "", trainerIDError),
                    onChanged: (_){
                      setState(() {});
                    },
                  )
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextButton(
              onPressed: _trainerIDController.text.isNotEmpty
                ? () async {
                  Logger().i('Continue button pressed');
                  Navigator.popUntil(context, (route) => route.isFirst);
                  // Save the data to shared preferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt('weight', 76);
                  prefs.setInt('imuToKnee', 41);
                  prefs.setInt('kneeToHip', 56);
                  prefs.setInt('trainerID', int.parse(_trainerIDController.text));
                  prefs.setInt('mode', 0);
                  widget.onContinue(0);
                  prefs.setInt('runnerID', Random().nextInt(10000000));
                }
                : () {
                  setState(() {
                    showErrorSkip = true;
                  });
                },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Theme.of(context).colorScheme.onPrimary, // Set text color
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 60), // adjust width and height as needed
                ),
                onPressed: formValid
                ? () async {
                  Logger().i('Continue button pressed');  
                  Navigator.popUntil(context, (route) => route.isFirst);
                  // Save the data to shared preferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt('weight', int.parse(_weightController.text));
                  prefs.setInt('imuToKnee', int.parse(_imuToKneeController.text));
                  prefs.setInt('kneeToHip', int.parse(_kneeToHipController.text));
                  prefs.setInt('trainerID', int.parse(_trainerIDController.text));
                  prefs.setInt('mode', 0);
                  widget.onContinue(0);
                  prefs.setInt('runnerID', Random().nextInt(10000000));
                }
                : () {
                  setState(() {
                    showError = true;
                  });
                },
                child: Text('Continue', style: TextStyle(fontSize: 16.0, fontFamily: 'Roboto')),
              ),
            ),
          )
        ],
      ),
    );
  }
}
