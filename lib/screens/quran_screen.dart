import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../widgets/app_background.dart';
import 'juz_screen.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quran', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_numbered, color: Colors.white),
            tooltip: 'Browse by Juz',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const JuzScreen()),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search surah by name or number',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.9),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
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
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: ListTile(
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
