import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:async';
import 'file_management.dart';
import 'bluetooth.dart';

const Color textColor = Color.fromARGB(255, 224, 224, 224);
const Color redButtons = Color.fromARGB(255, 211, 47, 47);
const Color greenButtons = Color.fromARGB(255, 76, 175, 80);
const Color greyButtons = Color.fromARGB(255, 158, 158, 158);

class RunnerPageManager extends StatefulWidget{
  const RunnerPageManager({super.key});

  @override
  State<RunnerPageManager> createState() => _RunnerPageManagerState();
}

class _RunnerPageManagerState extends State<RunnerPageManager> {
  int screenIndex = 0;
  IconData leftBatteryIcon = Icons.battery_unknown_rounded;
  IconData rightBatteryIcon = Icons.battery_unknown_rounded;
  Color leftBatteryColor = Colors.white;
  Color rightBatteryColor = Colors.white;
  String appBarTitle = 'Home';


  IconButton leadingIcon = IconButton(
          icon: const Icon(Icons.circle_outlined, size: 30),
          onPressed: () {
            Logger().i('Profile button pressed');
          },
        );

  Future<void> handleBatteryButtonPress() async {
    
    Logger().i('Battery button pressed');
    BluetoothManager btManager = BluetoothManager();
    int connectionStatus = await btManager.connectToDevices();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasBeenCalled = prefs.getBool('hasBeenCalled') ?? false;

    if (!hasBeenCalled){
      btManager.receiveData();
      prefs.setBool('hasBeenCalled', true);
    }

    String? deviceLeftAddress = prefs.getString('deviceLeftAddress');
    String? deviceRightAddress = prefs.getString('deviceRightAddress');

    final service = FlutterBackgroundService();
    service.invoke('initializeBluetooth', {
      'deviceLeftAddress': deviceLeftAddress,
      'deviceRightAddress': deviceRightAddress,
    });

    BluetoothManager().sendData('battery');

    setState(() {
      // Update icon colors based on the connection status
      leftBatteryColor = (connectionStatus & 1) != 0 ? greenButtons : Colors.white;
      leftBatteryIcon = (connectionStatus & 1) != 0 ? Icons.battery_full_rounded : Icons.battery_unknown_rounded;
      rightBatteryColor = (connectionStatus & 2) != 0 ? greenButtons : Colors.white;
      rightBatteryIcon = (connectionStatus & 2) != 0 ? Icons.battery_full_rounded : Icons.battery_unknown_rounded; // Right connected
    });
  }

  void _changeSettingsScreen(int index) {
    setState(() {
      screenIndex = index;
      if (index == 3) {
        appBarTitle = 'Parameters';
      } else if (index == 4) {
        appBarTitle = 'About';
      }
      leadingIcon = IconButton(
        icon: const Icon(Icons.arrow_back, size: 30),
        onPressed: () {
          setState(() {
            screenIndex = 2;
            appBarTitle = 'Settings';
            leadingIcon = IconButton(
              icon: const Icon(Icons.circle_outlined, size: 30),
              onPressed: () {
                Logger().i('Profile button pressed');
              },
            );
          });
          Logger().i('Back button pressed');
        },
      );

    });
  }

  @override
  Widget build(BuildContext context){
    Widget page;
    switch (screenIndex) {
      case 0:
        page = RunnerHomePage();
        setState(() {
            leadingIcon = IconButton(
              icon: const Icon(Icons.circle_outlined, size: 30),
              onPressed: () {
                Logger().i('Profile button pressed');
              },
            );
          });
        break;
      case 1:
        page = const RunnerDownloadPage();
        setState(() {
            leadingIcon = IconButton(
              icon: const Icon(Icons.circle_outlined, size: 30),
              onPressed: () {
                Logger().i('Profile button pressed');
              },
            );
          });
        break;
      case 2:
        page = RunnerSettingsPage(changeSettingScreen: _changeSettingsScreen,);
        setState(() {
            leadingIcon = IconButton(
              icon: const Icon(Icons.circle_outlined, size: 30),
              onPressed: () {
                Logger().i('Profile button pressed');
              },
            );
          });
        break;
      case 3:
        page = const EditParametersPage();
        break;
      default:
        page = RunnerHomePage();
    }

    return Scaffold(
      appBar: AppBar(        
        title: Text(appBarTitle),
        leading: leadingIcon,
        actions: [
          IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(leftBatteryIcon, size: 30, color: leftBatteryColor,),
                Icon(rightBatteryIcon, size: 30, color: rightBatteryColor,)
              ],
            ),
            onPressed: handleBatteryButtonPress,
          ),
        ],
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download, size: 30),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
        currentIndex: screenIndex > 2 ? 2 : screenIndex,
        onTap: (index) {
          setState(() {
            screenIndex = index;
            appBarTitle = index == 0 ? 'Home' : index == 1 ? 'Downloads' : 'Settings';
          });
          Logger().i('Bottom navigation bar item $index pressed');
        },
      ),
    );
  }
}

class RunnerHomePage extends StatefulWidget {
  const RunnerHomePage({super.key});

  @override
  State<RunnerHomePage> createState() => _RunnerHomePageState();
}

class _RunnerHomePageState extends State<RunnerHomePage> {

  Color defaultButtonColor = Color.fromARGB(255, 76, 175, 80);

  Color _buttonColor = Color.fromARGB(255, 76, 175, 80);
  final timeToStart = 5;
  bool _isCountingDown = false;
  Timer? _timer;
  Widget _buttonChild = const Icon(Icons.play_arrow_rounded, size: 100, color: Color.fromARGB(255, 224, 224, 224));
  String _timerText = 'Start';
  DateTime? _startTime;
  final service = FlutterBackgroundService();
  Map<String, List<double>> toStore = {};

  List<String> angleLeft = [], angleRight = [], timeAngleLeft = [], timeAngleRight = [],
              grfLeft = [], grfRight = [], timeGrfLeft = [], timeGrfRight = [], timeGroundLeft = [], timeGroundRight = [];

  Future<void> _countdown() async{
    if (!mounted) return;
      setState(() {
        _buttonColor = Colors.orange;
        _timerText = 'Please stand still';
      });
      for (int i = 0; i < timeToStart; i++) {
        _isCountingDown = true;
        
        Logger().i('$i');
        if (!mounted) return;
        setState((){
          _buttonChild = Text(
            (timeToStart-i).toString(),
            style: const TextStyle(
              fontSize: 50.0,
              fontFamily: 'Roboto',
              color: Color.fromARGB(255, 224, 224, 224),
            ),
          );
        });

        await Future.delayed(const Duration(seconds: 1));
      }
  }

  void _setToStop(){
    if (!mounted) return;
    setState((){
      _buttonChild = const Icon(Icons.stop_rounded, size: 100, color: Color.fromARGB(255, 224, 224, 224));
      _buttonColor = redButtons;
    });
  }

  void _startStopButton()  async{
    if (_buttonColor == defaultButtonColor) {
      Logger().i('Button color changed to red');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int weight = prefs.getInt('weight') ?? 0;
      int imuToKnee = prefs.getInt('imuToKnee') ?? 0;
      int kneeToHip = prefs.getInt('kneeToHip') ?? 0;

      BluetoothManager().sendData('start $weight $imuToKnee $kneeToHip');

      await _countdown();

      _setToStop();

      _startTimer(0);


    } else {

      Logger().i('Button color changed to green');
      BluetoothManager().sendData('stop');
      setState((){
        _buttonChild = const Icon(Icons.play_arrow_rounded, size: 100, color: Color.fromARGB(255, 224, 224, 224));
        _buttonColor = defaultButtonColor;
      });
      await Future.delayed(const Duration(milliseconds: 100)); 
      stopTimer();
    }
    _isCountingDown = false;
  }

  void _startTimer(int alreadyStarted) async{
    
    _timer?.cancel();
    if (alreadyStarted == 0){
      _startTime = DateTime.now();
      final now = DateTime.now();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('timerStart', now.millisecondsSinceEpoch);
      await prefs.setInt('timerOn', 1);
    }

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer){
      final now = DateTime.now();
      if (!mounted) return;
      final elapsed = now.difference(_startTime!);
      setState(() {
        _timerText = _formatTime(elapsed);
      });
    });
  }
  
  void stopTimer() async {
    _timer?.cancel();

    if (grfLeft == [] && grfRight == [] && timeGrfLeft == [] && timeGrfRight == [] && timeGroundLeft == [] && timeGroundRight == [] && angleLeft == [] && angleRight == [] && timeAngleLeft == [] && timeAngleRight == []) {
      Logger().i('No data to save');
    }
    Logger().i('Data to save: $grfLeft, $grfRight, $timeGrfLeft, $timeGrfRight, $timeGroundLeft, $timeGroundRight, $angleLeft, $angleRight, $timeAngleLeft, $timeAngleRight');
    
    toStore = {
      "grfLeft": grfLeft.map((e) => double.parse(e)).toList(),
      "grfRight": grfRight.map((e) => double.parse(e)).toList(),
      "timeGrfLeft": timeGrfLeft.map((e) => double.parse(e)).toList(),
      "timeGrfRight": timeGrfRight.map((e) => double.parse(e)).toList(),
      "timeGroundLeft": timeGroundLeft.map((e) => double.parse(e)).toList(),
      "timeGroundRight": timeGroundRight.map((e) => double.parse(e)).toList(),
      "angleLeft": angleLeft.map((e) => double.parse(e)).toList(),
      "angleRight": angleRight.map((e) => double.parse(e)).toList(),
      "timeAngleLeft": timeAngleLeft.map((e) => double.parse(e)).toList(),
      "timeAngleRight": timeAngleRight.map((e) => double.parse(e)).toList(),
    };

    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('timerOn', 0);

    List<String> currentList = prefs.getStringList('fileNames') ?? [];
    currentList.add(_startTime.toString().substring(0, _startTime.toString().length - 4));
    await prefs.setStringList('fileNames', currentList);

    int trainerID = prefs.getInt('trainerID') ?? 0;  //should this be an await?
    SaveFileHandler fileHandler = SaveFileHandler();
    fileHandler.data = toStore;
    await fileHandler.saveData(_startTime.toString().substring(0, _startTime.toString().length - 4), trainerID);
  }

  String _formatTime(Duration elapsed) {
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds =
        (elapsed.inMilliseconds.remainder(1000)).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$milliseconds';
  }

  Future<void> _checkTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final timerOn = prefs.getInt('timerOn');
    if (timerOn == 1) {
      final startTime = prefs.getInt('timerStart');
      if (startTime != null) {
        _startTime = DateTime.fromMillisecondsSinceEpoch(startTime);
        _setToStop();
        _startTimer(1);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BluetoothManager btManager = BluetoothManager();

    btManager.leftDataStream.listen((data) {
      
      Logger().i('Left data: $data');
    });

    btManager.rightDataStream.listen((data) {
      setState(() {
        Logger().i('Right data: $data');
      });
    });

    _checkTimer();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 80.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(60, 0, 0, 0),
                    blurRadius: 15,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isCountingDown
                ? null
                : () {
                  Logger().i('Start button pressed');
                  _startStopButton();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20.0),
                  backgroundColor: _buttonColor,
                  foregroundColor: Color.fromARGB(255, 224, 224, 224),
                  disabledBackgroundColor: _buttonColor,
                  fixedSize: const Size(250, 250),
                  
                ),
                child: _buttonChild,
              ),
            ),
          ),
          Text(
            _timerText,
            style: const TextStyle(
              fontSize: 30.0,
              fontFamily: 'Roboto',
            ),
          ),

        ],
      ),
    );
  }
}

class RunnerDownloadPage extends StatefulWidget {
  const RunnerDownloadPage({super.key});

  @override
  State<RunnerDownloadPage> createState() => _RunnerDownloadPageState();
}

class _RunnerDownloadPageState extends State<RunnerDownloadPage> {
  int itemCount = 0;
  List<String> currentList = [];

  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentList = prefs.getStringList('fileNames') ?? [];
    setState(() {
      itemCount = currentList.length;
    });
  }

  void _moveToDownloads(String fileName) async {
    try{
      SaveFileHandler fileManager = SaveFileHandler();
      await fileManager.download(fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File moved to Downloads'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Logger().e('Error copying file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to move file: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _deleteFile(String fileName, int index) async {
    bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$fileName"?',),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(255, 100, 181, 246)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color.fromARGB(255, 100, 181, 246)),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

    try {
      SaveFileHandler fileManager = SaveFileHandler();
      await fileManager.delete(fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File deleted'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Logger().e('Error deleting file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete file: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentListTemp = prefs.getStringList('fileNames') ?? [];
    currentListTemp.removeAt(index);
    await prefs.setStringList('fileNames', currentListTemp);

    setState(() {
      currentList.removeAt(index);
      itemCount = currentList.length;
    });

  }

  @override
  void initState(){
    super.initState();
    _loadSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentList[itemCount - index - 1],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _moveToDownloads(currentList[itemCount - index - 1]);
                    },
                    icon: Icon(Icons.download_rounded),
                    color: greenButtons,
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteFile(currentList[itemCount - index - 1], itemCount - index - 1);
                    },
                    icon: Icon(Icons.delete_rounded),
                    color: redButtons,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

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