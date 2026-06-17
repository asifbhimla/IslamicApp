import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _loadDailyAyah();
  }

  Future<void> _loadDailyAyah() async {
    final ayah = await DailyAyahService.getToday();
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
    final entries = state.prayerEntriesFor(now);
    final hijri = HijriCalendar.now();
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('QalbCare', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 48, 16, 16),
          children: [
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hijri.toFormat('dd MMMM yyyy')} AH',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(now),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  'Next prayer: ${next.name}',
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  timeFormat.format(next.time),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.hourglass_bottom,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'in ${_countdownTo(next.time)}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.locationLabel,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            const SizedBox(height: 16),
          ],
          Text("Today's prayer times", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final entry in entries)
                  ListTile(
                    leading: Icon(
                      _iconFor(entry.name),
                      color: entry.name == next.name
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    title: Text(
                      entry.name,
                      style: entry.name == next.name
                          ? TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)
                          : null,
                    ),
                    trailing: Text(
                      timeFormat.format(entry.time),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: entry.name == next.name
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: entry.name == next.name
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Method: ${state.calculationMethod.label} · '
            'Asr: ${state.madhab.name == 'hanafi' ? 'Hanafi' : 'Shafi'}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
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
