import 'package:flutter/material.dart';

class TrackingStatusCard extends StatefulWidget {
  final bool isTracking;
  final String currentAddress;
  final VoidCallback onToggle;

  const TrackingStatusCard({
    super.key,
    required this.isTracking,
    required this.currentAddress,
    required this.onToggle,
  });

  @override
  State<TrackingStatusCard> createState() => _TrackingStatusCardState();
}

class _TrackingStatusCardState extends State<TrackingStatusCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: widget.isTracking ? Colors.blue.withOpacity(0.5) : Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: widget.isTracking 
              ? [Colors.blue.shade800, Colors.indigo.shade900]
              : [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isTracking)
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.5).animate(
                          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                        ),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.isTracking ? Colors.white : Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isTracking ? Icons.navigation_rounded : Icons.location_off_rounded,
                        color: widget.isTracking ? Colors.blue.shade800 : Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isTracking ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isTracking ? 'LIVE TRACKING' : 'OFFLINE',
                            style: TextStyle(
                              color: widget.isTracking ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isTracking ? widget.currentAddress : 'Tracking Stopped',
                        style: TextStyle(
                          color: widget.isTracking ? Colors.white : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onToggle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isTracking ? Colors.red.shade600 : Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded),
                        const SizedBox(width: 8),
                        Text(
                          widget.isTracking ? 'STOP TRACKING' : 'START TRACKING',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
