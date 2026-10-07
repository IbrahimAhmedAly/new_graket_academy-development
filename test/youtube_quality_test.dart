import 'package:flutter_test/flutter_test.dart';
import 'package:new_graket_acadimy/core/services/youtube_quality.dart';

void main() {
  group('youtube quality label', () {
    test('names HD levels by their line count', () {
      expect(YoutubeQuality.label('hd720'), '720p');
      expect(YoutubeQuality.label('hd1080'), '1080p');
      expect(YoutubeQuality.label('hd2160'), '2160p');
    });

    test('maps the named standard-definition levels', () {
      expect(YoutubeQuality.label('large'), '480p');
      expect(YoutubeQuality.label('medium'), '360p');
      expect(YoutubeQuality.label('small'), '240p');
      expect(YoutubeQuality.label('tiny'), '144p');
      expect(YoutubeQuality.label('highres'), '4320p');
    });

    test('labels auto and passes unknown levels through', () {
      expect(YoutubeQuality.label(YoutubeQuality.auto), 'Auto');
      expect(YoutubeQuality.label('ultra'), 'ultra');
    });
  });
}
