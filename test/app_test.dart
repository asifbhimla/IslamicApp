import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/app_state.dart';
import 'package:islamic_app/data/duas_data.dart';
import 'package:islamic_app/screens/duas_screen.dart';
import 'package:islamic_app/screens/juz_screen.dart';
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

    testWidgets('Juz screen lists all 30 ajza', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.pumpWidget(_wrap(const JuzScreen(), state));

      expect(find.text('Juz 1'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Juz 30'), 300);
      expect(find.text('Juz 30'), findsOneWidget);
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
