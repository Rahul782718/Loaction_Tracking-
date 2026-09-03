import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/permission_service.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/location_point_model.dart';
import '../../../repositories/trip_repository.dart';

import '../../../core/services/location_background_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final PermissionService _permissionService = PermissionService();
  final TripRepository _tripRepository = TripRepository();
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;
  DateTime? _startTime;

  DashboardBloc() : super(DashboardState()) {
    on<InitializeDashboard>(_onInitialize);
    on<ToggleTracking>(_onToggleTracking);
    on<DashboardLocationUpdated>(_onLocationUpdated);
    on<DashboardAddressUpdated>(_onAddressUpdated);
    on<DashboardTimerTicked>(_onTimerTicked);
  }

  Future<void> _onInitialize(InitializeDashboard event, Emitter<DashboardState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isServiceRunning = await FlutterForegroundTask.isRunningService;

    if (isServiceRunning) {
      final startTimeStr = prefs.getString(AppConstants.keyStartTime);
      if (startTimeStr != null) {
        _startTime = DateTime.parse(startTimeStr);
        final pos = await Geolocator.getCurrentPosition();
        emit(state.copyWith(
          isTracking: true,
          currentPosition: pos,
          duration: DateTime.now().difference(_startTime!),
        ));
        _startTimer();
        _startForegroundLocationStream();
      }
    }
  }

  Future<void> _onToggleTracking(ToggleTracking event, Emitter<DashboardState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    if (!state.isTracking) {
      final hasPermission = await _permissionService.requestLocationPermission();
      if (!hasPermission) return;

      _startTime = DateTime.now();
      await prefs.setString(AppConstants.keyStartTime, _startTime!.toIso8601String());

      // Start Background Service
      await LocationBackgroundService.startService();

      emit(state.copyWith(
        isTracking: true,
        distance: 0.0,
        timelinePoints: [],
        currentAddress: 'Waiting for GPS...',
        duration: Duration.zero,
      ));

      _startTimer();
      _startForegroundLocationStream();
    } else {
      _stopForegroundLocationStream();
      _stopTimer();
      await prefs.remove(AppConstants.keyStartTime);

      // Stop Background Service
      await LocationBackgroundService.stopService();

      if (state.timelinePoints.isNotEmpty) {
        await _saveTrip();
      }

      emit(state.copyWith(isTracking: false, duration: Duration.zero));
    }
  }

  void _startForegroundLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings:  AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Instruct OS to only update every 10 meters
      ),
    ).listen((position) {
      add(DashboardLocationUpdated(position));
    });
  }

  void _stopForegroundLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        add(DashboardTimerTicked(DateTime.now().difference(_startTime!)));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimerTicked(DashboardTimerTicked event, Emitter<DashboardState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onLocationUpdated(DashboardLocationUpdated event, Emitter<DashboardState> emit) async {
    if (!state.isTracking) return;

    // --- ACCURACY FILTER ---
    // Ignore points with accuracy worse than 25 meters to prevent jitter
    if (event.position.accuracy > 25) {
      debugPrint('Skipping inaccurate point: ${event.position.accuracy}m');
      return;
    }

    // --- MOVEMENT FILTER (RADIUS) ---
    // Only capture if we moved 10+ meters from the LAST SAVED POINT
    if (state.timelinePoints.isNotEmpty) {
      final lastPoint = state.timelinePoints.first.position;
      final movedDistance = Geolocator.distanceBetween(
        lastPoint.latitude, lastPoint.longitude,
        event.position.latitude, event.position.longitude
      );

      if (movedDistance < 10) {
        debugPrint('Skipping stationary jitter: ${movedDistance.toStringAsFixed(2)}m moved');
        // Still update current position for the map to look smooth, but don't record the point
        emit(state.copyWith(currentPosition: event.position));
        return; 
      }
    }

    double newDistance = state.distance;
    if (state.currentPosition != null) {
      final stepDistance = Geolocator.distanceBetween(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
        event.position.latitude,
        event.position.longitude,
      );
      newDistance += stepDistance;
    }

    final newPoint = TimelinePoint(position: event.position, address: 'Locating...');
    final List<TimelinePoint> newList = List.from(state.timelinePoints)..insert(0, newPoint);

    emit(state.copyWith(
      currentPosition: event.position,
      distance: newDistance,
      timelinePoints: newList,
    ));

    debugPrint('Point Captured! Radius Move > 10m. Total distance: ${newDistance.toStringAsFixed(2)}m');

    _getAddressFromLatLng(event.position);
  }

  Future<void> _onAddressUpdated(DashboardAddressUpdated event, Emitter<DashboardState> emit) async {
    final newList = state.timelinePoints.map((point) {
      if (point.position.latitude == event.position.latitude &&
          point.position.longitude == event.position.longitude &&
          point.position.timestamp == event.position.timestamp) {
        return TimelinePoint(position: point.position, address: event.address);
      }
      return point;
    }).toList();

    emit(state.copyWith(
      currentAddress: event.address,
      timelinePoints: newList,
    ));
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.subLocality}, ${place.locality}";
        add(DashboardAddressUpdated(address, position));
      }
    } catch (e) {
      add(DashboardAddressUpdated("Unknown Location", position));
    }
  }

  Future<void> _saveTrip() async {
    debugPrint('Saving trip with ${state.timelinePoints.length} points...');
    final trip = TripModel(
      id: const Uuid().v4(),
      startTime: _startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      distance: state.distance,
      route: state.timelinePoints.map((p) => LocationPointModel(
        latitude: p.position.latitude,
        longitude: p.position.longitude,
        timestamp: p.position.timestamp,
        altitude: p.position.altitude,
        speed: p.position.speed,
        address: p.address,
      )).toList(),
    );

    await _tripRepository.saveTrip(trip);
    debugPrint('Trip saved successfully: ${trip.id}');
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
