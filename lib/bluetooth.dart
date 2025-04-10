import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

final Logger logger = Logger();

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
          logger.i('Received data Left: $receivedDataLeft');
          // Process received data here
          processData(receivedDataLeft, _leftDataController);
        }
      });
    }

    if (connectionRight != null && connectionRight!.isConnected) {
      connectionRight!.input?.listen((Uint8List data) {
        String receivedDataRight = utf8.decode(data).trim();
        if (receivedDataRight.isNotEmpty){
          logger.i('Received data Right: $receivedDataRight');
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
      logger.i('Sent $data to LEFT');
    }

    if (connectionRight != null && connectionRight!.isConnected) {
      connectionRight!.output.add(utf8.encode(data));
      connectionRight!.output.allSent;
      logger.i('Sent $data to RIGHT');
    }
  }

  Future<void> initializeBluetooth() async {
    
    bool permissionsGranted = await requestBluetoothPermissions();
    if (permissionsGranted) {
      logger.i("Bluetooth permissions granted.");
    } else {
      logger.e("Bluetooth permissions not granted.");
    }
  }

  Future<bool> requestBluetoothPermissions() async {
    PermissionStatus scanPermission = await Permission.bluetoothScan.request();
    PermissionStatus connectPermission = await Permission.bluetoothConnect.request();

    if (scanPermission.isGranted && connectPermission.isGranted) {
      return true;
    } else {
      logger.e("Required Bluetooth permissions not granted.");
      return false;
    }
  }

  Future<int> connectToDevices() async {
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    int connectionStatus = 0;

    BluetoothDevice? deviceLeft = devices.firstWhere(
      (d) => d.name == "LEFT_PICO",
      orElse: () => BluetoothDevice(address: "", name: "Unknown"),
    );

    BluetoothDevice? deviceRight = devices.firstWhere(
      (d) => d.name == "RIGHT_PICO",
      orElse: () => BluetoothDevice(address: "", name: "Unknown"),
    );

    if (deviceLeft.address.isEmpty) {
      logger.e("Left not found! Make sure it's paired.");
      return 0;
    } else if (deviceRight.address.isEmpty) {
      logger.e("Right not found! Make sure it's paired.");
      return 0;
    }

    try {
      connectionLeft = await BluetoothConnection.toAddress(deviceLeft.address);
      logger.i('Connected to ${deviceLeft.name}');
      await Future.delayed(Duration(seconds: 1));
      connectionStatus += 1;
    } catch (error) {
      logger.e('Error connecting to LEFT: $error');
    }

    try {
      connectionRight = await BluetoothConnection.toAddress(deviceRight.address);
      logger.i('Connected to right');
      connectionStatus += 2;
    } catch (error) {
      logger.e('Error connecting to RIGHT: $error');
    }
    
    return connectionStatus;
  }

  Future<bool> checkConnection() async {
    if (connectionLeft != null && connectionLeft!.isConnected) {
      logger.i('Connection to LEFT is active');
    } else {
      logger.e('Connection to LEFT is not active');
      return false;
    }

    if (connectionRight != null && connectionRight!.isConnected) {
      logger.i('Connection to RIGHT is active');
    } else {
      logger.e('Connection to RIGHT is not active');
      return false;
    }
    return true;
  }

  void dispose() {
    connectionLeft?.dispose();
    connectionRight?.dispose();
    _leftDataController.close();
    _rightDataController.close();
  }
}