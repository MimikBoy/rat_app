import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
      initialNotificationTitle: 'Running in Background',
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
void onStart(ServiceInstance service) {
  // For Android: set up a periodic timer or stream
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  List<String> grfLeft, grfRight, grfLeftTime, grfRightTime, groundTimeLeft, groundTimeRight,
      angleLeft, angleRight, angleTimeLeft, angleTimeRight, batteryLeft, batteryRight;

  btManager.leftDataStream.listen((data) {
      //JOAS PUT STUFF IN HERE
  });

  btManager.rightDataStream.listen((data) {
      //JOAS PUT STUFF IN HERE
  });

  btManager.receiveData();

  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) {
        timer.cancel();
        service.stopSelf();
      }
    }
  });
}