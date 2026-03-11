import 'dart:io';
import 'dart:typed_data';

/// Decodes gzip-compressed bytes using the native `dart:io` [GZipCodec].
///
/// This is used on platforms where `dart:io` is available (Flutter mobile,
/// desktop, Dart CLI/server) for maximum performance.
Uint8List decodeGzip(List<int> bytes) {
  return Uint8List.fromList(gzip.decode(bytes));
}
