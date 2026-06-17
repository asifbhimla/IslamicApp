import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../data/islamic_events.dart';
import '../widgets/app_background.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _hijriYear;
  late int _hijriMonth;
  final HijriCalendar _converter = HijriCalendar.now();

  static const List<String> _monthNames = [
    'Muharram',
    'Safar',
    "Rabi' al-Awwal",
    "Rabi' al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhul-Qa'dah",
    'Dhul-Hijjah',
  ];

  @override
  void initState() {
    super.initState();
    final today = HijriCalendar.now();
    _hijriYear = today.hYear;
    _hijriMonth = today.hMonth;
  }

  void _changeMonth(int delta) {
    setState(() {
      _hijriMonth += delta;
      if (_hijriMonth > 12) {
        _hijriMonth = 1;
        _hijriYear++;
      } else if (_hijriMonth < 1) {
        _hijriMonth = 12;
        _hijriYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = HijriCalendar.now();
    final daysInMonth = _converter.getDaysInMonth(_hijriYear, _hijriMonth);
    final firstDayGregorian =
        _converter.hijriToGregorian(_hijriYear, _hijriMonth, 1);
    // Grid columns run Sunday..Saturday.
    final leadingBlanks = firstDayGregorian.weekday % 7;

    final monthEvents = islamicEvents
        .where((e) => e.month == _hijriMonth && e.day <= daysInMonth)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Islamic Calendar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: ListView(
        padding: EdgeInsets.fromLTRB(16, kToolbarHeight + MediaQuery.of(context).padding.top + 8, 16, 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Column(
                children: [
                  Text(
                    '${_monthNames[_hijriMonth - 1]} $_hijriYear AH',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    _gregorianRangeLabel(daysInMonth),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final day in const [
                'Sun',
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat'
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final gregorian =
                  firstDayGregorian.add(Duration(days: day - 1));
              final isToday = today.hYear == _hijriYear &&
                  today.hMonth == _hijriMonth &&
                  today.hDay == day;
              final event = eventOn(_hijriMonth, day);

              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday
                      ? theme.colorScheme.primary
                      : event != null
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isToday
                            ? theme.colorScheme.onPrimary
                            : event != null
                                ? theme.colorScheme.primary
                                : null,
                        fontWeight:
                            isToday || event != null ? FontWeight.bold : null,
                      ),
                    ),
                    Text(
                      DateFormat('d/M').format(gregorian),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: isToday
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ),
          ),
          const SizedBox(height: 16),
          if (monthEvents.isNotEmpty) ...[
            Text('This month', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (final event in monthEvents)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        child: Text(
                          '${event.day}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(event.name),
                      subtitle: Text(
                        DateFormat('EEEE, d MMMM yyyy').format(
                          _converter.hijriToGregorian(
                              _hijriYear, _hijriMonth, event.day),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Upcoming events', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final upcoming in _upcomingEvents(today))
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(upcoming.$1.name),
                    subtitle: Text(
                      '${upcoming.$1.day} ${_monthNames[upcoming.$1.month - 1]} ${upcoming.$2} AH · '
                      '${DateFormat('d MMM yyyy').format(upcoming.$3)}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hijri dates are estimates based on astronomical calculation and '
            'may differ by a day from local moon sighting.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }

  String _gregorianRangeLabel(int daysInMonth) {
    final start = _converter.hijriToGregorian(_hijriYear, _hijriMonth, 1);
    final end =
        _converter.hijriToGregorian(_hijriYear, _hijriMonth, daysInMonth);
    final format = DateFormat('d MMM yyyy');
    return '${format.format(start)} – ${format.format(end)}';
  }

  /// The next five events from today onward, as (event, hijri year, gregorian
  /// date) records.
  List<(IslamicEvent, int, DateTime)> _upcomingEvents(HijriCalendar today) {
    final results = <(IslamicEvent, int, DateTime)>[];
    for (var year = today.hYear; year <= today.hYear + 1; year++) {
      for (final event in islamicEvents) {
        if (year == today.hYear &&
            (event.month < today.hMonth ||
                (event.month == today.hMonth && event.day < today.hDay))) {
          continue;
        }
        results.add((
          event,
          year,
          _converter.hijriToGregorian(year, event.month, event.day),
        ));
      }
    }
    return results.take(5).toList();
  }
}
