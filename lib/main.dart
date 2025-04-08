import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'runner_screens.dart';
import 'bluetooth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('hasBeenCalled', false);
  BluetoothManager btManager = BluetoothManager();
  await btManager.initializeBluetooth(); 
  // Initialize Bluetooth connection
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 33, 33, 33),
        splashColor: const Color.fromARGB(44, 58, 69, 108),     // Custom splash (ripple) color.
        highlightColor: const Color.fromARGB(44, 58, 69, 108),
         appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 33, 33, 33), // Slightly lighter grey
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // Slightly lighter grey
          selectedItemColor: Color.fromARGB(255, 100, 181, 246),
          unselectedItemColor: Color.fromARGB(255, 158, 158, 158),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 9, 52, 211)),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Color.fromARGB(255, 238, 238, 238),
          displayColor: Color.fromARGB(255, 238, 238, 238),
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
      default:
      Logger().e('Invalid index: $startScreen');
      return WelcomeScreen(onContinue: _changeScreen,);
    }
  }
}
