import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import 'surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahs = [
      for (var i = 1; i <= quran.totalSurahCount; i++) i,
    ].where((i) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return quran.getSurahName(i).toLowerCase().contains(q) ||
          quran.getSurahNameEnglish(i).toLowerCase().contains(q) ||
          i.toString() == q;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search surah by name or number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Text(
                      '$surah',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(quran.getSurahName(surah)),
                  subtitle: Text(
                    '${quran.getSurahNameEnglish(surah)} · '
                    '${quran.getPlaceOfRevelation(surah)} · '
                    '${quran.getVerseCount(surah)} verses',
                  ),
                  trailing: Text(
                    quran.getSurahNameArabic(surah),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(surahNumber: surah),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
