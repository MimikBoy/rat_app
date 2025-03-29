import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Checking if there is something stored in shared preferences.
  // WidgetsFlutterBinding.ensureInitialized();
  // final prefs = await SharedPreferences.getInstance();
  // int storedWeight = prefs.getInt('weight') ?? -1;
  // Logger().i('Stored weight: $storedWeight');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 241, 121, 15)),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
      return Placeholder();
      case 1:
      // Show the TrainerHomePage.
      default:
      Logger().e('Invalid index: $startScreen');
      return WelcomeScreen(onContinue: _changeScreen,);
    }
  }
}
