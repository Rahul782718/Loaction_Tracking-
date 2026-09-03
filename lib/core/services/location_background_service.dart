import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Start listening to location in the background isolate
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings:  AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Logic: Only capture every 10 meters move
      ),
    ).listen((Position position) {
      // Accuracy filter in background too
      if (position.accuracy > 25) return;

      final positionData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
        'altitude': position.altitude,
        'accuracy': position.accuracy,
        'heading': position.heading,
        'speed': position.speed,
        'speed_accuracy': position.speedAccuracy,
      };

      FlutterForegroundTask.sendDataToMain(positionData);
      
      FlutterForegroundTask.updateService(
        notificationTitle: 'Route Tracker Active',
        notificationText: 'Radius Move Captured: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      );
    });
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isUserAction) async {
    await _positionSubscription?.cancel();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

class LocationBackgroundService {
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_tracking_channel',
        channelName: 'Location Tracking Service',
        channelDescription: 'Tracks your route in the background',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Route Tracker Active',
      notificationText: 'Your journey is being recorded...',
      callback: startCallback,
    );
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
