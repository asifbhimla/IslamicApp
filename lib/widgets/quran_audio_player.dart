import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

class QuranAudioPlayer extends StatefulWidget {
  const QuranAudioPlayer({
    super.key,
    required this.surahNumber,
    this.verseNumber,
    this.onPlayingVerseChanged,
  });

  final int surahNumber;
  final int? verseNumber;

  /// Called with the verse number currently sounding during full-surah
  /// playback, or null when nothing is playing. Only used in surah mode.
  final ValueChanged<int?>? onPlayingVerseChanged;

  @override
  State<QuranAudioPlayer> createState() => _QuranAudioPlayerState();
}

class _QuranAudioPlayerState extends State<QuranAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _loading = false;
  String? _error;
  quran.Reciter _reciter = quran.Reciter.arAlafasy;

  StreamSubscription<int?>? _indexSub;
  StreamSubscription<PlayerState>? _stateSub;
  int? _lastEmittedVerse;

  @override
  void initState() {
    super.initState();
    _indexSub = _player.currentIndexStream.listen((_) => _emitPlayingVerse());
    _stateSub =
        _player.playerStateStream.listen((_) => _emitPlayingVerse());
  }

  void _emitPlayingVerse() {
    final callback = widget.onPlayingVerseChanged;
    if (callback == null || widget.verseNumber != null) return;
    final state = _player.processingState;
    final index = _player.currentIndex;
    final active = index != null &&
        (state == ProcessingState.ready ||
            state == ProcessingState.buffering);
    final verse = active ? index + 1 : null;
    if (verse != _lastEmittedVerse) {
      _lastEmittedVerse = verse;
      callback(verse);
    }
  }

  @override
  void dispose() {
    _indexSub?.cancel();
    _stateSub?.cancel();
    widget.onPlayingVerseChanged?.call(null);
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAndPlay() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (widget.verseNumber != null) {
        await _player
            .setUrl(
              quran.getAudioURLByVerse(widget.surahNumber, widget.verseNumber!,
                  reciter: _reciter),
            )
            .timeout(const Duration(seconds: 15));
      } else {
        final verseCount = quran.getVerseCount(widget.surahNumber);
        final sources = <AudioSource>[
          for (var v = 1; v <= verseCount; v++)
            AudioSource.uri(
              Uri.parse(quran.getAudioURLByVerse(widget.surahNumber, v,
                  reciter: _reciter)),
            ),
        ];
        await _player
            .setAudioSources(sources)
            .timeout(const Duration(seconds: 15));
      }
      _player.play();
    } catch (e) {
      _error = 'Could not load audio. Check your internet connection.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_player.processingState == ProcessingState.idle ||
        _player.processingState == ProcessingState.completed) {
      await _loadAndPlay();
    } else if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _stop() {
    _player.stop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        final processingState =
            playerState?.processingState ?? ProcessingState.idle;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_loading)
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      processingState == ProcessingState.completed
                          ? Icons.replay
                          : playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                if (processingState != ProcessingState.idle)
                  IconButton(
                    icon: Icon(Icons.stop_circle_outlined,
                        size: 36, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: _stop,
                  ),
                const SizedBox(width: 8),
                _ReciterDropdown(
                  value: _reciter,
                  onChanged: (r) {
                    setState(() => _reciter = r);
                    if (processingState != ProcessingState.idle) {
                      _player.stop();
                      _loadAndPlay();
                    }
                  },
                ),
              ],
            ),
            if (processingState == ProcessingState.ready ||
                processingState == ProcessingState.buffering)
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, posSnap) {
                  final position = posSnap.data ?? Duration.zero;
                  final duration = _player.duration ?? Duration.zero;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(_formatDuration(position),
                            style: theme.textTheme.bodySmall),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: duration.inMilliseconds.toDouble().clamp(1, double.maxFinite),
                            value: position.inMilliseconds
                                .toDouble()
                                .clamp(0, duration.inMilliseconds.toDouble()),
                            onChanged: (value) {
                              _player.seek(
                                  Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Text(_formatDuration(duration),
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _ReciterDropdown extends StatelessWidget {
  const _ReciterDropdown({required this.value, required this.onChanged});

  final quran.Reciter value;
  final ValueChanged<quran.Reciter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DropdownButton<quran.Reciter>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: Theme.of(context).textTheme.bodySmall,
        items: quran.Reciter.values
            .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.englishName, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (r) {
          if (r != null) onChanged(r);
        },
      ),
    );
  }
}
