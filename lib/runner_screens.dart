import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class RunnerPageManager extends StatefulWidget{
  const RunnerPageManager({super.key});

  @override
  State<RunnerPageManager> createState() => _RunnerPageManagerState();
}

class _RunnerPageManagerState extends State<RunnerPageManager> {
  int screenIndex = 0;


  @override
  Widget build(BuildContext context){
    Widget page;
    switch (screenIndex) {
      case 0:
        page = const RunnerHomePage();
        break;
      case 1:
        page = Placeholder();
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
        title: const Text('Home'),
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
              children: const [
                Icon(Icons.battery_unknown_rounded, size: 30),
                Icon(Icons.battery_unknown_rounded, size: 30)
              ],
            ),
            onPressed: () {
              Logger().i('Battery button pressed');
            },
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

  void _changeColor()  async{
    if (_buttonColor == Colors.green) {
      Logger().i('Button color changed to red');
      await _countdown();
      _setToStop();
      _startTimer(0);
    } else {
      Logger().i('Button color changed to green');
      if (!mounted) return;
      setState((){
        _buttonChild = const Icon(Icons.play_arrow_rounded, size: 100, color: Colors.white);
        _buttonColor = Colors.green;
      });
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
                _changeColor();
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