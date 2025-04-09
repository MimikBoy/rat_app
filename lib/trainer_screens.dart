import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'file_management.dart';

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
        page = Placeholder();
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
        page = const Placeholder();
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
        page = const Placeholder();
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

class TrainerSettingsPage extends StatefulWidget {
  final Function(int)? changeSettingScreen;
  const TrainerSettingsPage({super.key, this.changeSettingScreen});

  @override
  State<TrainerSettingsPage> createState() => _TrainerSettingsPageState();
}


class _TrainerSettingsPageState extends State<TrainerSettingsPage> {
  int itemCount = 0;
  int trainerID = 0;
  List<String> currentList = [
    'Trainer ID: ',
    'About',
  ];
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
  void initState(){
    super.initState();
    _loadSharedPreferences();

    setState(() {
      itemCount = currentList.length + 1;
      currentList[0] = 'Trainer ID: $trainerID';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(
        color: seperatorColor,
        thickness: 1,
      ),
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
                  widget.changeSettingScreen!(4); // Navigate to Edit Parameters page
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