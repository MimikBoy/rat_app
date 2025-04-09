import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:rat_app/file_management.dart';
import 'package:flutter/services.dart';

const Color textColor = Color.fromARGB(255, 224, 224, 224);
const Color seperatorColor = Color.fromARGB(100, 189, 189, 189);
const Color redButtons = Color.fromARGB(255, 211, 47, 47);
const Color greenButtons = Color.fromARGB(255, 76, 175, 80);
const Color greyButtons = Color.fromARGB(255, 158, 158, 158);

class TrainerSettingsPage extends StatefulWidget {
  final Function(int)? changeSettingScreen;
  const TrainerSettingsPage({super.key, this.changeSettingScreen});

  @override
  State<TrainerSettingsPage> createState() => _TrainerSettingsPageState();
}

class _TrainerSettingsPageState extends State<TrainerSettingsPage> {
  int itemCount = 0;
  int trainerID = 0;
  List<String> currentList = ['Trainer ID: ', 'Edit Parameters', 'About'];
  // loads preferences
  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    trainerID = prefs.getInt('trainerID') ?? 0;
    setState(() {
      currentList[0] = 'Trainer ID: $trainerID';
    });
  }

  // runs initially to set up the class/state
  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();

    setState(() {
      itemCount = currentList.length + 1;
      currentList[0] = 'Trainer ID: $trainerID';
    });
  }

  // TODO: remove the "Edit Paramters" parts
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder:
          (context, index) =>
              const Divider(color: seperatorColor, thickness: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              currentList[index],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          );
        } else if (index < itemCount - 1) {
          return InkWell(
            onTap: () {
              if (index == 1) {
                if (widget.changeSettingScreen != null) {
                  widget.changeSettingScreen!(
                    3,
                  ); //TODO Navigate to Edit Parameters page
                    //Currently it seems to not be able to change the index state of the trainer_screens_controller
                } else {
                  Logger().e('changeSettingScreen is null');
                }
                Logger().i('Edit Parameters button pressed');
              } else if (index == 2) {
                Logger().i('About button pressed');
                if (widget.changeSettingScreen != null) {
                  widget.changeSettingScreen!(
                    4,
                  ); // Navigate to About page (NOT IMPLEMENTED)
                } else {
                  Logger().e('changeSettingScreen is null');
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                // Instead of extra margin, only use internal padding.
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentList[index],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
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
InputDecoration fieldDecoration(
  String hintText,
  String suffixText,
  bool showFieldError,
) {
  return InputDecoration(
    hintText: hintText,
    suffixText: suffixText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    border: const OutlineInputBorder(),
    errorText: showFieldError ? 'Please enter a valid number' : null,
  );
}

class TrainerParametersPage extends StatefulWidget {
  const TrainerParametersPage({super.key});

  @override
  State<TrainerParametersPage> createState() => _TrainerParametersPageState();
}

class _TrainerParametersPageState extends State<TrainerParametersPage> {
  final TextEditingController _trainerIDController = TextEditingController();

  bool showError = false;

  bool get formValid =>
      _trainerIDController.text.isNotEmpty &&
      _trainerIDController.text.length == 7;

  @override
  void dispose() {
    _trainerIDController.dispose();
    super.dispose();
  }
  String trainerIDHintText = '';

  void _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      trainerIDHintText = prefs.getInt('trainerID')?.toString() ?? 'Trainer ID';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.only(
              right: 15.0,
              left: 15.0,
              bottom: 15.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 15.0,
              left: 15.0,
              bottom: 15.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 15.0,
              left: 15.0,
              bottom: 15.0,
            ),
            child: Row(
              children: [
                SizedBox(width: 110, child: Text('Trainer ID: ')),
                Expanded(
                  child: TextField(
                    controller: _trainerIDController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: fieldDecoration(
                      trainerIDHintText,
                      "",
                      trainerIDError,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed:
                    formValid
                        ? () async {
                          if (!mounted) return;
                          Navigator.pop(context);
                          Logger().i('Continue button pressed');
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setInt(
                            'trainerID',
                            int.parse(_trainerIDController.text),
                          );
                        }
                        : () {
                          setState(() {
                            showError = true;
                          });
                        },
                child: Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
