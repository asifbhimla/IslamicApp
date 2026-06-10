import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Calculation methods offered in Settings, keyed by a stable string that is
/// persisted in SharedPreferences.
class CalculationMethodOption {
  const CalculationMethodOption(this.key, this.label, this.builder);

  final String key;
  final String label;
  final CalculationParameters Function() builder;
}

final List<CalculationMethodOption> calculationMethods = [
  CalculationMethodOption('muslimWorldLeague', 'Muslim World League',
      CalculationMethodParameters.muslimWorldLeague),
  CalculationMethodOption('northAmerica', 'ISNA (North America)',
      CalculationMethodParameters.northAmerica),
  CalculationMethodOption('egyptian', 'Egyptian General Authority',
      CalculationMethodParameters.egyptian),
  CalculationMethodOption('karachi', 'University of Islamic Sciences, Karachi',
      CalculationMethodParameters.karachi),
  CalculationMethodOption('ummAlQura', 'Umm Al-Qura (Makkah)',
      CalculationMethodParameters.ummAlQura),
  CalculationMethodOption(
      'dubai', 'Dubai', CalculationMethodParameters.dubai),
  CalculationMethodOption('moonsightingCommittee', 'Moonsighting Committee',
      CalculationMethodParameters.moonsightingCommittee),
  CalculationMethodOption(
      'singapore', 'Singapore (MUIS)', CalculationMethodParameters.singapore),
  CalculationMethodOption('turkiye', 'Türkiye (Diyanet)',
      CalculationMethodParameters.turkiye),
  CalculationMethodOption(
      'kuwait', 'Kuwait', CalculationMethodParameters.kuwait),
  CalculationMethodOption('qatar', 'Qatar', CalculationMethodParameters.qatar),
  CalculationMethodOption(
      'tehran', 'Tehran', CalculationMethodParameters.tehran),
  CalculationMethodOption(
      'jafari', 'Jafari', CalculationMethodParameters.jafari),
];

/// A single prayer time entry for display.
class PrayerEntry {
  const PrayerEntry(this.name, this.time, {this.isObligatory = true});

  final String name;
  final DateTime time;
  final bool isObligatory;
}

class AppState extends ChangeNotifier {
  // Makkah is the fallback until the user grants location access.
  double latitude = 21.4225;
  double longitude = 39.8262;
  String locationLabel = 'Makkah (default)';

  String calculationMethodKey = 'muslimWorldLeague';
  Madhab madhab = Madhab.shafi;
  bool athanNotificationsEnabled = true;
  double quranArabicFontSize = 26;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    latitude = prefs.getDouble('latitude') ?? latitude;
    longitude = prefs.getDouble('longitude') ?? longitude;
    locationLabel = prefs.getString('locationLabel') ?? locationLabel;
    calculationMethodKey =
        prefs.getString('calculationMethod') ?? calculationMethodKey;
    madhab = (prefs.getString('madhab') ?? 'shafi') == 'hanafi'
        ? Madhab.hanafi
        : Madhab.shafi;
    athanNotificationsEnabled =
        prefs.getBool('athanNotificationsEnabled') ?? true;
    quranArabicFontSize =
        prefs.getDouble('quranArabicFontSize') ?? quranArabicFontSize;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    await prefs.setString('locationLabel', locationLabel);
    await prefs.setString('calculationMethod', calculationMethodKey);
    await prefs.setString(
        'madhab', madhab == Madhab.hanafi ? 'hanafi' : 'shafi');
    await prefs.setBool(
        'athanNotificationsEnabled', athanNotificationsEnabled);
    await prefs.setDouble('quranArabicFontSize', quranArabicFontSize);
  }

  CalculationMethodOption get calculationMethod => calculationMethods
      .firstWhere((m) => m.key == calculationMethodKey,
          orElse: () => calculationMethods.first);

  CalculationParameters get _parameters {
    final params = calculationMethod.builder();
    params.madhab = madhab;
    return params;
  }

  PrayerTimes prayerTimesFor(DateTime date) {
    return PrayerTimes(
      date: date,
      coordinates: Coordinates(latitude, longitude),
      calculationParameters: _parameters,
    );
  }

  /// The five daily prayers plus sunrise for [date], in local time.
  List<PrayerEntry> prayerEntriesFor(DateTime date) {
    final times = prayerTimesFor(date);
    return [
      PrayerEntry('Fajr', times.fajr.toLocal()),
      PrayerEntry('Sunrise', times.sunrise.toLocal(), isObligatory: false),
      PrayerEntry('Dhuhr', times.dhuhr.toLocal()),
      PrayerEntry('Asr', times.asr.toLocal()),
      PrayerEntry('Maghrib', times.maghrib.toLocal()),
      PrayerEntry('Isha', times.isha.toLocal()),
    ];
  }

  /// The next upcoming prayer relative to [now] (defaults to current time).
  /// Falls back to tomorrow's Fajr after Isha.
  PrayerEntry nextPrayer({DateTime? now}) {
    now ??= DateTime.now();
    final today = prayerEntriesFor(now)
        .where((e) => e.isObligatory)
        .toList();
    for (final entry in today) {
      if (entry.time.isAfter(now)) return entry;
    }
    final tomorrow = prayerTimesFor(now.add(const Duration(days: 1)));
    return PrayerEntry('Fajr', tomorrow.fajr.toLocal());
  }

  Future<void> setLocation(double lat, double lng, String label) async {
    latitude = lat;
    longitude = lng;
    locationLabel = label;
    notifyListeners();
    await _save();
  }

  Future<void> setCalculationMethod(String key) async {
    calculationMethodKey = key;
    notifyListeners();
    await _save();
  }

  Future<void> setMadhab(Madhab value) async {
    madhab = value;
    notifyListeners();
    await _save();
  }

  Future<void> setAthanNotificationsEnabled(bool value) async {
    athanNotificationsEnabled = value;
    notifyListeners();
    await _save();
  }

  Future<void> setQuranArabicFontSize(double value) async {
    quranArabicFontSize = value;
    notifyListeners();
    await _save();
  }
}
