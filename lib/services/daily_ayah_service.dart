import 'dart:math';

import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

class DailyAyah {
  const DailyAyah({
    required this.surahNumber,
    required this.verseNumber,
    required this.arabic,
    required this.translation,
    required this.surahName,
  });

  final int surahNumber;
  final int verseNumber;
  final String arabic;
  final String translation;
  final String surahName;
}

class DailyAyahService {
  static Future<DailyAyah> getToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final savedDate = prefs.getString('dailyAyahDate');
    int surah;
    int verse;

    if (savedDate == todayKey) {
      surah = prefs.getInt('dailyAyahSurah') ?? 1;
      verse = prefs.getInt('dailyAyahVerse') ?? 1;
    } else {
      final seed = today.year * 10000 + today.month * 100 + today.day;
      final random = Random(seed);
      surah = random.nextInt(quran.totalSurahCount) + 1;
      final verseCount = quran.getVerseCount(surah);
      verse = random.nextInt(verseCount) + 1;
      await prefs.setString('dailyAyahDate', todayKey);
      await prefs.setInt('dailyAyahSurah', surah);
      await prefs.setInt('dailyAyahVerse', verse);
    }

    return DailyAyah(
      surahNumber: surah,
      verseNumber: verse,
      arabic: quran.getVerse(surah, verse, verseEndSymbol: true),
      translation: quran.getVerseTranslation(surah, verse),
      surahName: quran.getSurahNameEnglish(surah),
    );
  }
}
