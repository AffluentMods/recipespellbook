// Stub implementations of share_handler types for web compilation.

// ignore_for_file: avoid_unused_constructor_parameters

class SharedMedia {
  final List<SharedAttachment?>? attachments;
  final String? content;
  const SharedMedia({this.attachments, this.content});
}

class SharedAttachment {
  final String path;
  final SharedAttachmentType? type;
  const SharedAttachment({required this.path, this.type});
}

enum SharedAttachmentType { image, video, file }

class ShareHandlerPlatform {
  static final instance = ShareHandlerPlatform._();
  ShareHandlerPlatform._();
  Future<SharedMedia?> getInitialSharedMedia() async => null;
  Stream<SharedMedia> get sharedMediaStream => const Stream.empty();
}
