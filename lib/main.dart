import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'package:logger/logger.dart';

void main() {
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
  int _counter = 0;
  var selectedIndex = -2;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case -2:
      // Show the WelcomeScreen.
      return WelcomeScreen(onContinue: _changeScreen,);
      case -1:
      // Show the WhatAreYou screen.
      return WhatAreYou(onContinue: _changeScreen,);
      case 0:
      // Show the HomePage.
      return Scaffold(
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          const Text('You have pushed the button this many times:'),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ],
        ),
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        ),
      );
      default:
      Logger().e('Invalid index: $selectedIndex');
      return WelcomeScreen(onContinue: _changeScreen,);
    }
  }
}
