import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;

import '../app_state.dart';
import '../services/alquran_cloud_service.dart';
import '../widgets/app_background.dart';
import '../widgets/quran_audio_player.dart';

class SurahDetailScreen extends StatefulWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  int? _playingVerse;
  final Map<int, GlobalKey> _verseKeys = {};

  void _onPlayingVerseChanged(int? verse) {
    if (!mounted || verse == _playingVerse) return;
    setState(() => _playingVerse = verse);
    if (verse == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _verseKeys[verse]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.3,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahNumber = widget.surahNumber;
    final arabicFontSize = context
        .select<AppState, double>((state) => state.quranArabicFontSize);
    final verseCount = quran.getVerseCount(surahNumber);
    final showBasmala = surahNumber != 1 && surahNumber != 9;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
            '${quran.getSurahName(surahNumber)} · ${quran.getSurahNameArabic(surahNumber)}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Column(
        children: [
          SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
          Card(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: QuranAudioPlayer(
                surahNumber: surahNumber,
                onPlayingVerseChanged: _onPlayingVerseChanged,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              itemCount: verseCount + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${quran.getSurahNameEnglish(surahNumber)} · '
                            '${quran.getPlaceOfRevelation(surahNumber)} · '
                            '$verseCount verses',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (showBasmala) ...[
                            const SizedBox(height: 16),
                            Text(
                              quran.basmala,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                final verse = index;
                final isPlaying = _playingVerse == verse;
                return Card(
                  key: _verseKeys.putIfAbsent(verse, () => GlobalKey()),
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isPlaying ? theme.colorScheme.primaryContainer : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isPlaying
                        ? BorderSide(color: theme.colorScheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _VerseRow(
                      surahNumber: surahNumber,
                      verseNumber: verse,
                      arabicFontSize: arabicFontSize,
                      highlighted: isPlaying,
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

class _VerseRow extends StatefulWidget {
  const _VerseRow({
    required this.surahNumber,
    required this.verseNumber,
    required this.arabicFontSize,
    this.highlighted = false,
  });

  final int surahNumber;
  final int verseNumber;
  final double arabicFontSize;
  final bool highlighted;

  @override
  State<_VerseRow> createState() => _VerseRowState();
}

class _VerseRowState extends State<_VerseRow> {
  AudioPlayer? _versePlayer;
  bool _playing = false;
  bool _loading = false;

  String? _apiTranslation;
  String? _apiSecondaryTranslation;
  bool _apiFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchApiTranslations();
  }

  @override
  void didUpdateWidget(covariant _VerseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahNumber != widget.surahNumber ||
        oldWidget.verseNumber != widget.verseNumber) {
      _fetchApiTranslations();
    }
  }

  Future<void> _fetchApiTranslations() async {
    final state = context.read<AppState>();
    if (!state.useAlQuranCloudApi) return;

    setState(() => _apiFetching = true);
    final primary = await AlQuranCloudService.fetchVerseTranslation(
      widget.surahNumber,
      widget.verseNumber,
      state.apiPrimaryEdition,
    );
    String? secondary;
    if (state.apiSecondaryEdition != 'none') {
      secondary = await AlQuranCloudService.fetchVerseTranslation(
        widget.surahNumber,
        widget.verseNumber,
        state.apiSecondaryEdition,
      );
    }
    if (mounted) {
      setState(() {
        _apiTranslation = primary;
        _apiSecondaryTranslation = secondary;
        _apiFetching = false;
      });
    }
  }

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
    final state = context.watch<AppState>();
    final useApi = state.useAlQuranCloudApi;
    final secondary = state.secondaryTranslation;

    final highlighted = widget.highlighted;
    final mainText = highlighted
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final accentText = highlighted
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;
    final subText = highlighted
        ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.85)
        : theme.colorScheme.onSurfaceVariant;

    final primaryTranslation = useApi
        ? (_apiTranslation ??
            quran.getVerseTranslation(
                widget.surahNumber, widget.verseNumber))
        : quran.getVerseTranslation(
            widget.surahNumber, widget.verseNumber);

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
                  color: mainText,
                  fontWeight: FontWeight.w500,
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
                        color: accentText,
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
        if (_apiFetching && useApi)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${widget.verseNumber}.  ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accentText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: primaryTranslation),
            ],
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: mainText,
            height: 1.5,
          ),
        ),
        if (useApi && state.apiSecondaryEdition != 'none') ...[
          const SizedBox(height: 6),
          Text(
            _apiSecondaryTranslation ??
                quran.getVerseTranslation(
                    widget.surahNumber, widget.verseNumber),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subText,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else if (!useApi && secondary != null) ...[
          const SizedBox(height: 6),
          Text(
            quran.getVerseTranslation(
              widget.surahNumber,
              widget.verseNumber,
              translation: secondary.translation,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subText,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
