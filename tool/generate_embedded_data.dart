// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Generates lib/src/airport_data_embedded.dart from data/airports.json.
///
/// Run this whenever the airport data is updated:
///   dart run tool/generate_embedded_data.dart
void main() {
  final jsonFile = File('data/airports.json');
  if (!jsonFile.existsSync()) {
    print('Error: data/airports.json not found.');
    print('Run this script from the package root directory.');
    exit(1);
  }

  print('Reading data/airports.json...');
  final jsonBytes = jsonFile.readAsBytesSync();
  print(
      '  JSON size: ${(jsonBytes.length / 1024 / 1024).toStringAsFixed(1)} MB');

  print('Compressing with gzip (level 9)...');
  final codec = GZipCodec(level: 9);
  final gzBytes = codec.encode(jsonBytes);
  print('  Compressed size: ${(gzBytes.length / 1024).toStringAsFixed(0)} KB');

  print('Encoding to base64...');
  final b64 = base64.encode(gzBytes);
  print('  Base64 length: ${b64.length} chars');

  // Split into chunks of 76 chars for readability
  final chunks = <String>[];
  for (var i = 0; i < b64.length; i += 76) {
    final end = (i + 76 < b64.length) ? i + 76 : b64.length;
    chunks.add("'${b64.substring(i, end)}'");
  }

  final sb = StringBuffer();
  sb.writeln('// GENERATED FILE - DO NOT EDIT');
  sb.writeln(
      '// This file contains gzip-compressed airport data encoded as base64.');
  sb.writeln('// Regenerate with: dart run tool/generate_embedded_data.dart');
  sb.writeln('');
  sb.writeln('/// Base64-encoded gzip-compressed airport JSON data.');
  sb.writeln('const airportDataBase64 =');
  for (var i = 0; i < chunks.length; i++) {
    if (i < chunks.length - 1) {
      sb.writeln('    ${chunks[i]}');
    } else {
      sb.writeln('    ${chunks[i]};');
    }
  }

  final outputFile = File('lib/src/airport_data_embedded.dart');
  outputFile.writeAsStringSync(sb.toString());
  print('Generated ${outputFile.path}');
  print('  ${chunks.length} lines of base64 data');
}
