import 'package:audioplayers/audioplayers.dart';

/// Audio cue playback service for expense actions and settlement milestones.
class SoundService {
  final AudioPlayer _player;

  SoundService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  Future<void> playExpenseAdded() async {
    // TODO: Play expense added audio asset.
  }

  Future<void> playSettled() async {
    // TODO: Play settlement milestone audio asset.
  }

  Future<void> playNudge() async {
    // TODO: Play reminder nudge audio asset.
  }

  Future<void> dispose() => _player.dispose();
}
