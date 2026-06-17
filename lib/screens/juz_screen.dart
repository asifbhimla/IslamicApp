import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import 'surah_detail_screen.dart';

/// Traditional names of the 30 ajza, indexed 0..29 (Juz 1..30).
const List<String> juzNames = [
  'Alif Lam Meem',
  'Sayaqul',
  'Tilkal Rusul',
  'Lan Tanaloo',
  'Wal Mohsanat',
  'La Yuhibbullah',
  "Wa Iza Sami'oo",
  'Wa Lau Annana',
  "Qalal Mala'u",
  "Wa A'lamoo",
  "Ya'tazeroon",
  "Wa Mamin Da'abat",
  'Wa Ma Ubri-oo',
  'Rubama',
  'Subhanallazi',
  'Qal Alam',
  'Iqtarabat',
  'Qad Aflaha',
  'Wa Qalallazina',
  "A'man Khalaqa",
  'Utlu Ma Oohiya',
  'Wa Manyaqnut',
  'Wa Mali',
  'Faman Azlam',
  'Ilayhi Yuruddu',
  "Ha'a Meem",
  'Qala Fama Khatbukum',
  'Qad Sami Allah',
  'Tabarakallazi',
  "'Amma",
];

/// Arabic names of the 30 ajza, indexed 0..29 (Juz 1..30).
const List<String> juzNamesArabic = [
  'الم',
  'سيقول',
  'تلك الرسل',
  'لن تنالوا',
  'والمحصنات',
  'لا يحب الله',
  'وإذا سمعوا',
  'ولو أننا',
  'قال الملأ',
  'واعلموا',
  'يعتذرون',
  'وما من دابة',
  'وما أبرئ',
  'ربما',
  'سبحان الذي',
  'قال ألم',
  'اقترب',
  'قد أفلح',
  'وقال الذين',
  'أمن خلق',
  'اتل ما أوحي',
  'ومن يقنت',
  'ومالي',
  'فمن أظلم',
  'إليه يرد',
  'حم',
  'قال فما خطبكم',
  'قد سمع الله',
  'تبارك الذي',
  'عم',
];

/// The list of all 30 ajza (Juz). Designed to live inside a tab, so it has no
/// Scaffold or AppBar of its own.
class JuzListView extends StatelessWidget {
  const JuzListView({super.key, this.query = ''});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = query.toLowerCase();
    final juzList = [
      for (var juz = 1; juz <= quran.totalJuzCount; juz++) juz,
    ].where((juz) {
      if (q.isEmpty) return true;
      return juzNames[juz - 1].toLowerCase().contains(q) ||
          juzNamesArabic[juz - 1].contains(query) ||
          juz.toString() == q;
    }).toList();

    return ListView.builder(
      key: const ValueKey('juzListView'),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        final juz = juzList[index];
        final surahVerses = quran.getSurahAndVersesFromJuz(juz);
        final surahNumbers = surahVerses.keys.toList()..sort();
        final firstSurah = surahNumbers.first;
        final firstVerse = surahVerses[firstSurah]![0];
        final lastSurah = surahNumbers.last;
        final lastVerse = surahVerses[lastSurah]![1];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Text(
                '$juz',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              juzNames[juz - 1],
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Juz $juz · ${quran.getSurahName(firstSurah)} $firstVerse  →  '
              '${quran.getSurahName(lastSurah)} $lastVerse',
            ),
            trailing: Text(
              juzNamesArabic[juz - 1],
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surahNumber: firstSurah,
                  initialVerse: firstVerse,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
