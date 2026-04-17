import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/utils/mime_utils.dart';

void main() {
  group('mimeTypeFromPath', () {
    test('.png → image/png', () {
      expect(mimeTypeFromPath('photo.png'), 'image/png');
    });

    test('.webp → image/webp', () {
      expect(mimeTypeFromPath('image.webp'), 'image/webp');
    });

    test('.gif → image/gif', () {
      expect(mimeTypeFromPath('animation.gif'), 'image/gif');
    });

    test('.heic → image/heic', () {
      expect(mimeTypeFromPath('photo.heic'), 'image/heic');
    });

    test('.heif → image/heic', () {
      expect(mimeTypeFromPath('photo.heif'), 'image/heic');
    });

    test('.jpg → image/jpeg (default)', () {
      expect(mimeTypeFromPath('photo.jpg'), 'image/jpeg');
    });

    test('.jpeg → image/jpeg (default)', () {
      expect(mimeTypeFromPath('photo.jpeg'), 'image/jpeg');
    });

    test('no extension → image/jpeg (default)', () {
      expect(mimeTypeFromPath('photo'), 'image/jpeg');
    });

    test('unknown extension → image/jpeg (default)', () {
      expect(mimeTypeFromPath('data.txt'), 'image/jpeg');
    });

    test('case insensitivity: .PNG → image/png', () {
      expect(mimeTypeFromPath('PHOTO.PNG'), 'image/png');
    });

    test('case insensitivity: .HEIC → image/heic', () {
      expect(mimeTypeFromPath('IMG_001.HEIC'), 'image/heic');
    });

    test('path with directories', () {
      expect(mimeTypeFromPath('/path/to/file.png'), 'image/png');
    });
  });
}
