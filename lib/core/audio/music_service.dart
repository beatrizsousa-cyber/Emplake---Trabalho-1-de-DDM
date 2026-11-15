import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_providers.dart';

/// Música de fundo ORIGINAL, gerada pelo próprio código (nada de arquivo mp3,
/// então não tem direitos autorais e o projeto continua só com arquivos .dart).
///
/// É um tema curtinho estilo "desenho animado dos anos 30": baixo de ragtime
/// ("oom-pah"), acordes curtos e uma melodia saltitante em onda quadrada.
/// Dura uns 16 segundos e toca em loop.
class ChiptuneMusic {
  static const int sampleRate = 22050;
  static const double _bpm = 116;

  /// [baixo, nota1, nota2, nota3] em números MIDI (60 = Dó central).
  static const List<List<int>> _bars = [
    [36, 60, 64, 67], // Dó
    [33, 57, 60, 64], // Lá menor
    [41, 53, 57, 60], // Fá
    [43, 55, 59, 62], // Sol
    [36, 60, 64, 67], // Dó
    [33, 57, 60, 64], // Lá menor
    [38, 57, 62, 65], // Ré menor
    [43, 55, 59, 62], // Sol
  ];

  /// Qual nota do acorde (1 a 3) a melodia toca em cada colcheia. -1 = pausa.
  static const List<List<int>> _leadPatterns = [
    [3, 2, 1, 2, 3, -1, 2, -1],
    [2, 3, 2, 1, 3, 2, 1, -1],
  ];

  static double _hz(int midi) => 440.0 * math.pow(2.0, (midi - 69) / 12.0);

  // 0 = pulso (melodia), 1 = quadrada (acordes), 2 = triângulo (baixo)
  static double _osc(int wave, double phase) {
    switch (wave) {
      case 0:
        return phase < 0.25 ? 1.0 : -1.0;
      case 1:
        return phase < 0.5 ? 1.0 : -1.0;
      default:
        return 4 * (phase - 0.5).abs() - 1;
    }
  }

  /// Monta o áudio inteiro e devolve os bytes de um arquivo WAV.
  static Uint8List buildWav() {
    final stepLen = (60.0 / _bpm / 2 * sampleRate).round(); // uma colcheia
    final totalSteps = _bars.length * 8;
    final buf = Float64List(stepLen * totalSteps);

    void note(int startStep, int steps, int midi, int wave, double amp,
        double decay) {
      final f = _hz(midi);
      final start = startStep * stepLen;
      final len = steps * stepLen;
      for (var i = 0; i < len && start + i < buf.length; i++) {
        final t = i / sampleRate;
        final phase = (t * f) % 1.0;
        final attack = math.min(1.0, t / 0.004);
        final release = math.min(1.0, (len - i) / (sampleRate * 0.012));
        final env = attack * release * math.exp(-decay * t);
        buf[start + i] += _osc(wave, phase) * amp * env;
      }
    }

    for (var b = 0; b < _bars.length; b++) {
      final bar = _bars[b];
      final base = b * 8;

      // Baixo: tempo 1 na fundamental, tempo 3 na quinta.
      note(base, 2, bar[0] + 12, 2, 0.30, 3);
      note(base + 4, 2, bar[0] + 12 + 7, 2, 0.30, 3);

      // Acordes curtinhos nos tempos fracos ("pah").
      for (final s in const [2, 6]) {
        for (var k = 1; k <= 3; k++) {
          note(base + s, 1, bar[k], 1, 0.07, 14);
        }
      }

      // Melodia saltitante.
      final pattern = _leadPatterns[b % 2];
      for (var s = 0; s < 8; s++) {
        if (pattern[s] >= 0) {
          note(base + s, 1, bar[pattern[s]] + 12, 0, 0.16, 9);
        }
      }
    }

    // Float -> PCM de 16 bits + cabeçalho WAV.
    final dataLen = buf.length * 2;
    final bytes = ByteData(44 + dataLen);
    void tag(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        bytes.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    tag(0, 'RIFF');
    bytes.setUint32(4, 36 + dataLen, Endian.little);
    tag(8, 'WAVE');
    tag(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little); // PCM
    bytes.setUint16(22, 1, Endian.little); // mono
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    tag(36, 'data');
    bytes.setUint32(40, dataLen, Endian.little);

    const gain = 1.6; // a mistura pura é baixinha
    for (var i = 0; i < buf.length; i++) {
      final v = (buf[i] * gain).clamp(-0.95, 0.95).toDouble();
      bytes.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}

/// Liga e desliga a música. Quem decide é o interruptor das Configurações
/// (soundProvider), que começa DESLIGADO.
class MusicController {
  final AudioPlayer _player = AudioPlayer();
  Uint8List? _wav;
  bool _enabled = false;
  bool _playing = false;
  bool _starting = false;

  Future<void> setEnabled(bool on) async {
    _enabled = on;
    if (on) {
      await _start();
    } else {
      await _stop();
    }
  }

  /// O navegador só deixa o som tocar depois de um clique ou toque. Se a
  /// música estava ligada nas Configurações mas foi bloqueada ao abrir o
  /// app, o primeiro clique da usuária a liberta.
  Future<void> onUserGesture() async {
    if (_enabled && !_playing) await _start();
  }

  Future<void> _start() async {
    if (_starting) return;
    _starting = true;
    try {
      _wav ??= ChiptuneMusic.buildWav();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.35);
      try {
        await _player.play(BytesSource(_wav!, mimeType: 'audio/wav'));
      } catch (_) {
        // Plano B: o mesmo áudio como "data URI".
        final uri = 'data:audio/wav;base64,${base64Encode(_wav!)}';
        await _player.play(UrlSource(uri));
      }
      _playing = true;
    } catch (_) {
      // Provavelmente o navegador bloqueou. Tenta de novo no próximo clique.
      _playing = false;
    } finally {
      _starting = false;
    }
  }

  Future<void> _stop() async {
    if (!_playing) return;
    try {
      await _player.stop();
    } catch (_) {}
    _playing = false;
  }

  void dispose() {
    _player.dispose();
  }
}

final musicProvider = Provider<MusicController>((ref) {
  final controller = MusicController();
  ref.onDispose(controller.dispose);
  ref.listen<bool>(
    soundProvider,
    (_, on) => controller.setEnabled(on),
    fireImmediately: true,
  );
  return controller;
});
