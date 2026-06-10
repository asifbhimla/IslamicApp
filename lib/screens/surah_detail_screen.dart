import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../app_state.dart';

class SurahDetailScreen extends StatelessWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arabicFontSize = context
        .select<AppState, double>((state) => state.quranArabicFontSize);
    final verseCount = quran.getVerseCount(surahNumber);
    // Every surah except At-Tawbah (9) opens with the basmala; in Al-Fatihah
    // (1) it is already verse 1.
    final showBasmala = surahNumber != 1 && surahNumber != 9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${quran.getSurahName(surahNumber)} · ${quran.getSurahNameArabic(surahNumber)}'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: verseCount + 1,
        separatorBuilder: (_, _) => const Divider(height: 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                Text(
                  '${quran.getSurahNameEnglish(surahNumber)} · '
                  '${quran.getPlaceOfRevelation(surahNumber)} · '
                  '$verseCount verses',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (showBasmala) ...[
                  const SizedBox(height: 16),
                  Text(
                    quran.basmala,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            );
          }
          final verse = index;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                quran.getVerse(surahNumber, verse, verseEndSymbol: true),
                style: TextStyle(
                  fontSize: arabicFontSize,
                  height: 2,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                '$verse. ${quran.getVerseTranslation(surahNumber, verse)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
