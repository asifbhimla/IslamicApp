import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import 'package:quran/quran.dart' as quran;

import '../app_state.dart';
import '../services/daily_ayah_service.dart';
import '../widgets/app_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  DailyAyah? _dailyAyah;
  bool _lastUseApi = false;
  String _lastApiEdition = '';
  String _lastApiSecondaryEdition = '';

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (_dailyAyah == null ||
        _lastUseApi != state.useAlQuranCloudApi ||
        _lastApiEdition != state.apiPrimaryEdition ||
        _lastApiSecondaryEdition != state.apiSecondaryEdition) {
      _lastUseApi = state.useAlQuranCloudApi;
      _lastApiEdition = state.apiPrimaryEdition;
      _lastApiSecondaryEdition = state.apiSecondaryEdition;
      _loadDailyAyah();
    }
  }

  Future<void> _loadDailyAyah() async {
    final state = context.read<AppState>();
    final ayah = await DailyAyahService.getToday(
      useApi: state.useAlQuranCloudApi,
      apiEdition: state.apiPrimaryEdition,
      apiSecondaryEdition: state.apiSecondaryEdition,
    );
    if (mounted) setState(() => _dailyAyah = ayah);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _countdownTo(DateTime time) {
    final remaining = time.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final now = DateTime.now();
    final next = state.nextPrayer(now: now);
    // The tile shows a prayer as "Current" from 30 minutes before it starts;
    // Fajr's window ends at sunrise, after which Dhuhr shows as "Next".
    // The ring timer always counts down to the next prayer.
    final tile = state.homeTilePrayer(now: now);
    final tilePrayer = tile.prayer;
    final tileLabel = tile.isCurrent ? 'Current Prayer' : 'Next Prayer';
    final entries = state.prayerEntriesFor(now);
    final fajrTime = entries.firstWhere((e) => e.name == 'Fajr').time;
    final maghribTime = entries.firstWhere((e) => e.name == 'Maghrib').time;
    final hijri = HijriCalendar.now();
    final locale = state.effectiveLocale;
    final timeFormat = DateFormat.jm(locale);

    // Calculate countdown progress (fraction of time elapsed since previous prayer)
    final obligatoryToday = entries.where((e) => e.isObligatory).toList();
    DateTime previousPrayerTime;
    final idx = obligatoryToday.indexWhere((e) => e.name == next.name);
    if (idx > 0) {
      previousPrayerTime = obligatoryToday[idx - 1].time;
    } else {
      // Next is Fajr (today or tomorrow) — previous was yesterday's Isha
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayEntries = state.prayerEntriesFor(yesterday);
      previousPrayerTime = yesterdayEntries.last.time;
    }
    final totalDuration = next.time.difference(previousPrayerTime).inSeconds;
    final elapsed = now.difference(previousPrayerTime).inSeconds;
    final progress = totalDuration > 0
        ? (elapsed / totalDuration).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'قلب',
              style: TextStyle(
                color: Color(0xFFD4A843),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'Care',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 48, 16, 16),
          children: [
          Row(
            children: [
              const Icon(Icons.place, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.locationLabel,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${hijri.toFormat('dd MMMM yyyy')} AH',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: Colors.white),
          ),
          Text(
            DateFormat.yMMMMEEEEd(locale).format(now),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7B5EA7),
                  Color(0xFF4A7BF7),
                  Color(0xFF22D3EE),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$tileLabel : ${tilePrayer.name}',
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            timeFormat.format(tilePrayer.time),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(Start time)',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Suhur: ${timeFormat.format(fajrTime)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Iftar: ${timeFormat.format(maghribTime)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _CountdownRingPainter(progress: progress),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Time',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.white70, fontSize: 10),
                          ),
                          Text(
                            _countdownTo(next.time),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Left',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (int i = 0; i < entries.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: entries[i].name == next.name
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconFor(entries[i].name),
                          size: 16,
                          color: entries[i].name == next.name
                              ? theme.colorScheme.primary
                              : Colors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entries[i].name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: entries[i].name == next.name
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: entries[i].name == next.name
                                ? theme.colorScheme.primary
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeFormat.format(entries[i].time),
                          style: TextStyle(
                            fontSize: 9,
                            color: entries[i].name == next.name
                                ? theme.colorScheme.primary
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Method: ${state.calculationMethod.label} · '
            'Asr: ${state.madhab.name == 'hanafi' ? 'Hanafi' : 'Shafi'}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_dailyAyah != null) ...[
            Text('Ayah of the Day', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _dailyAyah!.arabic,
                      style: theme.textTheme.titleLarge?.copyWith(height: 2),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _dailyAyah!.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (state.useAlQuranCloudApi &&
                        _dailyAyah!.secondaryTranslation != null) ...[
                      const Divider(height: 20),
                      Text(
                        _dailyAyah!.secondaryTranslation!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else if (!state.useAlQuranCloudApi &&
                        state.secondaryTranslation != null) ...[
                      const Divider(height: 20),
                      Text(
                        state.secondaryTranslation!.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quran.getVerseTranslation(
                          _dailyAyah!.surahNumber,
                          _dailyAyah!.verseNumber,
                          translation: state.secondaryTranslation!.translation,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '— ${_dailyAyah!.surahName} ${_dailyAyah!.surahNumber}:${_dailyAyah!.verseNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  IconData _iconFor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.dark_mode;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
        return Icons.light_mode;
      case 'Asr':
        return Icons.wb_cloudy_outlined;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}

class _CountdownRingPainter extends CustomPainter {
  _CountdownRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Gradient arc — sweeps from top, clockwise
    // Colors go green → yellow → orange → red as time elapses
    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: const [
        Color(0xFF4ADE80),
        Color(0xFFFBBF24),
        Color(0xFFF97316),
        Color(0xFFEF4444),
        Color(0xFF4ADE80),
      ],
      transform: const GradientRotation(-math.pi / 2),
    );

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Bright dot at the tip of the arc
    final tipAngle = -math.pi / 2 + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    canvas.drawCircle(Offset(tipX, tipY), 5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(tipX, tipY), 3, Paint()..color = const Color(0xFF4ADE80));
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) => old.progress != progress;
}
