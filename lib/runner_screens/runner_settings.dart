import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rat_app/utils/file_management.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/services.dart';

class RunnerSettingsPage extends StatefulWidget {
  final Function(int)? changeSettingScreen;
  const RunnerSettingsPage({super.key, this.changeSettingScreen});

  @override
  State<RunnerSettingsPage> createState() => _RunnerSettingsPageState();
}


class _RunnerSettingsPageState extends State<RunnerSettingsPage> {
  int itemCount = 0;
  int runnerID = 0;
  List<String> currentList = [
    'Runner ID: ',
    'Edit Parameters',
    'About',
  ];

  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    runnerID = prefs.getInt('runnerID') ?? 0;
    setState(() {
      currentList[0] = 'Runner ID: $runnerID';
    });
  }

  @override
  void initState(){
    super.initState();
    _loadSharedPreferences();

    setState(() {
      itemCount = currentList.length + 1;
      currentList[0] = 'Runner ID: $runnerID';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index == 0){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              currentList[index],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            )
          );
        } else if (index < itemCount-1) {
          return InkWell(
            onTap: () {
              if (index == 1) {
                if (widget.changeSettingScreen != null) {
                  widget.changeSettingScreen!(3); // Navigate to Edit Parameters page
                } else {
                  Logger().e('changeSettingScreen is null');
                }
                Logger().i('Edit Parameters button pressed');
              } else if (index == 2) {
                Logger().i('About button pressed');
                if (widget.changeSettingScreen != null) {
                  widget.changeSettingScreen!(4); //TODO this doesn't work
                } else {
                  Logger().e('changeSettingScreen is null');
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                // Instead of extra margin, only use internal padding.
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentList[index],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              onPressed: () {
                Logger().i('Cleared all local data');
                SaveFileHandler().clearLocalData();
                Phoenix.rebirth(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 211, 47, 47),
                foregroundColor: Color.fromARGB(255, 238, 238, 238),
                fixedSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Reduced rounding
                ),
              ),
              child: const Text(
                'Clear Local Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      },
    );
  }
}

// Field Decoration for integer input fields
InputDecoration fieldDecoration(String hintText, String suffixText, bool showFieldError) {
  return InputDecoration(
    hintText: hintText,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    border: const OutlineInputBorder(),
    errorText: showFieldError ? 'Please enter a valid number' : null,
  );
}
class EditParametersPage extends StatefulWidget {
  const EditParametersPage({super.key});

  @override
  State<EditParametersPage> createState() => _EditParametersPageState();
}

class _EditParametersPageState extends State<EditParametersPage> {

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _imuToKneeController = TextEditingController();
  final TextEditingController _kneeToHipController = TextEditingController();
  final TextEditingController _trainerIDController = TextEditingController();

  bool showError = false;

  bool get formValid =>
    _weightController.text.isNotEmpty &&
    _imuToKneeController.text.isNotEmpty &&
    _kneeToHipController.text.isNotEmpty &&
    _trainerIDController.text.isNotEmpty;
  

  @override

  void dispose() {
    _weightController.dispose();
    _imuToKneeController.dispose();
    _kneeToHipController.dispose();
    _trainerIDController.dispose();
    super.dispose();
  }

  String weightHintText = '';
  String imuToKneeHintText = '';
  String kneeToHipHintText = '';
  String trainerIDHintText = '';

  void _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      weightHintText = prefs.getInt('weight')?.toString() ?? 'Enter your weight';
      imuToKneeHintText = prefs.getInt('imuToKnee')?.toString() ?? 'IMU to Knee Length';
      kneeToHipHintText = prefs.getInt('kneeToHip')?.toString() ?? 'Knee to Hip Length';
      trainerIDHintText = prefs.getInt('trainerID')?.toString() ?? 'Trainer ID';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  @override
  Widget build(BuildContext context){

    bool weightError = showError && _weightController.text.isEmpty;
    bool imuToKneeError = showError && _imuToKneeController.text.isEmpty;
    bool kneeToHipError = showError && _kneeToHipController.text.isEmpty;
    bool trainerIDError = showError && _trainerIDController.text.isEmpty;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              'Change Parameters',
              style: TextStyle(fontSize: 32.0),
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
                    decoration: fieldDecoration(weightHintText, "kg", weightError),
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
                    decoration: fieldDecoration(imuToKneeHintText, "cm", imuToKneeError),
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
                    decoration: fieldDecoration(kneeToHipHintText, "cm", kneeToHipError),
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
                    decoration: fieldDecoration(trainerIDHintText, "", trainerIDError),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: formValid
                ? () async {
                  if (!mounted) return;
                  Navigator.pop(context);
                  Logger().i('Continue button pressed');  
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt('weight', int.parse(_weightController.text));
                  prefs.setInt('imuToKnee', int.parse(_imuToKneeController.text));
                  prefs.setInt('kneeToHip', int.parse(_kneeToHipController.text));
                  prefs.setInt('trainerID', int.parse(_trainerIDController.text));
                  
                }
                : () {
                  setState(() {
                    showError = true;
                  });
                },
                child: Text('Save'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
