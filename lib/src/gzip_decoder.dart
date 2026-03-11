// Platform-adaptive gzip decoder.
//
// On dart:io platforms (Flutter mobile, desktop, Dart CLI/server),
// this uses the native GZipCodec for maximum performance.
//
// On web platforms where dart:io is unavailable, this falls back
// to the pure-Dart implementation from package:archive.
export 'gzip_decoder_web.dart' if (dart.library.io) 'gzip_decoder_io.dart';
