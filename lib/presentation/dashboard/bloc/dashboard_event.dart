part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class InitializeDashboard extends DashboardEvent {}

class ToggleTracking extends DashboardEvent {}

class DashboardLocationUpdated extends DashboardEvent {
  final Position position;
  DashboardLocationUpdated(this.position);
}

class DashboardAddressUpdated extends DashboardEvent {
  final String address;
  final Position position;
  DashboardAddressUpdated(this.address, this.position);
}

class DashboardTimerTicked extends DashboardEvent {
  final Duration duration;
  DashboardTimerTicked(this.duration);
}
