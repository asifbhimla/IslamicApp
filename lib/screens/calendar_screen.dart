import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
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
  int? _selectedDay;
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
      _selectedDay = null;
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
    final locale = context.watch<AppState>().effectiveLocale;
    final today = HijriCalendar.now();
    final daysInMonth = _converter.getDaysInMonth(_hijriYear, _hijriMonth);
    final firstDayGregorian =
        _converter.hijriToGregorian(_hijriYear, _hijriMonth, 1);
    // Grid columns run Sunday..Saturday.
    final leadingBlanks = firstDayGregorian.weekday % 7;

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
          padding: EdgeInsets.fromLTRB(
              16, kToolbarHeight + MediaQuery.of(context).padding.top + 8, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: Icon(Icons.chevron_left,
                              color: theme.colorScheme.primary),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${_monthNames[_hijriMonth - 1]} $_hijriYear AH',
                                style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                _gregorianRangeLabel(daysInMonth, locale),
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeMonth(1),
                          icon: Icon(Icons.chevron_right,
                              color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        for (final day in const [
                          'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
                        ])
                          Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 0.92,
                      ),
                      itemCount: leadingBlanks + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < leadingBlanks) {
                          return const SizedBox.shrink();
                        }
                        final day = index - leadingBlanks + 1;
                        final gregorian =
                            firstDayGregorian.add(Duration(days: day - 1));
                        final isToday = today.hYear == _hijriYear &&
                            today.hMonth == _hijriMonth &&
                            today.hDay == day;
                        final isSelected = _selectedDay == day;
                        final event = eventOn(_hijriMonth, day);
                        final dayColor = isToday
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = day),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isToday ? theme.colorScheme.primary : null,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected && !isToday
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 1.5)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: dayColor,
                                    fontWeight: isToday || event != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  DateFormat.Md(locale).format(gregorian),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: isToday
                                        ? theme.colorScheme.onPrimary
                                            .withValues(alpha: 0.85)
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: event != null
                                        ? (isToday
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.primary)
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedDay != null) ...[
              const SizedBox(height: 12),
              _buildDayDetail(theme, locale, _selectedDay!),
            ],
            const SizedBox(height: 16),
            Text('Upcoming events',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.white)),
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
                        '${DateFormat.yMMMd(locale).format(upcoming.$3)}',
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

  Widget _buildDayDetail(ThemeData theme, String locale, int day) {
    final gregorian =
        _converter.hijriToGregorian(_hijriYear, _hijriMonth, day);
    final event = eventOn(_hijriMonth, day);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$day ${_monthNames[_hijriMonth - 1]} $_hijriYear AH',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.yMMMMEEEEd(locale).format(gregorian),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (event != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'No special event on this day.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _gregorianRangeLabel(int daysInMonth, String locale) {
    final start = _converter.hijriToGregorian(_hijriYear, _hijriMonth, 1);
    final end =
        _converter.hijriToGregorian(_hijriYear, _hijriMonth, daysInMonth);
    final format = DateFormat.yMMMd(locale);
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
