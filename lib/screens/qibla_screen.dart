import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets/app_background.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<CompassEvent>? _sub;
  double? _heading;
  bool _compassUnavailable = false;

  @override
  void initState() {
    super.initState();
    try {
      final stream = FlutterCompass.events;
      if (stream == null) {
        _compassUnavailable = true;
      } else {
        _sub = stream.listen(
          (event) {
            if (mounted) setState(() => _heading = event.heading);
          },
          onError: (_) {
            if (mounted) setState(() => _compassUnavailable = true);
          },
        );
      }
    } catch (_) {
      _compassUnavailable = true;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final qibla = state.qiblaDirection;
    final heading = _heading;

    // Difference between where the device points and the Qibla bearing.
    final diff = heading == null ? null : ((qibla - heading) % 360 + 360) % 360;
    final aligned = diff != null && (diff <= 5 || diff >= 355);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Qibla Finder', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.locationLabel,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Qibla is ${qibla.round()}° from North',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                if (_compassUnavailable)
                  _NoCompassMessage(qibla: qibla)
                else
                  Expanded(child: _buildCompass(theme, qibla, heading, aligned)),
                const SizedBox(height: 24),
                if (!_compassUnavailable)
                  Text(
                    heading == null
                        ? 'Calibrating compass…'
                        : aligned
                            ? 'Facing the Qibla'
                            : 'Turn to align the marker with the top',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: aligned ? const Color(0xFF4ADE80) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Hold the phone flat and away from metal or magnets for an '
                  'accurate reading.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(
      ThemeData theme, double qibla, double? heading, bool aligned) {
    final headingRad = (heading ?? 0) * math.pi / 180;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fixed top indicator marking "straight ahead".
            Align(
              alignment: Alignment.topCenter,
              child: Icon(Icons.arrow_drop_down,
                  size: 40,
                  color: aligned ? const Color(0xFF4ADE80) : Colors.white),
            ),
            // Compass rose + Qibla marker, rotated opposite to the heading so
            // it reflects real-world directions.
            Padding(
              padding: const EdgeInsets.all(28),
              child: Transform.rotate(
                angle: -headingRad,
                child: CustomPaint(
                  painter: _CompassPainter(
                    qiblaBearing: qibla,
                    aligned: aligned,
                    color: theme.colorScheme.primary,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            // Kaaba icon in the middle.
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mosque, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCompassMessage extends StatelessWidget {
  const _NoCompassMessage({required this.qibla});

  final double qibla;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Icon(Icons.explore_off, color: Colors.white70, size: 64),
        const SizedBox(height: 16),
        Text(
          'No compass sensor detected on this device.',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Face ${qibla.round()}° from true north to find the Qibla.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.qiblaBearing,
    required this.aligned,
    required this.color,
  });

  final double qiblaBearing;
  final bool aligned;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, ring);

    final tick = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    for (var deg = 0; deg < 360; deg += 30) {
      final a = deg * math.pi / 180 - math.pi / 2;
      final outer = center + Offset(math.cos(a), math.sin(a)) * radius;
      final inner =
          center + Offset(math.cos(a), math.sin(a)) * (radius - 12);
      canvas.drawLine(inner, outer, tick);
    }

    // Cardinal letters.
    const cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    cardinals.forEach((deg, label) {
      final a = deg * math.pi / 180 - math.pi / 2;
      final pos = center + Offset(math.cos(a), math.sin(a)) * (radius - 30);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? const Color(0xFFEF4444) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    });

    // Qibla needle.
    final a = qiblaBearing * math.pi / 180 - math.pi / 2;
    final tip = center + Offset(math.cos(a), math.sin(a)) * (radius - 14);
    final needle = Paint()
      ..color = aligned ? const Color(0xFF4ADE80) : color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, needle);
    canvas.drawCircle(
        tip, 9, Paint()..color = aligned ? const Color(0xFF4ADE80) : color);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.qiblaBearing != qiblaBearing ||
      old.aligned != aligned ||
      old.color != color;
}
