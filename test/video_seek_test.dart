import 'package:flutter_test/flutter_test.dart';
import 'package:new_graket_acadimy/core/functions/video_seek.dart';

void main() {
  group('clamped video seek target', () {
    test('moves backward and forward by the requested offset', () {
      expect(
        clampedVideoSeekTarget(
          currentPosition: const Duration(seconds: 30),
          offset: const Duration(seconds: -10),
          totalDuration: const Duration(minutes: 1),
        ),
        const Duration(seconds: 20),
      );
      expect(
        clampedVideoSeekTarget(
          currentPosition: const Duration(seconds: 30),
          offset: const Duration(seconds: 10),
          totalDuration: const Duration(minutes: 1),
        ),
        const Duration(seconds: 40),
      );
    });

    test('never seeks before the beginning', () {
      expect(
        clampedVideoSeekTarget(
          currentPosition: const Duration(seconds: 4),
          offset: const Duration(seconds: -10),
          totalDuration: const Duration(minutes: 1),
        ),
        Duration.zero,
      );
    });

    test('never seeks beyond the video duration', () {
      expect(
        clampedVideoSeekTarget(
          currentPosition: const Duration(seconds: 56),
          offset: const Duration(seconds: 10),
          totalDuration: const Duration(minutes: 1),
        ),
        const Duration(minutes: 1),
      );
    });

    test('repeated taps keep using the previously clamped position', () {
      var position = const Duration(seconds: 8);
      for (var i = 0; i < 3; i++) {
        position = clampedVideoSeekTarget(
          currentPosition: position,
          offset: const Duration(seconds: -10),
          totalDuration: const Duration(minutes: 1),
        );
      }

      expect(position, Duration.zero);
    });
  });
}
