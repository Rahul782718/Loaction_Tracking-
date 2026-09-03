import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import '../trip/widgets/route_map.dart';
import 'widgets/tracking_status_card.dart';
import 'widgets/trip_stats_card.dart';
import 'bloc/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(InitializeDashboard()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  GoogleMapController? _mapController;

  void _onBlocUpdate(BuildContext context, DashboardState state) {
    // This handles moving the camera when a NEW location is received while tracking
    if (state.currentPosition != null && state.isTracking && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  void _onReceiveTaskData(dynamic data) {
    debugPrint('Main Isolate: Received task data: $data');
    if (data is Map<String, dynamic>) {
      try {
        final position = Position(
          latitude: data['latitude'],
          longitude: data['longitude'],
          timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
          altitude: (data['altitude'] ?? 0.0).toDouble(),
          accuracy: (data['accuracy'] ?? 0.0).toDouble(),
          heading: (data['heading'] ?? 0.0).toDouble(),
          speed: (data['speed'] ?? 0.0).toDouble(),
          speedAccuracy: (data['speed_accuracy'] ?? 0.0).toDouble(),
          altitudeAccuracy: (data['altitude_accuracy'] ?? 0.0).toDouble(),
          headingAccuracy: (data['heading_accuracy'] ?? 0.0).toDouble(),
        );
        
        debugPrint('Main Isolate: Parsed Position [${position.latitude}, ${position.longitude}]');
        if (mounted) {
          context.read<DashboardBloc>().add(DashboardLocationUpdated(position));
        }
      } catch (e) {
        debugPrint('Main Isolate: Error parsing background location data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text(
            'Route Tracker',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.pushNamed(context, '/history'),
            ),
          ],
        ),
        body: BlocListener<DashboardBloc, DashboardState>(
          listener: _onBlocUpdate,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    BlocBuilder<DashboardBloc, DashboardState>(
                      // Only rebuild map when route points count change
                      buildWhen: (p, c) => p.routePoints.length != c.routePoints.length || p.isTracking != c.isTracking,
                      builder: (context, state) {
                        return RouteMap(
                          points: state.routePoints,
                          isTracking: state.isTracking,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            // If we already have a position, move to it immediately
                            if (state.currentPosition != null) {
                               _mapController!.moveCamera(
                                 CameraUpdate.newLatLngZoom(
                                   LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
                                   16,
                                 ),
                               );
                            }
                          },
                        );
                      },
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          return TrackingStatusCard(
                            isTracking: state.isTracking,
                            currentAddress: state.currentAddress,
                            onToggle: () => context.read<DashboardBloc>().add(ToggleTracking()),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: BlocBuilder<DashboardBloc, DashboardState>(
                          builder: (context, state) {
                            return TripStatsCard(
                              distance: state.distance,
                              duration: state.duration,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: const _TimelineList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.timelinePoints.length} points',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.timelinePoints.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No location data yet.',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                itemCount: state.timelinePoints.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  final point = state.timelinePoints[index];
                  final time = DateFormat('hh:mm:ss a').format(point.position.timestamp.toLocal());
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.my_location, color: Colors.blue.shade700, size: 20),
                    ),
                    title: Text(
                      point.address,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Lat: ${point.position.latitude.toStringAsFixed(5)}, Lng: ${point.position.longitude.toStringAsFixed(5)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                    trailing: Text(
                      time,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
