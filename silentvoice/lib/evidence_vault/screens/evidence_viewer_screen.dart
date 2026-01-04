import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';
import 'package:silentvoice/evidence_vault/models/evidence_item.dart';
import 'package:silentvoice/security/aes_crypto.dart';

class EvidenceViewerScreen extends StatefulWidget {
  final EvidenceItem item;
  final Uint8List encryptionKey;

  const EvidenceViewerScreen({
    super.key,
    required this.item,
    required this.encryptionKey,
  });

  @override
  State<EvidenceViewerScreen> createState() => _EvidenceViewerScreenState();
}

class _EvidenceViewerScreenState extends State<EvidenceViewerScreen>
    with WidgetsBindingObserver {
  Uint8List? decryptedBytes;
  bool isLoading = true;
  String? error;
  bool isMuted = false;

  AudioPlayer? _audioPlayer;
  File? _tempAudioFile;

  VideoPlayerController? _videoController;
  File? _tempVideoFile;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausePlayback();
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });

    if (_audioPlayer != null) {
      _audioPlayer!.setVolume(isMuted ? 0.0 : 1.0);
    }

    if (_videoController != null) {
      _videoController!.setVolume(isMuted ? 0.0 : 1.0);
    }
  }

  void _pausePlayback() {
    if (_videoController != null && _videoController!.value.isPlaying) {
      _videoController!.pause();
    }

    _audioPlayer?.stop();
  }

  void _toggleVideoPlayback() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildVideoControls() {
    final controller = _videoController!;
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position)),
              Text(_formatDuration(duration)),
            ],
          ),
        ),

        Slider(
          value: position.inMilliseconds.toDouble().clamp(
            0.0,
            duration.inMilliseconds.toDouble(),
          ),
          min: 0,
          max: duration.inMilliseconds.toDouble(),
          onChanged: (value) {
            controller.seekTo(Duration(milliseconds: value.toInt()));
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAndDecrypt();
  }

  Future<void> _loadAndDecrypt() async {
    try {
      final file = File(widget.item.encryptedPath);
      final encryptedBytes = await file.readAsBytes();

      final decrypted = AesCrypto.decrypt(
        encryptedData: encryptedBytes,
        key: widget.encryptionKey,
      );

      final tempDir = await getTemporaryDirectory();
      if (widget.item.type == EvidenceType.audio) {
        final tempFile = File('${tempDir.path}/${widget.item.id}');

        await tempFile.writeAsBytes(decrypted);

        _tempAudioFile = tempFile;
        _audioPlayer = AudioPlayer();

        await _audioPlayer!.setReleaseMode(ReleaseMode.stop);
      }
      if (widget.item.type == EvidenceType.video) {
        final tempFile = File('${tempDir.path}/${widget.item.id}.mp4');
        await tempFile.writeAsBytes(decrypted);

        _tempVideoFile = tempFile;
        _videoController = VideoPlayerController.file(tempFile);
        await _videoController!.initialize();
        _videoController!.addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
      }

      if (!mounted) return;

      setState(() {
        decryptedBytes = decrypted;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to open evidence';
        isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (_audioPlayer == null || _tempAudioFile == null) return;

    await _audioPlayer!.setVolume(1.0);

    await _audioPlayer!.play(
      DeviceFileSource(_tempAudioFile!.path),
      volume: 1.0,
    );
  }

  Future<void> _stopAudio() async {
    await _audioPlayer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evidence')),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence'),
        actions: [QuickExitButton()],
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    switch (widget.item.type) {
      case EvidenceType.image:
        return Image.memory(decryptedBytes!);

      case EvidenceType.audio:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack, size: 64),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _playAudio,
                child: const Text('Play Audio'),
              ),
              ElevatedButton(
                onPressed: _stopAudio,
                child: const Text('Stop Audio'),
              ),
              IconButton(
                onPressed: _toggleMute,
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  size: 32,
                ),
              ),
            ],
          ),
        );

      case EvidenceType.video:
        if (_videoController == null) {
          return const Center(child: Text('Loading video...'));
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'play_pause',

                    onPressed: _toggleVideoPlayback,
                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),

                  const SizedBox(width: 16),

                  FloatingActionButton(
                    heroTag: 'mute_unmute',

                    onPressed: _toggleMute,
                    child: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildVideoControls(),
            ),
          ],
        );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer?.dispose();
    _videoController?.dispose();

    if (_tempAudioFile != null && _tempAudioFile!.existsSync()) {
      _tempAudioFile!.deleteSync();
    }
    if (_tempVideoFile?.existsSync() == true) {
      _tempVideoFile!.deleteSync();
    }

    super.dispose();
  }
}
