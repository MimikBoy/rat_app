import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rat_app/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'file_management.dart';
import 'bluetooth.dart';

class RunnerPageManager extends StatefulWidget{
  final BluetoothManager btManager;
  const RunnerPageManager({super.key, required this.btManager});

  @override
  State<RunnerPageManager> createState() => _RunnerPageManagerState();
}

class _RunnerPageManagerState extends State<RunnerPageManager> {
  int screenIndex = 0;
  IconData leftBatteryIcon = Icons.battery_unknown_rounded;
  IconData rightBatteryIcon = Icons.battery_unknown_rounded;
  Color leftBatteryColor = Colors.grey;
  Color rightBatteryColor = Colors.grey;
  String appBarTitle = 'Home';

  Future<void> handleBatteryButtonPress() async {
    Logger().i('Battery button pressed');
    int connectionStatus = await btManager.connectToDevices();

    setState(() {
      // Update icon colors based on the connection status
      leftBatteryColor = (connectionStatus & 1) != 0 ? Colors.green : Colors.grey;
      leftBatteryIcon = (connectionStatus & 1) != 0 ? Icons.battery_full_rounded : Icons.battery_unknown_rounded;
      rightBatteryColor = (connectionStatus & 2) != 0 ? Colors.green : Colors.grey;
      rightBatteryIcon = (connectionStatus & 2) != 0 ? Icons.battery_full_rounded : Icons.battery_unknown_rounded; // Right connected
    });
  }

  @override
  Widget build(BuildContext context){
    Widget page;
    switch (screenIndex) {
      case 0:
        page = const RunnerHomePage();
        break;
      case 1:
        page = const RunnerDownloadPage();
        break;
      case 2:
        page = Placeholder();
        break;
      default:
        page = const RunnerHomePage();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.circle_outlined, size: 30),
          onPressed: () {
            Logger().i('Profile button pressed');
          },
        ),
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
        currentIndex: screenIndex,
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

  Color _buttonColor = Colors.green;
  final timeToStart = 5;
  bool _isCountingDown = false;
  Timer? _timer;
  Widget _buttonChild = const Icon(Icons.play_arrow_rounded, size: 100, color: Colors.white);
  String _timerText = 'Start';
  DateTime? _startTime;
  final service = FlutterBackgroundService();
  Map<String, List<double>> toStore = {};

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
              color: Colors.white,
            ),
          );
        });

        await Future.delayed(const Duration(seconds: 1));
      }
  }

  void _setToStop(){
    if (!mounted) return;
    setState((){
      _buttonChild = const Icon(Icons.stop_rounded, size: 100, color: Colors.white);
      _buttonColor = Colors.red;
    });
  }

  void _startStopButton()  async{
    if (_buttonColor == Colors.green) {
      Logger().i('Button color changed to red');
      await service.startService();
      await _countdown();
      _setToStop();
      _startTimer(0);
    } else {

      Logger().i('Button color changed to green');
      final service = FlutterBackgroundService();
      service.invoke('stopService');
      setState((){
        _buttonChild = const Icon(Icons.play_arrow_rounded, size: 100, color: Colors.white);
        _buttonColor = Colors.green;
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
    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('timerOn', 0);

    List<String> currentList = prefs.getStringList('fileNames') ?? [];
    currentList.add(_startTime.toString().substring(0, _startTime.toString().length - 4));
    await prefs.setStringList('fileNames', currentList);

    int trainerID = prefs.getInt('trainerID') ?? 0;
    SaveFileHandler fileHandler = SaveFileHandler(_startTime.toString().substring(0, _startTime.toString().length - 4), trainerID);
    fileHandler.data = toStore;
    await fileHandler.saveData();
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
    service.on('stopServiceResult').listen((data) {
      if (!mounted) return;
      if (data != null) {
        final rawMap = (data['namedVectors'] as Map<String, dynamic>);
        toStore = rawMap.map((key, value) {
          return MapEntry(key, (value as List<dynamic>).map<double>((e) => e.toDouble()).toList());
        });
        Logger().i('Received vectors: $toStore');
      }
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
                foregroundColor: Colors.white,
                disabledBackgroundColor: _buttonColor,
                fixedSize: const Size(250, 250),
              ),
              child: _buttonChild,
            ),
          ),
          Text(
            _timerText,
            style: const TextStyle(
              fontSize: 30.0,
              fontFamily: 'Roboto',
              color: Colors.black,
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
      SaveFileHandler fileManager = SaveFileHandler(fileName, 0);
      await fileManager.download();
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
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

    try {
      SaveFileHandler fileManager = SaveFileHandler(fileName, 0);
      await fileManager.delete();
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
      separatorBuilder: (context, index) => const Divider(
        color: Colors.black,
        thickness: 1,
      ),
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
                    color: Colors.green,
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteFile(currentList[itemCount - index - 1], itemCount - index - 1);
                    },
                    icon: Icon(Icons.delete_rounded),
                    color: Colors.red,
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