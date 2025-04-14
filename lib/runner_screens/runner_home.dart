import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:rat_app/utils/bluetooth.dart';
import 'package:rat_app/utils/file_management.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const Color textColor = Color.fromARGB(255, 224, 224, 224);
const Color redButtons = Color.fromARGB(255, 211, 47, 47);
const Color greenButtons = Color.fromARGB(255, 76, 175, 80);
const Color greyButtons = Color.fromARGB(255, 158, 158, 158);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


class RunnerHomePage extends StatefulWidget {
  final Function(int batteryPercentage, bool isLeft) onBatteryPercentageUpdate;
  const RunnerHomePage({super.key, required this.onBatteryPercentageUpdate});

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
  List<String> leftNames = ['grfLeft', 'timeGrfLeft', 'timeGroundLeft', 'groundContactLeft', 'angleLeft', 'timeAngleLeft', 'alert', 'battery'];
  List<String> rightNames = ['grfRight', 'timeGrfRight', 'timeGroundRight', 'groundContactRight', 'angleRight', 'timeAngleRight', 'alert', 'battery'];

  Map<String, List<double>> toStore = {
    'grfLeft': [],
    'grfRight': [],
    'timeGrfLeft': [],
    'timeGrfRight': [],
    'timeGroundLeft': [],
    'timeGroundRight': [],
    'angleLeft': [],
    'angleRight': [],
    'timeAngleLeft': [],
    'timeAngleRight': [],
  };



  List<List<double>> dataPointsToSave = List.generate(10, (_) => []);
  List<List<String>> dataPointsRecieved = List.generate(12, (_) => []);

  List<List<double>> convertToDouble(List<List<String>> dataPointsRecievedTemp) {
    int minLength = dataPointsRecievedTemp[0].length < dataPointsRecievedTemp[6].length ? dataPointsRecievedTemp[0].length : dataPointsRecievedTemp[6].length;
    dataPointsRecievedTemp[0] = dataPointsRecievedTemp[0].sublist(0, minLength);
    dataPointsRecievedTemp[6] = dataPointsRecievedTemp[6].sublist(0, minLength);
    List<List<double>> temp = List.generate(12, (_) => []);
    for (int i = 0; i < dataPointsRecievedTemp.length; i++) {
      temp[i] = dataPointsRecieved[i].map((s) => double.parse(s)).toList();
      if (i == 6) {
        temp[i] = List.generate(
          minLength, 
          (index) => temp[0][index] + temp[i][index]
        );
      }
    }

    temp [0] = List.generate(
      minLength, 
      (index) => temp[6][index]*temp[3][index]
    );
    temp [6] = List.generate(
      minLength, 
      (index) => temp[6][index]*temp[9][index]
    );

    temp.removeAt(3);
    temp.removeAt(9);
    return temp;
  }

  Future<void> _countdown() async{
    if (!mounted) return;
      setState(() {
        _buttonColor = Colors.orange;
        _timerText = 'Please stand still and straight';
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

      BluetoothManager().sendData('start $weight $kneeToHip $imuToKnee');

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

    if (dataPointsRecieved.isEmpty) {
      Logger().i('No data to save');
    }
    Logger().i('Data to save: grfL: ${dataPointsToSave[0]}\n grfR: ${dataPointsToSave[1]}\n grfTL: ${dataPointsToSave[2]}\n grfTR: ${dataPointsToSave[3]}\n groundL: ${dataPointsToSave[4]}\n groundR: ${dataPointsToSave[5]}\n angL: ${dataPointsToSave[6]}\n angR: ${dataPointsToSave[7]}\n angTL: ${dataPointsToSave[8]}\n angTR: ${dataPointsToSave[9]}');
    
    dataPointsToSave = convertToDouble(dataPointsRecieved);

    int i = 0;
    toStore.forEach((key, value) {
      toStore[key] = dataPointsToSave[i];
      i++;
    });

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

  Future<void> handleAlertNotification(String data, String title) async{
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'alert_channel', // Channel ID
          'Alerts', // Channel name
          channelDescription: 'Notifications for alerts',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('sound_effects/metal-pipe.mp3'),
        );

        const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      final int notificationId = DateTime.now().millisecondsSinceEpoch;

      await flutterLocalNotificationsPlugin.show(
        notificationId, // Notification ID
        title, // Notification title
        data, // Notification body
        platformChannelSpecifics,
      );
  }

  void playMetalPipe(){
    final player = AudioPlayer();
    player.play(AssetSource('sound_effects/metal-pipe.mp3'));
  }

  bool _isDialogVisible = false;

  void alertDialogBox(String title, String message) {
    if (mounted && !_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  _isDialogVisible = false;
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ).then((_) {
        _isDialogVisible = false;
      });
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
      // if (data.startsWith('alert')){
      //   Logger().e('Alert: $data');
      //   // playMetalPipe();
      //   // alertDialogBox('Alert Left', data);
      //   handleAlertNotification(data, 'Alert Left');
      //   return;
      // }
      data = data.substring(0);
      List<String> dataString = data.substring(5).split("|");
      
      for (String dataPoint in dataString){
        for (int i = 0; i < (dataPointsRecieved.length/2).toInt(); i++){
          if (dataPoint.startsWith(leftNames[i])){
            dataPointsRecieved[i].add(dataPoint.substring(leftNames[i].length));
          }
        }
        if (dataPoint.startsWith(leftNames[6])){
          Logger().e('Alert: ${dataPoint.substring(leftNames[6].length)}');
          // playMetalPipe();
          // alertDialogBox('Alert Left', dataPoint.substring(leftNames[5].length));
          handleAlertNotification(dataPoint.substring(leftNames[6].length), 'Alert Left');
        } else if (dataPoint.startsWith(leftNames[7])){
          widget.onBatteryPercentageUpdate(int.parse(dataPoint.substring(leftNames[7].length)), true);
        }
      }
      Logger().i('Left data: $data');
    });

    btManager.rightDataStream.listen((data) {

      Logger().i('Right data: $data');
      data = data.substring(0);
      List<String> dataString = data.substring(5).split("|");
      
      for (String dataPoint in dataString){
        for (int i = (dataPointsRecieved.length/2).toInt() ; i < dataPointsRecieved.length; i++){
          if (dataPoint.startsWith(rightNames[i])){
            dataPointsRecieved[i].add(dataPoint.substring(rightNames[i].length));
          }
        }
        if (dataPoint.startsWith(rightNames[6])){
          Logger().e('Alert: ${dataPoint.substring(rightNames[6].length)}');
          // playMetalPipe();
          // alertDialogBox('Alert Left', dataPoint.substring(leftNames[5].length));
          handleAlertNotification(dataPoint.substring(rightNames[6].length), 'Alert Right');
        } else if (dataPoint.startsWith(rightNames[7])){
          widget.onBatteryPercentageUpdate(int.parse(dataPoint.substring(rightNames[7].length)), true);
        }
      }

      Logger().i('Right data: $data');
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
