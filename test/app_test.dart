import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/app_state.dart';
import 'package:islamic_app/data/duas_data.dart';
import 'package:islamic_app/screens/duas_screen.dart';
import 'package:islamic_app/screens/quran_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child, AppState state) {
  return ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(home: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState', () {
    test('computes ordered prayer times for the default location', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();

      final entries = state.prayerEntriesFor(DateTime(2026, 6, 10));
      expect(entries.map((e) => e.name), [
        'Fajr',
        'Sunrise',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ]);
      for (var i = 1; i < entries.length; i++) {
        expect(entries[i].time.isAfter(entries[i - 1].time), isTrue,
            reason: '${entries[i].name} should come after '
                '${entries[i - 1].name}');
      }
    });

    test('next prayer is always in the future', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();

      final now = DateTime.now();
      final next = state.nextPrayer(now: now);
      expect(next.time.isAfter(now), isTrue);
    });

    test('Qibla direction from London points toward Makkah', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();

      state.latitude = 51.5074;
      state.longitude = -0.1278;
      final qibla = state.qiblaDirection;
      // The Qibla from London is roughly 118-119 degrees from north.
      expect(qibla, greaterThan(110));
      expect(qibla, lessThan(130));
    });

    test('current prayer is the one in progress, distinct from next', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();

      final entries = state
          .prayerEntriesFor(DateTime(2026, 6, 10))
          .where((e) => e.isObligatory)
          .toList();
      final dhuhr = entries.firstWhere((e) => e.name == 'Dhuhr').time;
      final now = dhuhr.add(const Duration(minutes: 1));

      expect(state.currentPrayer(now: now).name, 'Dhuhr');
      expect(state.nextPrayer(now: now).name, 'Asr');
    });

    test('home tile follows the current/next 30-minute schedule', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();

      final date = DateTime(2026, 6, 10);
      final times = state.prayerTimesFor(date);
      final fajr = times.fajr.toLocal();
      final sunrise = times.sunrise.toLocal();
      final entries =
          state.prayerEntriesFor(date).where((e) => e.isObligatory).toList();
      final dhuhr = entries.firstWhere((e) => e.name == 'Dhuhr').time;
      final asr = entries.firstWhere((e) => e.name == 'Asr').time;

      ({PrayerEntry prayer, bool isCurrent}) at(DateTime t) =>
          state.homeTilePrayer(now: t);

      // 20 min before Fajr -> Next : Fajr
      var tile = at(fajr.subtract(const Duration(minutes: 20)));
      expect(tile.prayer.name, 'Fajr');
      expect(tile.isCurrent, isFalse);

      // After Fajr, before sunrise -> Current : Fajr
      tile = at(fajr.add(const Duration(minutes: 5)));
      expect(tile.prayer.name, 'Fajr');
      expect(tile.isCurrent, isTrue);

      // After sunrise -> Next : Dhuhr
      tile = at(sunrise.add(const Duration(minutes: 5)));
      expect(tile.prayer.name, 'Dhuhr');
      expect(tile.isCurrent, isFalse);

      // After Dhuhr -> Current : Dhuhr
      tile = at(dhuhr.add(const Duration(minutes: 5)));
      expect(tile.prayer.name, 'Dhuhr');
      expect(tile.isCurrent, isTrue);

      // 20 min before Asr -> Next : Asr
      tile = at(asr.subtract(const Duration(minutes: 20)));
      expect(tile.prayer.name, 'Asr');
      expect(tile.isCurrent, isFalse);
    });

    test('Hanafi madhab gives a later Asr', () async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();

      final date = DateTime(2026, 6, 10);
      final shafiAsr = state.prayerTimesFor(date).asr;
      state.madhab = Madhab.hanafi;
      final hanafiAsr = state.prayerTimesFor(date).asr;
      expect(hanafiAsr.isAfter(shafiAsr), isTrue);
    });
  });

  group('Screens', () {
    testWidgets('Quran screen lists and filters surahs', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.pumpWidget(_wrap(const QuranScreen(), state));

      expect(find.text('Al Fatiha'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '36');
      await tester.pump();
      expect(find.text("Ya'sin"), findsOneWidget);
      expect(find.text('Al Fatiha'), findsNothing);
    });

    testWidgets('Quran screen Juz tab lists ajza by name', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.pumpWidget(_wrap(const QuranScreen(), state));

      await tester.tap(find.text('Juz'));
      await tester.pumpAndSettle();

      expect(find.text('Alif Lam Meem'), findsOneWidget);
      final juzScrollable = find.descendant(
        of: find.byKey(const ValueKey('juzListView')),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(find.text("'Amma"), 300,
          scrollable: juzScrollable);
      expect(find.text("'Amma"), findsOneWidget);
    });

    testWidgets('Duas screen shows all categories', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.pumpWidget(_wrap(const DuasScreen(), state));

      for (final category in duaCategories) {
        expect(find.text(category.name), findsOneWidget);
      }
    });
  });
}
