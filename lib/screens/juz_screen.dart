import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import 'surah_detail_screen.dart';

/// The list of all 30 ajza (Juz). Designed to live inside a tab, so it has no
/// Scaffold or AppBar of its own.
class JuzListView extends StatelessWidget {
  const JuzListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      key: const ValueKey('juzListView'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: quran.totalJuzCount,
      itemBuilder: (context, index) {
        final juz = index + 1;
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
            title: Text('Juz $juz'),
            subtitle: Text(
              '${quran.getSurahName(firstSurah)} $firstVerse  →  '
              '${quran.getSurahName(lastSurah)} $lastVerse\n'
              '${surahNumbers.length} '
              '${surahNumbers.length == 1 ? 'surah' : 'surahs'}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
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
