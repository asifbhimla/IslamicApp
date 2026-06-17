import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

/// Translation language options for the Quran.
class TranslationOption {
  const TranslationOption(this.key, this.label, this.translation);

  final String key;
  final String label;
  final quran.Translation translation;
}

final List<TranslationOption> translationOptions = [
  const TranslationOption('none', 'None (disabled)', quran.Translation.enSaheeh),
  const TranslationOption('enSaheeh', 'English (Saheeh International)', quran.Translation.enSaheeh),
  const TranslationOption('enClearQuran', 'English (Clear Quran)', quran.Translation.enClearQuran),
  const TranslationOption('urdu', 'Urdu', quran.Translation.urdu),
  const TranslationOption('french', 'French', quran.Translation.frHamidullah),
  const TranslationOption('turkish', 'Turkish', quran.Translation.trSaheeh),
  const TranslationOption('indonesian', 'Indonesian', quran.Translation.indonesian),
  const TranslationOption('bengali', 'Bengali', quran.Translation.bengali),
  const TranslationOption('russian', 'Russian', quran.Translation.ruKuliev),
  const TranslationOption('chinese', 'Chinese', quran.Translation.chinese),
  const TranslationOption('spanish', 'Spanish', quran.Translation.spanish),
  const TranslationOption('portuguese', 'Portuguese', quran.Translation.portuguese),
  const TranslationOption('italian', 'Italian', quran.Translation.itPiccardo),
  const TranslationOption('dutch', 'Dutch', quran.Translation.nlSiregar),
  const TranslationOption('swedish', 'Swedish', quran.Translation.swedish),
  const TranslationOption('persian', 'Persian (Farsi)', quran.Translation.faHusseinDari),
  const TranslationOption('malayalam', 'Malayalam', quran.Translation.mlAbdulHameed),
];

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
  String secondaryTranslationKey = 'none';

  TranslationOption? get secondaryTranslation {
    if (secondaryTranslationKey == 'none') return null;
    return translationOptions.firstWhere(
      (t) => t.key == secondaryTranslationKey,
      orElse: () => translationOptions.first,
    );
  }

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
    secondaryTranslationKey =
        prefs.getString('secondaryTranslation') ?? secondaryTranslationKey;
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
    await prefs.setString('secondaryTranslation', secondaryTranslationKey);
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

  Future<void> setSecondaryTranslation(String key) async {
    secondaryTranslationKey = key;
    notifyListeners();
    await _save();
  }
}
