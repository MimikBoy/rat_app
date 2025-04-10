import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'Trainer Screens/settings.dart';
import 'Trainer Screens/Upload.dart';
import 'Trainer Screens/home.dart';

const Color textColor = Color.fromARGB(255, 224, 224, 224);
const Color seperatorColor = Color.fromARGB(100, 189, 189, 189);
const Color redButtons = Color.fromARGB(255, 211, 47, 47);
const Color greenButtons = Color.fromARGB(255, 76, 175, 80);
const Color greyButtons = Color.fromARGB(255, 158, 158, 158);

class TrainerPageManager extends StatefulWidget{
  const TrainerPageManager({super.key});

  @override
  State<TrainerPageManager> createState() => _TrainerPageManagerState();
}

class _TrainerPageManagerState extends State<TrainerPageManager> {
  int screenIndex = 0;
  IconData leftBatteryIcon = Icons.battery_unknown_rounded;
  IconData rightBatteryIcon = Icons.battery_unknown_rounded;
  Color leftBatteryColor = Colors.white;
  Color rightBatteryColor = Colors.white;
  String appBarTitle = 'Home';
  String runnerID = '0';


  IconButton leadingIcon = IconButton(
          icon: const Icon(Icons.circle_outlined, size: 30),
          onPressed: () {
            Logger().i('Profile button pressed');
          },
        );


  @override
  Widget build(BuildContext context){
    Widget page;
    switch (screenIndex) {
      case 0:
        page = TrainerHomePage(
            onRunnerSelected: (runnerID) {
              setState(() {
                screenIndex = 3;
                appBarTitle = runnerID;
                this.runnerID = runnerID;
              });
            },
          );
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
        page =  UploadScreen();
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
        page = TrainerSettingsPage();
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
        page = DataVisualizationPage(runnerID: runnerID,);
        break;
      default:
        page = Placeholder();
    }

    return Scaffold(
      appBar: AppBar(        
        title: Text(appBarTitle),
        leading: leadingIcon,
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
            icon: Icon(Icons.upload, size: 30),
            label: 'Uploads',
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
            appBarTitle = index == 0 ? 'Home' : index == 1 ? 'Uploads' : 'Settings';
          });
          Logger().i('Bottom navigation bar item $index pressed');
        },
      ),
    );
  }
}
