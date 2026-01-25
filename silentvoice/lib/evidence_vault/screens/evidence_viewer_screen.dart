import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
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

  double downloadProgress = 0.0;

  AudioPlayer? _audioPlayer;
  File? _tempAudioFile;

  VideoPlayerController? _videoController;
  File? _tempVideoFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAndDecrypt();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pausePlayback();
    }
  }

  void _pausePlayback() {
    _audioPlayer?.stop();
    if (_videoController?.value.isPlaying == true) {
      _videoController!.pause();
    }
  }

  void _toggleMute() {
    setState(() => isMuted = !isMuted);

    _audioPlayer?.setVolume(isMuted ? 0.0 : 1.0);
    _videoController?.setVolume(isMuted ? 0.0 : 1.0);
  }

  void _toggleVideoPlayback() {
    if (_videoController == null) return;

    setState(() {
      _videoController!.value.isPlaying
          ? _videoController!.pause()
          : _videoController!.play();
    });
  }

  Future<void> _loadAndDecrypt() async {
    try {
      final storageRef = FirebaseStorage.instance.ref(widget.item.storagePath);

      final tempDir = await getTemporaryDirectory();
      final encryptedTempFile = File('${tempDir.path}/${widget.item.id}.enc');

      final downloadTask = storageRef.writeToFile(encryptedTempFile);

      downloadTask.snapshotEvents.listen((snapshot) {
        if (!mounted) return;
        if (snapshot.totalBytes > 0) {
          setState(() {
            downloadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await downloadTask;

      final encryptedBytes = await encryptedTempFile.readAsBytes();

      final decrypted = AesCrypto.decrypt(
        encryptedData: encryptedBytes,
        key: widget.encryptionKey,
      );

      await encryptedTempFile.delete();

      if (widget.item.type == EvidenceType.audio) {
        final audioFile = File('${tempDir.path}/${widget.item.id}.m4a');
        await audioFile.writeAsBytes(decrypted, flush: true);

        _tempAudioFile = audioFile;
        _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      }

      if (widget.item.type == EvidenceType.video) {
        final videoFile = File('${tempDir.path}/${widget.item.id}.mp4');
        await videoFile.writeAsBytes(decrypted, flush: true);

        _tempVideoFile = videoFile;
        _videoController = VideoPlayerController.file(videoFile);
        await _videoController!.initialize();
        await Future.delayed(const Duration(milliseconds: 200));

        _videoController!.addListener(() {
          if (mounted) setState(() {});
        });
      }

      if (!mounted) return;

      setState(() {
        decryptedBytes = decrypted;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Playback Error: $e");
      if (!mounted) return;
      setState(() {
        error = 'Failed to open evidence on this device.';
        isLoading = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (_audioPlayer == null || _tempAudioFile == null) return;
    await _audioPlayer!.play(DeviceFileSource(_tempAudioFile!.path));
  }

  Future<void> _stopAudio() async {
    await _audioPlayer?.stop();
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
          value: position.inMilliseconds
              .clamp(0, duration.inMilliseconds)
              .toDouble(),
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Decrypting evidence...'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: downloadProgress),
              const SizedBox(height: 8),
              Text('${(downloadProgress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      );
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
        actions: const [QuickExitButton()],
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    switch (widget.item.type) {
      case EvidenceType.image:
        return Center(child: Image.memory(decryptedBytes!));

      case EvidenceType.audio:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack, size: 64),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _playAudio, child: const Text('Play')),
              ElevatedButton(onPressed: _stopAudio, child: const Text('Stop')),
              IconButton(
                onPressed: _toggleMute,
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
              ),
            ],
          ),
        );

      case EvidenceType.video:
        if (_videoController == null ||
            !_videoController!.value.isInitialized) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Preparing video decoder...'),
              ],
            ),
          );
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
                    heroTag: 'mute',
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
    _tempAudioFile?.deleteSync();
    _tempVideoFile?.deleteSync();
    super.dispose();
  }
}
