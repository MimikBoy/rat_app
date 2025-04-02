import 'package:flutter/material.dart';
import 'package:rat_app/bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  //bool _isListening = false;
  String leftOutput = "No data";
  String rightOutput = "No data";

   @override
  void initState() {
    super.initState();

    // Listen for processed data from BluetoothManager
    bluetoothManager.leftDataStream.listen((data) {
      setState(() {
        leftOutput = data;
      });
    });

    bluetoothManager.rightDataStream.listen((data) {
      setState(() {
        rightOutput = data;
      });
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BluetoothSetupPage()),
                );
              },
              child: const Text('Scan for Bluetooth Devices'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bluetoothManager.receiveData();
              },
              child: const Text('Start listening to data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await bluetoothManager.sendData('start');
              },
              child: const Text('Send start Command'),
            ),
            ElevatedButton(
              onPressed: () async {
                await bluetoothManager.sendData('stop');
              },
              child: const Text('Send stop Command'),
            ),
            const SizedBox(height: 20),
            Text("Left Processed Data: $leftOutput"),
            Text("Right Processed Data: $rightOutput"),
          ],
        ),
      ),
    );
  }
}