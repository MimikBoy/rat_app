import 'package:flutter/material.dart';
import 'start_screens/welcome_screen.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'screen_managers/runner_screens.dart';
import 'utils/bluetooth.dart';
import 'screen_managers/trainer_screens.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize connection status
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('hasBeenCalled', false);
  // Initialize Bluetooth connection
  BluetoothManager btManager = BluetoothManager();
  await btManager.initializeBluetooth(); 
  
  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,);

  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAT',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 33, 33, 33),
        splashColor: const Color.fromARGB(44, 58, 69, 108),     // Custom splash (ripple) color.
        highlightColor: const Color.fromARGB(44, 58, 69, 108),
         appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 33, 33, 33), // Slightly lighter grey
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white, // Set the title text color to white
            fontSize: 19, // Set the font size for the title
            fontWeight: FontWeight.bold, // Set the font weight for the title
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // Slightly lighter grey
          selectedItemColor: Color.fromARGB(255, 100, 181, 246),
          unselectedItemColor: Color.fromARGB(255, 158, 158, 158),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // set your default icon color here
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 9, 52, 211)),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Color.fromARGB(255, 238, 238, 238),
          displayColor: Color.fromARGB(255, 238, 238, 238),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Color.fromARGB(255, 33, 33, 33),
          titleTextStyle: TextStyle(color: Colors.white),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        dividerTheme: DividerThemeData(
          color: Color.fromARGB(100, 189, 189, 189), // Set the color of the divider
          thickness: 1, // Set the thickness of the divider
        ),
      ),
      home: MyHomePage(title: 'RAT App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int startScreen = -1;

  @override
  // Initializes the state of the widget. Called when the widget is first created.
  void initState() {
    super.initState();
    _initPrefs();
  }

  // Initializes initial preferences, such as the starting screen
  void _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      startScreen = prefs.getInt('mode') ?? -1;
      Logger().i('Stored index: $startScreen');
    });
  }

  // Changes the screen based on the index.
  void _changeScreen(int index) {
    setState(() {
      startScreen = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (startScreen) {
      case -1:
      // Show the WelcomeScreen.
      return WelcomeScreen(onContinue: _changeScreen,);
      case 0:
      // Show the RunnerHomePage.
      return RunnerPageManager();
      case 1:
      // Show the TrainerHomePage.
      // Fokko: Put your Trainer main page here.
      return TrainerPageManager();
      default:
      Logger().e('Invalid index: $startScreen');
      return WelcomeScreen(onContinue: _changeScreen,);
    }
  }
}
