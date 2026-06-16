import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../app_state.dart';
import '../widgets/quran_audio_player.dart';

class SurahDetailScreen extends StatelessWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arabicFontSize = context
        .select<AppState, double>((state) => state.quranArabicFontSize);
    final verseCount = quran.getVerseCount(surahNumber);
    final showBasmala = surahNumber != 1 && surahNumber != 9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${quran.getSurahName(surahNumber)} · ${quran.getSurahNameArabic(surahNumber)}'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: QuranAudioPlayer(surahNumber: surahNumber),
            ),
          ),
          Expanded(
            child: ListView.separated(
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
                return _VerseRow(
                  surahNumber: surahNumber,
                  verseNumber: verse,
                  arabicFontSize: arabicFontSize,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseRow extends StatefulWidget {
  const _VerseRow({
    required this.surahNumber,
    required this.verseNumber,
    required this.arabicFontSize,
  });

  final int surahNumber;
  final int verseNumber;
  final double arabicFontSize;

  @override
  State<_VerseRow> createState() => _VerseRowState();
}

class _VerseRowState extends State<_VerseRow> {
  AudioPlayer? _versePlayer;
  bool _playing = false;
  bool _loading = false;

  @override
  void dispose() {
    _versePlayer?.dispose();
    super.dispose();
  }

  Future<void> _toggleVerse() async {
    if (_playing) {
      _versePlayer?.stop();
      setState(() => _playing = false);
      return;
    }

    setState(() => _loading = true);
    try {
      _versePlayer ??= AudioPlayer();
      final url = quran.getAudioURLByVerse(
          widget.surahNumber, widget.verseNumber);
      await _versePlayer!.setUrl(url);
      setState(() {
        _playing = true;
        _loading = false;
      });
      await _versePlayer!.play();
      if (mounted) setState(() => _playing = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                quran.getVerse(widget.surahNumber, widget.verseNumber,
                    verseEndSymbol: true),
                style: TextStyle(
                  fontSize: widget.arabicFontSize,
                  height: 2,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(
              width: 36,
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _playing ? Icons.stop : Icons.play_arrow,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: _playing ? 'Stop verse' : 'Play verse',
                      onPressed: _toggleVerse,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.verseNumber}. ${quran.getVerseTranslation(widget.surahNumber, widget.verseNumber)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
