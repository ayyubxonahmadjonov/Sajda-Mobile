import 'package:just_audio/just_audio.dart';

class AyahAudioService {
  static final AyahAudioService _instance = AyahAudioService._internal();
  factory AyahAudioService() => _instance;
  AyahAudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Audio o'ynatish
  Future<void> play(String url) async {
    await _player.stop();
    await _player.setUrl(url);
    _player.play();
  }

  // Pause
  Future<void> pause() async {
    await _player.pause();
  }

  // Player streamni expose qilish
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  void dispose() {
    _player.dispose();
  }
}
