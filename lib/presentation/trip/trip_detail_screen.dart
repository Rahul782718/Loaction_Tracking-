import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import 'widgets/route_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class TripDetailScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final routePoints = trip.route.map((p) => LatLng(p.latitude, p.longitude)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                RouteMap(
                  points: routePoints,
                  isTracking: false,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _TripQuickStats(trip: trip),
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
              child: _SavedTimelineList(points: trip.route),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripQuickStats extends StatelessWidget {
  final TripModel trip;
  const _TripQuickStats({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Distance', value: '${(trip.distance / 1000).toStringAsFixed(2)} km'),
          _Stat(label: 'Points', value: '${trip.route.length}'),
          _Stat(label: 'Date', value: DateFormat('MMM d').format(trip.startTime)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _SavedTimelineList extends StatelessWidget {
  final List<dynamic> points;
  const _SavedTimelineList({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No points recorded for this trip.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Saved Route Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            itemCount: points.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final point = points[index];
              final time = DateFormat('hh:mm:ss a').format(point.timestamp.toLocal());
              
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history, color: Colors.blue.shade700, size: 20),
                ),
                title: Text(
                  point.address ?? 'Saved Location',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  time,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
