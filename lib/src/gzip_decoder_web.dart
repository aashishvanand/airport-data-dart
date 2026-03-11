import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Decodes gzip-compressed bytes using the pure-Dart implementation
/// from `package:archive`.
///
/// This is used on web platforms where `dart:io` is not available.
/// The `archive` package internally uses a full Dart implementation of
/// the DEFLATE algorithm, so no native code or FFI is required.
Uint8List decodeGzip(List<int> bytes) {
  return Uint8List.fromList(const GZipDecoder().decodeBytes(bytes));
}
