import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logger/web.dart';
//import 'package:flutter_background_service_android/flutter_background_service_android.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:logger/logger.dart';
import 'bluetooth.dart';
BluetoothManager btManager = BluetoothManager();



Future<void> initializeService(BluetoothManager blueManager) async {
  final service = FlutterBackgroundService();
  btManager = blueManager;
  // Set configuration (for Android)
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // The callback to handle background tasks
      isForegroundMode: true, // must be true to keep service running
      autoStart: false,
      // Notification shows in the status bar
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Foreground Service',
      initialNotificationContent: 'Tap to return to the app',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart, // handle tasks in foreground (iOS)
      onBackground: onIosBackground,
    ),
  );
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // For Android: set up a periodic timer or stream
  if (await Permission.notification.isGranted) {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }
  }

  Logger().i('Background service started');

  List<String> grfLeft = ['1', '2', '3'],
      grfRight = ['4', '5', '6'],
      grfLeftTime = ['7', '8', '9'],
      grfRightTime = ['10', '11', '12'],
      groundTimeLeft = ['13', '14', '15'],
      groundTimeRight = ['16', '17', '18'],
      angleLeft = ['19', '20', '21'],
      angleRight = ['22', '23', '24'],
      angleTimeLeft = ['25', '26', '27'],
      angleTimeRight = ['28', '29', '30'],
      batteryLeft = ['31', '32', '33'],
      batteryRight = ['34', '35', '36'];

  service.on('stopService').listen((event) async {

    Map<String, List<double>> namedVectors = {
      "grfLeft": grfLeft.map((e) => double.parse(e)).toList(),
      "grfRight": grfRight.map((e) => double.parse(e)).toList(),
      "grfLeftTime": grfLeftTime.map((e) => double.parse(e)).toList(),
      "grfRightTime": grfRightTime.map((e) => double.parse(e)).toList(),
      "groundTimeLeft": groundTimeLeft.map((e) => double.parse(e)).toList(),
      "groundTimeRight": groundTimeRight.map((e) => double.parse(e)).toList(),
      "angleLeft": angleLeft.map((e) => double.parse(e)).toList(),
      "angleRight": angleRight.map((e) => double.parse(e)).toList(),
      "angleTimeLeft": angleTimeLeft.map((e) => double.parse(e)).toList(),
      "angleTimeRight": angleTimeRight.map((e) => double.parse(e)).toList(),
      "batteryLeft": batteryLeft.map((e) => double.parse(e)).toList(),
      "batteryRight": batteryRight.map((e) => double.parse(e)).toList()
    };

  // First, send the vectors back to the foreground.
    service.invoke("stopServiceResult", {"namedVectors": namedVectors});

    // Give time for the data to be sent.
    await Future.delayed(const Duration(milliseconds: 100));
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await service.stopSelf();
        Logger().i('Foreground Android service has been stopped via command.');
      } else {
        Logger().w('Service is not running in foreground mode.');
      }
    } else {
      Logger().w('stopService command is not implemented for non-Android services.');
    }
  });

  btManager.leftDataStream.listen((data) {
      //JOAS PUT STUFF IN HERE
  });

  btManager.rightDataStream.listen((data) {
      //JOAS PUT STUFF IN HERE
  });

  btManager.receiveData();

  Timer.periodic(const Duration(seconds: 2), (timer) async {
    Logger().i('Current time: ${DateTime.now()}');
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) {
        timer.cancel();
        service.stopSelf();
      }
    }
  });

}