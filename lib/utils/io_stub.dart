/// Stub implementations of dart:io classes for web compilation.
/// On native platforms, this file is never used — dart:io is imported instead.
/// On web, these stubs satisfy the compiler but should never be called
/// (all web code paths should be guarded with kIsWeb checks).

// ignore_for_file: avoid_unused_constructor_parameters

import 'dart:typed_data';

class File {
  final String path;
  File(this.path);

  Future<bool> exists() async => false;
  bool existsSync() => false;
  Future<Uint8List> readAsBytes() async => Uint8List(0);
  Future<String> readAsString() async => '';
  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) async => this;
  Future<File> writeAsString(String content, {bool flush = false}) async => this;
  Future<File> copy(String newPath) async => File(newPath);
  Future<void> delete({bool recursive = false}) async {}
  int lengthSync() => 0;
  Future<int> length() async => 0;
  Directory get parent {
    final idx = path.lastIndexOf('/');
    return Directory(idx >= 0 ? path.substring(0, idx) : '.');
  }
}

class Directory {
  final String path;
  Directory(this.path);

  Future<bool> exists() async => false;
  bool existsSync() => false;
  Future<Directory> create({bool recursive = false}) async => this;
}

class SocketException implements Exception {
  final String message;
  const SocketException(this.message);
  @override
  String toString() => 'SocketException: $message';
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;
  static bool get isFuchsia => false;
  static String get operatingSystem => 'web';
}
