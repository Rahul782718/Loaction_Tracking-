import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMap extends StatefulWidget {
  final List<LatLng> points;
  final bool isTracking;
  final Function(GoogleMapController)? onMapCreated;

  const RouteMap({
    super.key,
    required this.points,
    this.isTracking = false,
    this.onMapCreated,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-center map if tracking and points changed
    if (widget.isTracking &&
        widget.points.isNotEmpty &&
        widget.points != oldWidget.points) {
      _moveToCurrentLocation();
    }
  }

  void _moveToCurrentLocation() {
    if (widget.points.isEmpty || _controller == null) return;
    
    // In our timeline list, newest is at index 0
    final currentPos = widget.points.first;

    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPos, zoom: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the center: newest point first, then fallback to last recorded, then (0,0)
    LatLng initialPos = const LatLng(0, 0);
    if (widget.points.isNotEmpty) {
       initialPos = widget.isTracking ? widget.points.first : widget.points.last;
    }

    final Set<Marker> markers = {};
    if (widget.points.isNotEmpty) {
      // For tracking: points[0] is newest, points[last] is Start
      // For history: points[0] is Start, points[last] is newest
      final startPos = widget.isTracking ? widget.points.last : widget.points.first;
      final currentPos = widget.isTracking ? widget.points.first : widget.points.last;

      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: startPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Start Point'),
        ),
      );

      if (widget.points.length > 1) {
        markers.add(
          Marker(
            markerId: const MarkerId('current'),
            position: currentPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: widget.isTracking ? 'Your Location' : 'End Point'),
          ),
        );
      }
    }

    final Set<Polyline> polylines = {
      if (widget.points.length >= 2)
        Polyline(
          polylineId: const PolylineId('route_path'),
          points: widget.points,
          color: const Color(0xFF6C63FF), // Modern Purple
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPos,
        zoom: 15,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: widget.isTracking,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapType: MapType.normal, // FORCED LIGHT MODE
      onMapCreated: (controller) {
        _controller = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
    );
  }
}
