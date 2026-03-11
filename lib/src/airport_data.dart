import 'dart:math';

import 'airport.dart';
import 'airport_stats.dart';
import 'data_loader.dart';

/// Main class providing all airport data lookup and analysis functions.
class AirportData {
  // =========================================================================
  // Core Search Functions
  // =========================================================================

  /// Finds an airport by its 3-letter IATA code.
  ///
  /// Returns a list containing the matching airport, or throws if not found.
  /// The IATA code is case-insensitive.
  ///
  /// ```dart
  /// final airports = AirportData.getAirportByIata('LHR');
  /// print(airports.first.airport); // "London Heathrow Airport"
  /// ```
  static List<Airport> getAirportByIata(String iataCode) {
    if (iataCode.isEmpty) {
      throw ArgumentError('IATA code cannot be empty');
    }

    final code = iataCode.toUpperCase();
    final airport = DataLoader.iataIndex[code];

    if (airport == null) {
      throw StateError('No data found for IATA code: $iataCode');
    }

    return [airport];
  }

  /// Finds an airport by its 4-character ICAO code.
  ///
  /// Returns a list containing the matching airport, or throws if not found.
  /// The ICAO code is case-insensitive.
  ///
  /// ```dart
  /// final airports = AirportData.getAirportByIcao('EGLL');
  /// print(airports.first.airport); // "London Heathrow Airport"
  /// ```
  static List<Airport> getAirportByIcao(String icaoCode) {
    if (icaoCode.isEmpty) {
      throw ArgumentError('ICAO code cannot be empty');
    }

    final code = icaoCode.toUpperCase();
    final airport = DataLoader.icaoIndex[code];

    if (airport == null) {
      throw StateError('No data found for ICAO code: $icaoCode');
    }

    return [airport];
  }

  /// Searches for airports by name (case-insensitive, minimum 2 characters).
  ///
  /// Returns all airports whose name contains the query string.
  ///
  /// ```dart
  /// final airports = AirportData.searchByName('Heathrow');
  /// ```
  static List<Airport> searchByName(String query) {
    if (query.length < 2) {
      throw ArgumentError('Search query must be at least 2 characters');
    }

    final lowerQuery = query.toLowerCase();
    final airports = DataLoader.loadAirports();

    return airports
        .where((a) => a.airport.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // =========================================================================
  // Geographic Functions
  // =========================================================================

  /// Finds airports within a specified radius of given coordinates.
  ///
  /// [lat] and [lon] are the center coordinates.
  /// [radiusKm] is the search radius in kilometers.
  ///
  /// Returns airports sorted by distance (nearest first), each with a
  /// [distance] field populated.
  ///
  /// ```dart
  /// final nearby = AirportData.findNearbyAirports(51.5074, -0.1278, 100);
  /// ```
  static List<Airport> findNearbyAirports(
    double lat,
    double lon,
    double radiusKm,
  ) {
    final airports = DataLoader.loadAirports();
    final results = <Airport>[];

    for (final airport in airports) {
      final dist = _haversineDistance(
        lat,
        lon,
        airport.latitude,
        airport.longitude,
      );
      if (dist <= radiusKm) {
        results.add(
          airport.copyWithDistance(double.parse(dist.toStringAsFixed(2))),
        );
      }
    }

    results.sort((a, b) => a.distance!.compareTo(b.distance!));
    return results;
  }

  /// Calculates the great-circle distance between two airports.
  ///
  /// Accepts either IATA or ICAO codes. Returns distance in kilometers.
  ///
  /// ```dart
  /// final distance = AirportData.calculateDistance('LHR', 'JFK');
  /// print(distance); // approximately 5541
  /// ```
  static double calculateDistance(String code1, String code2) {
    final airport1 = _resolveAirport(code1);
    final airport2 = _resolveAirport(code2);

    if (airport1 == null) {
      throw ArgumentError('Airport not found for code: $code1');
    }
    if (airport2 == null) {
      throw ArgumentError('Airport not found for code: $code2');
    }

    return _haversineDistance(
      airport1.latitude,
      airport1.longitude,
      airport2.latitude,
      airport2.longitude,
    );
  }

  // =========================================================================
  // Filtering Functions
  // =========================================================================

  /// Finds all airports in a specific country.
  ///
  /// [countryCode] is a 2-letter ISO country code (case-insensitive).
  ///
  /// ```dart
  /// final usAirports = AirportData.getAirportByCountryCode('US');
  /// ```
  static List<Airport> getAirportByCountryCode(String countryCode) {
    if (countryCode.isEmpty) {
      throw ArgumentError('Country code cannot be empty');
    }

    final code = countryCode.toUpperCase();
    final airports = DataLoader.loadAirports();

    return airports.where((a) => a.countryCode == code).toList();
  }

  /// Finds all airports on a specific continent.
  ///
  /// [continentCode] is a 2-letter continent code: AS, EU, NA, SA, AF, OC, AN.
  ///
  /// ```dart
  /// final asianAirports = AirportData.getAirportByContinent('AS');
  /// ```
  static List<Airport> getAirportByContinent(String continentCode) {
    if (continentCode.isEmpty) {
      throw ArgumentError('Continent code cannot be empty');
    }

    final code = continentCode.toUpperCase();
    final airports = DataLoader.loadAirports();

    return airports.where((a) => a.continent == code).toList();
  }

  /// Finds airports by their type.
  ///
  /// Available types: large_airport, medium_airport, small_airport,
  /// heliport, seaplane_base.
  ///
  /// Using 'airport' as the type returns large, medium, and small airports.
  /// The search is case-insensitive.
  ///
  /// ```dart
  /// final largeAirports = AirportData.getAirportsByType('large_airport');
  /// final allAirports = AirportData.getAirportsByType('airport');
  /// ```
  static List<Airport> getAirportsByType(String type) {
    final lowerType = type.toLowerCase();
    final airports = DataLoader.loadAirports();

    if (lowerType == 'airport') {
      return airports
          .where((a) => a.type.toLowerCase().contains('airport'))
          .toList();
    }

    return airports.where((a) => a.type.toLowerCase() == lowerType).toList();
  }

  /// Finds all airports within a specific timezone.
  ///
  /// ```dart
  /// final londonAirports = AirportData.getAirportsByTimezone('Europe/London');
  /// ```
  static List<Airport> getAirportsByTimezone(String timezone) {
    if (timezone.isEmpty) {
      throw ArgumentError('Timezone cannot be empty');
    }

    final airports = DataLoader.loadAirports();
    return airports.where((a) => a.time == timezone).toList();
  }

  // =========================================================================
  // Advanced Functions
  // =========================================================================

  /// Finds airports matching multiple criteria.
  ///
  /// Supported filter keys:
  /// - `country_code`: 2-letter country code
  /// - `continent`: 2-letter continent code
  /// - `type`: airport type (or 'airport' for all airport types)
  /// - `has_scheduled_service`: bool
  /// - `min_runway_ft`: minimum runway length in feet
  ///
  /// ```dart
  /// final airports = AirportData.findAirports(AirportFilter(
  ///   countryCode: 'GB',
  ///   type: 'large_airport',
  ///   hasScheduledService: true,
  /// ));
  /// ```
  static List<Airport> findAirports(AirportFilter filters) {
    final airports = DataLoader.loadAirports();

    return airports.where((a) {
      if (filters.countryCode != null &&
          a.countryCode.toUpperCase() != filters.countryCode!.toUpperCase()) {
        return false;
      }

      if (filters.continent != null &&
          a.continent.toUpperCase() != filters.continent!.toUpperCase()) {
        return false;
      }

      if (filters.type != null) {
        final filterType = filters.type!.toLowerCase();
        if (filterType == 'airport') {
          if (!a.type.toLowerCase().contains('airport')) return false;
        } else {
          if (a.type.toLowerCase() != filterType) return false;
        }
      }

      if (filters.hasScheduledService != null) {
        if (a.scheduledService != filters.hasScheduledService!) return false;
      }

      if (filters.minRunwayFt != null) {
        final runway = int.tryParse(a.runwayLength) ?? 0;
        if (runway < filters.minRunwayFt!) return false;
      }

      return true;
    }).toList();
  }

  /// Provides autocomplete suggestions for search interfaces.
  ///
  /// Returns at most 10 airports matching the query in name or IATA code.
  /// Minimum query length is 1 character.
  ///
  /// ```dart
  /// final suggestions = AirportData.getAutocompleteSuggestions('Lon');
  /// ```
  static List<Airport> getAutocompleteSuggestions(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final airports = DataLoader.loadAirports();
    final results = <Airport>[];

    for (final airport in airports) {
      if (results.length >= 10) break;
      if (airport.airport.toLowerCase().contains(lowerQuery) ||
          airport.iata.toLowerCase().contains(lowerQuery)) {
        results.add(airport);
      }
    }

    return results;
  }

  /// Gets external links for an airport using IATA or ICAO code.
  ///
  /// Returns an [AirportLinks] object with available URLs.
  ///
  /// ```dart
  /// final links = AirportData.getAirportLinks('SIN');
  /// print(links.wikipedia);
  /// ```
  static AirportLinks getAirportLinks(String code) {
    final airport = _resolveAirport(code);

    if (airport == null) {
      throw ArgumentError('Airport not found for code: $code');
    }

    return AirportLinks(
      website: airport.website.isNotEmpty ? airport.website : null,
      wikipedia: airport.wikipedia.isNotEmpty ? airport.wikipedia : null,
      flightradar24: airport.flightradar24Url.isNotEmpty
          ? airport.flightradar24Url
          : null,
      radarbox: airport.radarboxUrl.isNotEmpty ? airport.radarboxUrl : null,
      flightaware: airport.flightawareUrl.isNotEmpty
          ? airport.flightawareUrl
          : null,
    );
  }

  // =========================================================================
  // Statistical & Analytical Functions
  // =========================================================================

  /// Gets comprehensive statistics about airports in a specific country.
  ///
  /// Throws if no airports are found for the given country code.
  ///
  /// ```dart
  /// final stats = AirportData.getAirportStatsByCountry('US');
  /// print(stats.total);
  /// print(stats.byType['large_airport']);
  /// ```
  static AirportCountryStats getAirportStatsByCountry(String countryCode) {
    final code = countryCode.toUpperCase();
    final airports = DataLoader.loadAirports()
        .where((a) => a.countryCode == code)
        .toList();

    if (airports.isEmpty) {
      throw StateError('No airports found for country code: $countryCode');
    }

    return _buildCountryStats(airports);
  }

  /// Gets comprehensive statistics about airports on a specific continent.
  ///
  /// Throws if no airports are found for the given continent code.
  ///
  /// ```dart
  /// final stats = AirportData.getAirportStatsByContinent('AS');
  /// print(stats.total);
  /// print(stats.byCountry);
  /// ```
  static AirportContinentStats getAirportStatsByContinent(
    String continentCode,
  ) {
    final code = continentCode.toUpperCase();
    final airports = DataLoader.loadAirports()
        .where((a) => a.continent == code)
        .toList();

    if (airports.isEmpty) {
      throw StateError('No airports found for continent code: $continentCode');
    }

    return _buildContinentStats(airports);
  }

  /// Gets the largest airports on a continent by runway length or elevation.
  ///
  /// [continentCode] is a 2-letter continent code.
  /// [limit] is the maximum number of results (default 10).
  /// [sortBy] is either 'runway' (default) or 'elevation'.
  ///
  /// ```dart
  /// final top5 = AirportData.getLargestAirportsByContinent('AS', 5, 'runway');
  /// ```
  static List<Airport> getLargestAirportsByContinent(
    String continentCode, [
    int limit = 10,
    String sortBy = 'runway',
  ]) {
    final code = continentCode.toUpperCase();
    final airports = DataLoader.loadAirports()
        .where((a) => a.continent == code)
        .toList();

    if (sortBy == 'elevation') {
      airports.sort((a, b) {
        final elevA = int.tryParse(a.elevationFt) ?? 0;
        final elevB = int.tryParse(b.elevationFt) ?? 0;
        return elevB.compareTo(elevA);
      });
    } else {
      airports.sort((a, b) {
        final runwayA = int.tryParse(a.runwayLength) ?? 0;
        final runwayB = int.tryParse(b.runwayLength) ?? 0;
        return runwayB.compareTo(runwayA);
      });
    }

    return airports.take(limit).toList();
  }

  // =========================================================================
  // Bulk Operations
  // =========================================================================

  /// Fetches multiple airports by their IATA or ICAO codes in one call.
  ///
  /// Returns a list of airports in the same order as the input codes.
  /// Returns `null` for codes that are not found.
  ///
  /// ```dart
  /// final airports = AirportData.getMultipleAirports(['SIN', 'LHR', 'JFK']);
  /// ```
  static List<Airport?> getMultipleAirports(List<String> codes) {
    if (codes.isEmpty) return [];

    // Ensure data is loaded
    DataLoader.loadAirports();

    return codes.map((code) => _resolveAirport(code)).toList();
  }

  /// Calculates distances between all pairs of airports in a list.
  ///
  /// Requires at least 2 valid airport codes.
  ///
  /// ```dart
  /// final matrix = AirportData.calculateDistanceMatrix(['SIN', 'LHR', 'JFK']);
  /// print(matrix.distances['SIN']!['LHR']);
  /// ```
  static DistanceMatrix calculateDistanceMatrix(List<String> codes) {
    if (codes.length < 2) {
      throw ArgumentError(
        'At least 2 airport codes are required for distance matrix',
      );
    }

    // Ensure data is loaded
    DataLoader.loadAirports();

    final resolvedAirports = <String, Airport>{};
    for (final code in codes) {
      final airport = _resolveAirport(code);
      if (airport == null) {
        throw ArgumentError('Airport not found for code: $code');
      }
      resolvedAirports[code] = airport;
    }

    final matrixAirports = codes.map((code) {
      final a = resolvedAirports[code]!;
      return DistanceMatrixAirport(
        code: code,
        name: a.airport,
        iata: a.iata,
        icao: a.icao,
      );
    }).toList();

    final distances = <String, Map<String, double>>{};
    for (final code1 in codes) {
      distances[code1] = {};
      for (final code2 in codes) {
        if (code1 == code2) {
          distances[code1]![code2] = 0;
        } else {
          final a1 = resolvedAirports[code1]!;
          final a2 = resolvedAirports[code2]!;
          final dist = _haversineDistance(
            a1.latitude,
            a1.longitude,
            a2.latitude,
            a2.longitude,
          );
          distances[code1]![code2] = double.parse(dist.toStringAsFixed(0));
        }
      }
    }

    return DistanceMatrix(airports: matrixAirports, distances: distances);
  }

  /// Finds the single nearest airport to given coordinates.
  ///
  /// Optionally filters by type and/or country code.
  /// Returns the airport with a [distance] field populated in km.
  ///
  /// ```dart
  /// final nearest = AirportData.findNearestAirport(1.35019, 103.994003);
  /// print(nearest.airport); // "Singapore Changi Airport"
  /// ```
  static Airport findNearestAirport(
    double lat,
    double lon, [
    AirportFilter? filters,
  ]) {
    var airports = DataLoader.loadAirports();

    if (filters != null) {
      airports = findAirports(filters);
    }

    if (airports.isEmpty) {
      throw StateError('No airports match the given filters');
    }

    Airport? nearest;
    double minDist = double.infinity;

    for (final airport in airports) {
      final dist = _haversineDistance(
        lat,
        lon,
        airport.latitude,
        airport.longitude,
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = airport;
      }
    }

    return nearest!.copyWithDistance(double.parse(minDist.toStringAsFixed(2)));
  }

  // =========================================================================
  // Validation & Utilities
  // =========================================================================

  /// Validates if an IATA code exists in the database.
  ///
  /// Returns `false` for codes that are not exactly 3 uppercase letters
  /// or that don't exist in the database.
  ///
  /// ```dart
  /// final isValid = AirportData.validateIataCode('SIN'); // true
  /// final isInvalid = AirportData.validateIataCode('XYZ'); // false
  /// ```
  static bool validateIataCode(String code) {
    if (code.length != 3) return false;
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) return false;

    return DataLoader.iataIndex.containsKey(code);
  }

  /// Validates if an ICAO code exists in the database.
  ///
  /// Returns `false` for codes that are not exactly 4 uppercase alphanumeric
  /// characters or that don't exist in the database.
  ///
  /// ```dart
  /// final isValid = AirportData.validateIcaoCode('WSSS'); // true
  /// ```
  static bool validateIcaoCode(String code) {
    if (code.length != 4) return false;
    if (!RegExp(r'^[A-Z0-9]{4}$').hasMatch(code)) return false;

    return DataLoader.icaoIndex.containsKey(code);
  }

  /// Gets the count of airports matching the given filters.
  ///
  /// If no filters are provided, returns the total count of all airports.
  ///
  /// ```dart
  /// final total = AirportData.getAirportCount();
  /// final usLarge = AirportData.getAirportCount(AirportFilter(
  ///   countryCode: 'US',
  ///   type: 'large_airport',
  /// ));
  /// ```
  static int getAirportCount([AirportFilter? filters]) {
    if (filters == null) {
      return DataLoader.loadAirports().length;
    }
    return findAirports(filters).length;
  }

  /// Checks if an airport has scheduled commercial service.
  ///
  /// Accepts either IATA or ICAO codes.
  ///
  /// ```dart
  /// final operational = AirportData.isAirportOperational('SIN'); // true
  /// ```
  static bool isAirportOperational(String code) {
    final airport = _resolveAirport(code);

    if (airport == null) {
      throw ArgumentError('Airport not found for code: $code');
    }

    return airport.scheduledService;
  }

  // =========================================================================
  // Private Helpers
  // =========================================================================

  /// Resolves an airport by trying IATA first, then ICAO.
  static Airport? _resolveAirport(String code) {
    if (code.isEmpty) return null;

    final upperCode = code.toUpperCase();

    // Ensure data is loaded
    DataLoader.loadAirports();

    // Try IATA first (3-letter codes)
    final byIata = DataLoader.iataIndex[upperCode];
    if (byIata != null) return byIata;

    // Try ICAO (4-letter codes)
    final byIcao = DataLoader.icaoIndex[upperCode];
    if (byIcao != null) return byIcao;

    return null;
  }

  /// Calculates the great-circle distance between two points using the
  /// Haversine formula.
  ///
  /// Returns distance in kilometers.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180);

  static AirportCountryStats _buildCountryStats(List<Airport> airports) {
    final byType = <String, int>{};
    var withScheduledService = 0;
    var totalRunway = 0.0;
    var runwayCount = 0;
    var totalElevation = 0.0;
    var elevationCount = 0;
    final timezoneSet = <String>{};

    for (final a in airports) {
      byType[a.type] = (byType[a.type] ?? 0) + 1;

      if (a.scheduledService) withScheduledService++;

      final runway = int.tryParse(a.runwayLength);
      if (runway != null && runway > 0) {
        totalRunway += runway;
        runwayCount++;
      }

      final elevation = int.tryParse(a.elevationFt);
      if (elevation != null) {
        totalElevation += elevation;
        elevationCount++;
      }

      if (a.time.isNotEmpty) {
        timezoneSet.add(a.time);
      }
    }

    return AirportCountryStats(
      total: airports.length,
      byType: byType,
      withScheduledService: withScheduledService,
      averageRunwayLength: runwayCount > 0
          ? double.parse((totalRunway / runwayCount).toStringAsFixed(0))
          : 0,
      averageElevation: elevationCount > 0
          ? double.parse((totalElevation / elevationCount).toStringAsFixed(0))
          : 0,
      timezones: timezoneSet.toList()..sort(),
    );
  }

  static AirportContinentStats _buildContinentStats(List<Airport> airports) {
    final byType = <String, int>{};
    final byCountry = <String, int>{};
    var withScheduledService = 0;
    var totalRunway = 0.0;
    var runwayCount = 0;
    var totalElevation = 0.0;
    var elevationCount = 0;
    final timezoneSet = <String>{};

    for (final a in airports) {
      byType[a.type] = (byType[a.type] ?? 0) + 1;
      byCountry[a.countryCode] = (byCountry[a.countryCode] ?? 0) + 1;

      if (a.scheduledService) withScheduledService++;

      final runway = int.tryParse(a.runwayLength);
      if (runway != null && runway > 0) {
        totalRunway += runway;
        runwayCount++;
      }

      final elevation = int.tryParse(a.elevationFt);
      if (elevation != null) {
        totalElevation += elevation;
        elevationCount++;
      }

      if (a.time.isNotEmpty) {
        timezoneSet.add(a.time);
      }
    }

    return AirportContinentStats(
      total: airports.length,
      byType: byType,
      byCountry: byCountry,
      withScheduledService: withScheduledService,
      averageRunwayLength: runwayCount > 0
          ? double.parse((totalRunway / runwayCount).toStringAsFixed(0))
          : 0,
      averageElevation: elevationCount > 0
          ? double.parse((totalElevation / elevationCount).toStringAsFixed(0))
          : 0,
      timezones: timezoneSet.toList()..sort(),
    );
  }
}
