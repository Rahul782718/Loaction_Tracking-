part of 'dashboard_bloc.dart';

class TimelinePoint {
  final Position position;
  final String address;
  TimelinePoint({required this.position, required this.address});
}

class DashboardState {
  final bool isTracking;
  final Position? currentPosition;
  final String currentAddress;
  final double distance;
  final List<TimelinePoint> timelinePoints;
  final Duration duration;

  DashboardState({
    this.isTracking = false,
    this.currentPosition,
    this.currentAddress = 'Unknown Location',
    this.distance = 0.0,
    this.timelinePoints = const [],
    this.duration = Duration.zero,
  });

  DashboardState copyWith({
    bool? isTracking,
    Position? currentPosition,
    String? currentAddress,
    double? distance,
    List<TimelinePoint>? timelinePoints,
    Duration? duration,
  }) {
    return DashboardState(
      isTracking: isTracking ?? this.isTracking,
      currentPosition: currentPosition ?? this.currentPosition,
      currentAddress: currentAddress ?? this.currentAddress,
      distance: distance ?? this.distance,
      timelinePoints: timelinePoints ?? this.timelinePoints,
      duration: duration ?? this.duration,
    );
  }

  List<LatLng> get routePoints =>
      timelinePoints.map((p) => LatLng(p.position.latitude, p.position.longitude)).toList();
}
