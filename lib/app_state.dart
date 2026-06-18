import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

/// A region/locale option that drives date and time formatting.
class RegionOption {
  const RegionOption(this.key, this.label);

  /// Locale string such as 'en_US'. An empty key means "device default".
  final String key;
  final String label;
}

const List<RegionOption> regionOptions = [
  RegionOption('', 'Device default'),
  RegionOption('en_US', 'United States — English'),
  RegionOption('en_GB', 'United Kingdom — English'),
  RegionOption('en_CA', 'Canada — English'),
  RegionOption('en_AU', 'Australia — English'),
  RegionOption('en_IN', 'India — English'),
  RegionOption('en_PK', 'Pakistan — English'),
  RegionOption('ar_SA', 'Saudi Arabia — العربية'),
  RegionOption('ar_AE', 'United Arab Emirates — العربية'),
  RegionOption('ar_EG', 'Egypt — العربية'),
  RegionOption('tr_TR', 'Türkiye — Türkçe'),
  RegionOption('id_ID', 'Indonesia — Bahasa Indonesia'),
  RegionOption('ms_MY', 'Malaysia — Bahasa Melayu'),
  RegionOption('ur_PK', 'Pakistan — اردو'),
  RegionOption('bn_BD', 'Bangladesh — বাংলা'),
  RegionOption('fr_FR', 'France — Français'),
  RegionOption('de_DE', 'Germany — Deutsch'),
  RegionOption('ru_RU', 'Russia — Русский'),
];

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
  bool useAlQuranCloudApi = false;
  String apiPrimaryEdition = 'en.sahih';
  String apiSecondaryEdition = 'none';

  /// Selected region. Empty string means "follow the device locale".
  String regionKey = '';

  /// The device's locale string (e.g. 'en_US'), set once at startup. Used as
  /// the effective locale when [regionKey] is empty.
  String deviceLocale = 'en_US';

  RegionOption get region => regionOptions.firstWhere(
      (r) => r.key == regionKey,
      orElse: () => regionOptions.first);

  /// The locale used for all date/number formatting.
  String get effectiveLocale =>
      regionKey.isEmpty ? deviceLocale : regionKey;

  /// Hijri calendar language, derived from the effective locale. The hijri
  /// package only ships 'en', 'ar' and 'tr' month/day names.
  String get _hijriLanguage {
    final lang = effectiveLocale.split(RegExp('[_-]')).first;
    if (lang == 'ar') return 'ar';
    if (lang == 'tr') return 'tr';
    return 'en';
  }

  /// Apply the effective locale to the global formatting state. Safe to call
  /// repeatedly (e.g. on startup and whenever the region changes).
  void applyLocale() {
    Intl.defaultLocale = effectiveLocale;
    HijriCalendar.setLocal(_hijriLanguage);
  }

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
    useAlQuranCloudApi = prefs.getBool('useAlQuranCloudApi') ?? false;
    apiPrimaryEdition =
        prefs.getString('apiPrimaryEdition') ?? apiPrimaryEdition;
    apiSecondaryEdition =
        prefs.getString('apiSecondaryEdition') ?? apiSecondaryEdition;
    regionKey = prefs.getString('regionKey') ?? regionKey;
    applyLocale();
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
    await prefs.setBool('useAlQuranCloudApi', useAlQuranCloudApi);
    await prefs.setString('apiPrimaryEdition', apiPrimaryEdition);
    await prefs.setString('apiSecondaryEdition', apiSecondaryEdition);
    await prefs.setString('regionKey', regionKey);
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

  /// Initial great-circle bearing (degrees clockwise from true north) from the
  /// current location to the Kaaba in Makkah.
  double get qiblaDirection {
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;
    final phi1 = latitude * math.pi / 180;
    final phi2 = kaabaLat * math.pi / 180;
    final deltaLng = (kaabaLng - longitude) * math.pi / 180;
    final y = math.sin(deltaLng) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLng);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
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

  /// The current (most recently started) obligatory prayer relative to [now].
  /// Before today's Fajr this is yesterday's Isha.
  PrayerEntry currentPrayer({DateTime? now}) {
    now ??= DateTime.now();
    final today =
        prayerEntriesFor(now).where((e) => e.isObligatory).toList();
    PrayerEntry? current;
    for (final entry in today) {
      if (!entry.time.isAfter(now)) {
        current = entry;
      } else {
        break;
      }
    }
    if (current != null) return current;
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayEntries =
        prayerEntriesFor(yesterday).where((e) => e.isObligatory).toList();
    return yesterdayEntries.last;
  }

  /// What the home tile should display relative to [now].
  ///
  /// A prayer is shown as "current" from its start time until its switch point,
  /// after which the next prayer is shown as "next". The switch point is 30
  /// minutes before the next prayer starts — except for Fajr, whose switch
  /// point is sunrise.
  ({PrayerEntry prayer, bool isCurrent}) homeTilePrayer({DateTime? now}) {
    now ??= DateTime.now();
    final current = currentPrayer(now: now);
    final next = nextPrayer(now: now);

    final DateTime switchPoint;
    if (current.name == 'Fajr') {
      switchPoint = prayerTimesFor(now).sunrise.toLocal();
    } else {
      switchPoint = next.time.subtract(const Duration(minutes: 30));
    }

    if (now.isBefore(switchPoint)) {
      return (prayer: current, isCurrent: true);
    }
    return (prayer: next, isCurrent: false);
  }

  /// The name of the prayer/period chip to highlight: the most recent entry
  /// (including Sunrise) whose time has begun. So Fajr is highlighted from its
  /// start until sunrise, Sunrise until Dhuhr, and so on. Before today's Fajr,
  /// Isha (carried over from the night) is highlighted.
  String selectedPrayerName({DateTime? now}) {
    now ??= DateTime.now();
    PrayerEntry? started;
    for (final entry in prayerEntriesFor(now)) {
      if (!entry.time.isAfter(now)) {
        started = entry;
      } else {
        break;
      }
    }
    return started?.name ?? 'Isha';
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

  Future<void> setUseAlQuranCloudApi(bool value) async {
    useAlQuranCloudApi = value;
    notifyListeners();
    await _save();
  }

  Future<void> setApiPrimaryEdition(String value) async {
    apiPrimaryEdition = value;
    notifyListeners();
    await _save();
  }

  Future<void> setApiSecondaryEdition(String value) async {
    apiSecondaryEdition = value;
    notifyListeners();
    await _save();
  }

  Future<void> setRegion(String key) async {
    regionKey = key;
    applyLocale();
    notifyListeners();
    await _save();
  }
}
