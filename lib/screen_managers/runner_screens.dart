import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rat_app/runner_screens/runner_home.dart';
import 'package:rat_app/runner_screens/runner_download.dart';
import 'package:rat_app/runner_screens/runner_settings.dart';
import 'dart:async';
import '../utils/bluetooth.dart';

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

    if (await btManager.checkConnection()){
      btManager.sendData('battery');
    } else {
      btManager.dispose();
      int connectionStatus = await btManager.connectToDevices();

      btManager.receiveData();

      final service = FlutterBackgroundService();

      setState(() {
        // Update icon colors based on the connection status
        leftBatteryColor = (connectionStatus & 1) != 0 ? greenButtons : Colors.white;
        leftBatteryIcon = (connectionStatus & 1) != 0 ? Icons.battery_full_rounded : Icons.battery_unknown_rounded;
        rightBatteryColor = (connectionStatus & 2) != 0 ? greenButtons : Colors.white;
        rightBatteryIcon = (connectionStatus & 2) != 0 ? Icons.battery_full_rounded : Icons.battery_unknown_rounded; // Right connected
      });

      BluetoothManager().sendData('battery');
    }

    
    
  }

  IconData getBatteryIcon(int batteryPercentage) {
    if (batteryPercentage > 87) {
      return Icons.battery_full_rounded;
    } else if (batteryPercentage >= 75) {
      return Icons.battery_6_bar_rounded;
    } else if (batteryPercentage > 62) {
      return Icons.battery_5_bar_rounded;
    } else if (batteryPercentage >= 50) {
      return Icons.battery_4_bar_rounded;
    } else if (batteryPercentage > 37) {
      return Icons.battery_3_bar_rounded;
    } else if (batteryPercentage >= 25) {
      return Icons.battery_2_bar_rounded;
    } else if (batteryPercentage > 12) {
      return Icons.battery_1_bar_rounded;
    } else if (batteryPercentage > 0) {
      return Icons.battery_0_bar_rounded;
    } else {
      return Icons.battery_alert_rounded;
    }
  }

  void handleBatteryPercentage(int batteryPercentage, bool isLeft){
    if (isLeft){
      setState(() {
        leftBatteryColor = batteryPercentage > 20 ? greenButtons : redButtons;
        leftBatteryIcon = getBatteryIcon(batteryPercentage);
      });
    } else {
      setState(() {
        rightBatteryColor = batteryPercentage > 20 ? greenButtons : redButtons;
        rightBatteryIcon = getBatteryIcon(batteryPercentage);
      });
    }
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

  void changeToProfile(){
    setState(() {
      leadingIcon = IconButton(
        icon: const Icon(Icons.circle_outlined, size: 30),
        onPressed: () {
          Logger().i('Profile button pressed');
        },
      );
    });
  }

  @override
  Widget build(BuildContext context){
    Widget page;
    switch (screenIndex) {
      case 0:
        page = RunnerHomePage(onBatteryPercentageUpdate: handleBatteryPercentage);
        changeToProfile();
        break;
      case 1:
        page = const RunnerDownloadPage();
        changeToProfile();
        break;
      case 2:
        page = RunnerSettingsPage(changeSettingScreen: _changeSettingsScreen,);
        changeToProfile();
        break;
      case 3:
        page = const EditParametersPage();
        break;
      default:
        page = RunnerHomePage(onBatteryPercentageUpdate: handleBatteryPercentage);
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
