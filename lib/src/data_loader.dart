import 'dart:convert';

import 'airport.dart';
import 'airport_data_embedded.dart';
import 'gzip_decoder.dart';

/// Loads airport data from the embedded compressed dataset.
///
/// Data is embedded as a base64-encoded gzip-compressed JSON string,
/// making this library work without requiring external data files.
///
/// On `dart:io` platforms (Flutter mobile, desktop, Dart CLI/server),
/// gzip decompression uses the native codec for maximum performance.
/// On web platforms, a pure-Dart fallback from `package:archive` is used.
class DataLoader {
  static List<Airport>? _cache;
  static Map<String, Airport>? _iataIndex;
  static Map<String, Airport>? _icaoIndex;

  /// Loads and returns all airports, using a cache after first load.
  static List<Airport> loadAirports() {
    if (_cache != null) return _cache!;

    // Decode base64 -> gzip bytes -> JSON string -> List
    final compressedBytes = base64.decode(airportDataBase64);
    final decompressedBytes = decodeGzip(compressedBytes);
    final jsonString = utf8.decode(decompressedBytes);
    final jsonList = json.decode(jsonString) as List<dynamic>;

    _cache = jsonList
        .map((e) => Airport.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    _buildIndices();
    return _cache!;
  }

  /// Returns the IATA index map for O(1) lookups.
  static Map<String, Airport> get iataIndex {
    if (_iataIndex == null) loadAirports();
    return _iataIndex!;
  }

  /// Returns the ICAO index map for O(1) lookups.
  static Map<String, Airport> get icaoIndex {
    if (_icaoIndex == null) loadAirports();
    return _icaoIndex!;
  }

  static void _buildIndices() {
    _iataIndex = {};
    _icaoIndex = {};
    for (final airport in _cache!) {
      if (airport.iata.isNotEmpty) {
        _iataIndex![airport.iata.toUpperCase()] = airport;
      }
      if (airport.icao.isNotEmpty) {
        _icaoIndex![airport.icao.toUpperCase()] = airport;
      }
    }
  }

  /// Clears the cached data (useful for testing).
  static void clearCache() {
    _cache = null;
    _iataIndex = null;
    _icaoIndex = null;
  }
}
