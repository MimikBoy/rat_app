import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();

  factory BluetoothManager() {
    return _instance;
  }

  BluetoothManager._internal();

  BluetoothConnection? connectionLeft;
  BluetoothConnection? connectionRight;

  // StreamControllers for processed data
  final StreamController<String> _leftDataController = StreamController.broadcast();
  final StreamController<String> _rightDataController = StreamController.broadcast();

  // Public streams to listen to processed data
  Stream<String> get leftDataStream => _leftDataController.stream;
  Stream<String> get rightDataStream => _rightDataController.stream;

  Future<void> processData(String data, StreamController<String> controller) async {
    String processedData = data;  //This needs to be changed to the actual processing logic
    controller.add(processedData); // Add to the respective stream
  }

  Future<void> receiveData() async {
    if (connectionLeft != null && connectionLeft!.isConnected) {
      connectionLeft!.input?.listen((Uint8List data) {
        String receivedDataLeft = utf8.decode(data).trim();
        if(receivedDataLeft.isNotEmpty){
        print('Received data Left: $receivedDataLeft');
        // Process received data here
        processData(receivedDataLeft, _leftDataController);
        }
      });
    }

    if (connectionRight != null && connectionRight!.isConnected) {
      connectionRight!.input?.listen((Uint8List data) {
        String receivedDataRight = utf8.decode(data).trim();
        if (receivedDataRight.isNotEmpty){
        print('Received data Right: $receivedDataRight');
        // Process received data here
        processData(receivedDataRight, _rightDataController);
        } 
      });
    }
  }

  Future<void> sendData(String data) async {
    if (connectionLeft != null && connectionLeft!.isConnected) {
      connectionLeft!.output.add(utf8.encode(data));
      connectionLeft!.output.allSent;
      print('Sent ' + data + ' to LEFT');
    }

    if (connectionRight != null && connectionRight!.isConnected) {
      connectionRight!.output.add(utf8.encode(data));
      connectionRight!.output.allSent;
      print('Sent ' + data + ' to RIGHT');
    }
  }
}

class BluetoothSetupPage extends StatefulWidget {
  const BluetoothSetupPage({Key? key}) : super(key: key);

  @override
  _BluetoothSetupPageState createState() => _BluetoothSetupPageState();
}

class _BluetoothSetupPageState extends State<BluetoothSetupPage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  String _statusMessage = "Connecting to devices...";

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    bool permissionsGranted = await _requestBluetoothPermissions();
    if (permissionsGranted) {
      _connectToDevices();
    } else {
      print("Bluetooth permissions not granted.");
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return true;
    }
    return false;
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  Future<void> _connectToDevices() async {
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();

    BluetoothDevice? deviceLeft = devices.firstWhere(
      (d) => d.name == "LEFT_ESP32",
      orElse: () => BluetoothDevice(address: "", name: "Unknown"),
    );

    BluetoothDevice? deviceRight = devices.firstWhere(
      (d) => d.name == "RIGHT_ESP32",
      orElse: () => BluetoothDevice(address: "", name: "Unknown"),
    );

    if (deviceLeft.address.isEmpty) {
      print("Left not found! Make sure it's paired.");
      return;
    } else if (deviceRight.address.isEmpty) {
      print("Right not found! Make sure it's paired.");
      return;
    }

    try {
      bluetoothManager.connectionLeft = await BluetoothConnection.toAddress(deviceLeft.address);
      print('Connected to ${deviceLeft.name}');
      _updateStatus("Connected to ${deviceLeft.name}");

      await Future.delayed(Duration(seconds: 5));

      try {
        bluetoothManager.connectionRight = await BluetoothConnection.toAddress(deviceRight.address);
        print('Connected to both devices');
        _updateStatus("Connected to both devices");

        await bluetoothManager.sendData('stop'); // Send stop to RIGHT
      } catch (error) {
        print('Error connecting to RIGHT: $error');
        _updateStatus("Error connecting to RIGHT: $error");
      }
    } catch (error) {
      print('Error connecting to LEFT: $error');
      _updateStatus("Error connecting to LEFT: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Setup'),
      ),
      body: Center(
        child: Text(_statusMessage),
      ),
    );
  }
}
