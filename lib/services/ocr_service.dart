import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final _textRecognizer = TextRecognizer();
  final _imagePicker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleFromGallery() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    return images.map((img) => File(img.path)).toList();
  }

  /// Extract text from image file
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Extract text from multiple images
  Future<String> extractTextFromMultiple(List<File> images) async {
    final buffer = StringBuffer();

    for (final image in images) {
      final text = await extractText(image);
      buffer.writeln(text);
      buffer.writeln(); // Add spacing between pages
    }

    return buffer.toString();
  }

  void dispose() {
    _textRecognizer.close();
  }
}