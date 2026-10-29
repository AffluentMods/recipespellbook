import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:recipespellbook/services/image_service.dart';

void main() {
  test('re-encoded photos keep their rotation but lose GPS and other EXIF', () async {
    // A 40x20 photo the camera stored sideways (orientation 6 = rotate 90°),
    // with a location and a device model in its EXIF.
    final photo = img.Image(width: 40, height: 20);
    img.fill(photo, color: img.ColorRgb8(200, 120, 40));
    photo.exif.imageIfd.orientation = 6;
    photo.exif.imageIfd['Model'] = img.IfdValueAscii('Test Phone');
    photo.exif.gpsIfd['GPSLatitudeRef'] = img.IfdValueAscii('N');
    final bytes = img.encodeJpg(photo);
    expect(img.decodeJpg(bytes)!.exif.gpsIfd.isEmpty, isFalse, reason: 'fixture has GPS');

    final out = await ImageService.compressImageBytes(bytes);

    final decoded = img.decodeJpg(out!)!;
    expect(decoded.exif.isEmpty, isTrue);
    expect(decoded.width, 20);
    expect(decoded.height, 40);
  });
}
