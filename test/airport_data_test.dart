import 'package:airport_data/airport_data.dart';
import 'package:test/test.dart';

void main() {
  // ========================================================================
  // Core Search Functions
  // ========================================================================

  group('getAirportByIata', () {
    test('should retrieve airport data for a valid IATA code', () {
      final airports = AirportData.getAirportByIata('LHR');
      expect(airports.first.iata, equals('LHR'));
      expect(airports.first.airport, contains('Heathrow'));
    });
  });

  group('getAirportByIcao', () {
    test('should retrieve airport data for a valid ICAO code', () {
      final airports = AirportData.getAirportByIcao('EGLL');
      expect(airports.first.icao, equals('EGLL'));
      expect(airports.first.airport, contains('Heathrow'));
    });
  });

  group('getAirportByCountryCode', () {
    test('should retrieve all airports for a given country code', () {
      final airports = AirportData.getAirportByCountryCode('US');
      expect(airports.length, greaterThan(100));
      expect(airports.first.countryCode, equals('US'));
    });
  });

  group('getAirportByContinent', () {
    test('should retrieve all airports for a given continent code', () {
      final airports = AirportData.getAirportByContinent('EU');
      expect(airports.length, greaterThan(100));
      expect(airports.every((a) => a.continent == 'EU'), isTrue);
    });
  });

  // ========================================================================
  // Geographic Functions
  // ========================================================================

  group('findNearbyAirports', () {
    test('should find airports within a given radius', () {
      const lat = 51.5074;
      const lon = -0.1278;
      final airports = AirportData.findNearbyAirports(lat, lon, 50);
      expect(airports.length, greaterThanOrEqualTo(1));
      expect(airports.any((a) => a.iata == 'LHR'), isTrue);
    });
  });

  group('calculateDistance', () {
    test(
      'should calculate the distance between two airports using IATA codes',
      () {
        final distance = AirportData.calculateDistance('LHR', 'JFK');
        expect(distance, closeTo(5541, 5));
      },
    );
  });

  // ========================================================================
  // Filtering Functions
  // ========================================================================

  group('getAirportsByType', () {
    test('should retrieve all large airports', () {
      final airports = AirportData.getAirportsByType('large_airport');
      expect(airports.length, greaterThan(10));
      expect(airports.every((a) => a.type == 'large_airport'), isTrue);
    });

    test('should retrieve all medium airports', () {
      final airports = AirportData.getAirportsByType('medium_airport');
      expect(airports.length, greaterThan(10));
      expect(airports.every((a) => a.type == 'medium_airport'), isTrue);
    });

    test('should retrieve all airports when searching for "airport"', () {
      final airports = AirportData.getAirportsByType('airport');
      expect(airports.length, greaterThan(50));
      expect(airports.every((a) => a.type.contains('airport')), isTrue);
    });

    test('should handle different airport types', () {
      final heliports = AirportData.getAirportsByType('heliport');
      expect(heliports, isA<List<Airport>>());
      if (heliports.isNotEmpty) {
        expect(heliports.every((a) => a.type == 'heliport'), isTrue);
      }

      final seaplaneBases = AirportData.getAirportsByType('seaplane_base');
      expect(seaplaneBases, isA<List<Airport>>());
      if (seaplaneBases.isNotEmpty) {
        expect(seaplaneBases.every((a) => a.type == 'seaplane_base'), isTrue);
      }
    });

    test('should handle case-insensitive searches', () {
      final upperCase = AirportData.getAirportsByType('LARGE_AIRPORT');
      final lowerCase = AirportData.getAirportsByType('large_airport');
      expect(upperCase.length, equals(lowerCase.length));
      expect(upperCase.length, greaterThan(0));
    });

    test('should return empty list for non-existent type', () {
      final airports = AirportData.getAirportsByType('nonexistent_type');
      expect(airports.length, equals(0));
    });
  });

  group('getAirportsByTimezone', () {
    test('should find all airports within a specific timezone', () {
      final airports = AirportData.getAirportsByTimezone('Europe/London');
      expect(airports.length, greaterThan(10));
      expect(airports.every((a) => a.time == 'Europe/London'), isTrue);
    });
  });

  // ========================================================================
  // Advanced Functions
  // ========================================================================

  group('getAutocompleteSuggestions', () {
    test('should return suggestions based on airport name', () {
      final suggestions = AirportData.getAutocompleteSuggestions('London');
      expect(suggestions.length, greaterThan(0));
      expect(suggestions.length, lessThanOrEqualTo(10));
      expect(suggestions.any((a) => a.iata == 'LHR'), isTrue);
    });
  });

  group('findAirports (Advanced Filtering)', () {
    test('should find airports with multiple matching criteria', () {
      final airports = AirportData.findAirports(
        const AirportFilter(countryCode: 'GB', type: 'airport'),
      );
      expect(airports.length, greaterThanOrEqualTo(0));
      expect(
        airports.every((a) =>
            a.countryCode == 'GB' && a.type.toLowerCase().contains('airport')),
        isTrue,
      );
    });

    test('should filter by scheduled service availability', () {
      final airportsWithService = AirportData.findAirports(
        const AirportFilter(hasScheduledService: true),
      );
      final airportsWithoutService = AirportData.findAirports(
        const AirportFilter(hasScheduledService: false),
      );

      expect(
        airportsWithService.length + airportsWithoutService.length,
        greaterThan(0),
      );

      if (airportsWithService.isNotEmpty) {
        expect(
          airportsWithService.every((a) => a.scheduledService == true),
          isTrue,
        );
      }

      if (airportsWithoutService.isNotEmpty) {
        expect(
          airportsWithoutService.every((a) => a.scheduledService == false),
          isTrue,
        );
      }
    });
  });

  group('getAirportLinks', () {
    test('should retrieve a map of all available external links', () {
      final links = AirportData.getAirportLinks('LHR');
      expect(links.wikipedia, contains('Heathrow_Airport'));
      expect(links.website, isNotNull);
    });

    test('should handle airports with missing links gracefully', () {
      final links = AirportData.getAirportLinks('HND');
      expect(links.wikipedia, contains('Tokyo_International_Airport'));
      expect(links.website, isNotNull);
    });
  });

  // ========================================================================
  // Statistical & Analytical Functions
  // ========================================================================

  group('getAirportStatsByCountry', () {
    test('should return comprehensive statistics for a country', () {
      final stats = AirportData.getAirportStatsByCountry('SG');
      expect(stats.total, greaterThan(0));
      expect(stats.byType, isNotEmpty);
      expect(stats.timezones, isA<List<String>>());
    });

    test('should calculate correct statistics for US airports', () {
      final stats = AirportData.getAirportStatsByCountry('US');
      expect(stats.total, greaterThan(1000));
      expect(stats.byType.containsKey('large_airport'), isTrue);
      expect(stats.byType['large_airport']!, greaterThan(0));
    });

    test('should throw error for invalid country code', () {
      expect(
        () => AirportData.getAirportStatsByCountry('XYZ'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('getAirportStatsByContinent', () {
    test('should return comprehensive statistics for a continent', () {
      final stats = AirportData.getAirportStatsByContinent('AS');
      expect(stats.total, greaterThan(100));
      expect(stats.byType, isNotEmpty);
      expect(stats.byCountry, isNotEmpty);
      expect(stats.byCountry.keys.length, greaterThan(10));
    });

    test('should include country breakdown', () {
      final stats = AirportData.getAirportStatsByContinent('EU');
      expect(stats.byCountry.containsKey('GB'), isTrue);
      expect(stats.byCountry.containsKey('FR'), isTrue);
      expect(stats.byCountry.containsKey('DE'), isTrue);
    });
  });

  group('getLargestAirportsByContinent', () {
    test('should return top airports by runway length', () {
      final airports = AirportData.getLargestAirportsByContinent(
        'AS',
        5,
        'runway',
      );
      expect(airports.length, lessThanOrEqualTo(5));
      expect(airports.length, greaterThan(0));
      // Check sorted by runway length descending
      for (var i = 0; i < airports.length - 1; i++) {
        final runway1 = int.tryParse(airports[i].runwayLength) ?? 0;
        final runway2 = int.tryParse(airports[i + 1].runwayLength) ?? 0;
        expect(runway1, greaterThanOrEqualTo(runway2));
      }
    });

    test('should return top airports by elevation', () {
      final airports = AirportData.getLargestAirportsByContinent(
        'SA',
        5,
        'elevation',
      );
      expect(airports.length, lessThanOrEqualTo(5));
      // Check sorted by elevation descending
      for (var i = 0; i < airports.length - 1; i++) {
        final elev1 = int.tryParse(airports[i].elevationFt) ?? 0;
        final elev2 = int.tryParse(airports[i + 1].elevationFt) ?? 0;
        expect(elev1, greaterThanOrEqualTo(elev2));
      }
    });

    test('should respect the limit parameter', () {
      final airports = AirportData.getLargestAirportsByContinent('EU', 3);
      expect(airports.length, lessThanOrEqualTo(3));
    });
  });

  // ========================================================================
  // Bulk Operations
  // ========================================================================

  group('getMultipleAirports', () {
    test('should fetch multiple airports by IATA codes', () {
      final airports = AirportData.getMultipleAirports(['SIN', 'LHR', 'JFK']);
      expect(airports.length, equals(3));
      expect(airports[0]!.iata, equals('SIN'));
      expect(airports[1]!.iata, equals('LHR'));
      expect(airports[2]!.iata, equals('JFK'));
    });

    test('should handle mix of IATA and ICAO codes', () {
      final airports = AirportData.getMultipleAirports(['SIN', 'EGLL', 'JFK']);
      expect(airports.length, equals(3));
      expect(airports.every((a) => a != null), isTrue);
    });

    test('should return null for invalid codes', () {
      final airports = AirportData.getMultipleAirports([
        'SIN',
        'INVALID',
        'LHR',
      ]);
      expect(airports.length, equals(3));
      expect(airports[0], isNotNull);
      expect(airports[1], isNull);
      expect(airports[2], isNotNull);
    });

    test('should handle empty list', () {
      final airports = AirportData.getMultipleAirports([]);
      expect(airports.length, equals(0));
    });
  });

  group('calculateDistanceMatrix', () {
    test('should calculate distance matrix for multiple airports', () {
      final matrix = AirportData.calculateDistanceMatrix(['SIN', 'LHR', 'JFK']);
      expect(matrix.airports.length, equals(3));

      // Check diagonal is zero
      expect(matrix.distances['SIN']!['SIN'], equals(0));
      expect(matrix.distances['LHR']!['LHR'], equals(0));
      expect(matrix.distances['JFK']!['JFK'], equals(0));

      // Check symmetry
      expect(
        matrix.distances['SIN']!['LHR'],
        equals(matrix.distances['LHR']!['SIN']),
      );
      expect(
        matrix.distances['SIN']!['JFK'],
        equals(matrix.distances['JFK']!['SIN']),
      );

      // Check reasonable distances
      expect(matrix.distances['SIN']!['LHR']!, greaterThan(5000));
      expect(matrix.distances['LHR']!['JFK']!, greaterThan(3000));
    });

    test('should throw error for less than 2 airports', () {
      expect(
        () => AirportData.calculateDistanceMatrix(['SIN']),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for invalid codes', () {
      expect(
        () => AirportData.calculateDistanceMatrix(['SIN', 'INVALID']),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('findNearestAirport', () {
    test('should find nearest airport to coordinates', () {
      final nearest = AirportData.findNearestAirport(1.35019, 103.994003);
      expect(nearest.distance, isNotNull);
      expect(nearest.iata, equals('SIN'));
      expect(nearest.distance!, lessThan(2));
    });

    test('should find nearest airport with type filter', () {
      final nearest = AirportData.findNearestAirport(
        51.5074,
        -0.1278,
        const AirportFilter(type: 'large_airport'),
      );
      expect(nearest, isNotNull);
      expect(nearest.type, equals('large_airport'));
      expect(nearest.distance, isNotNull);
    });

    test('should find nearest airport with type and country filters', () {
      final nearest = AirportData.findNearestAirport(
        40.7128,
        -74.0060,
        const AirportFilter(type: 'large_airport', countryCode: 'US'),
      );
      expect(nearest, isNotNull);
      expect(nearest.distance, isNotNull);
      expect(nearest.type, equals('large_airport'));
      expect(nearest.countryCode, equals('US'));
    });
  });

  // ========================================================================
  // Validation & Utilities
  // ========================================================================

  group('validateIataCode', () {
    test('should return true for valid IATA codes', () {
      expect(AirportData.validateIataCode('SIN'), isTrue);
      expect(AirportData.validateIataCode('LHR'), isTrue);
      expect(AirportData.validateIataCode('JFK'), isTrue);
    });

    test('should return false for invalid IATA codes', () {
      expect(AirportData.validateIataCode('XYZ'), isFalse);
      expect(AirportData.validateIataCode('ZZZ'), isFalse);
    });

    test('should return false for incorrect format', () {
      expect(AirportData.validateIataCode('ABCD'), isFalse);
      expect(AirportData.validateIataCode('AB'), isFalse);
      expect(AirportData.validateIataCode('abc'), isFalse);
      expect(AirportData.validateIataCode(''), isFalse);
    });
  });

  group('validateIcaoCode', () {
    test('should return true for valid ICAO codes', () {
      expect(AirportData.validateIcaoCode('WSSS'), isTrue);
      expect(AirportData.validateIcaoCode('EGLL'), isTrue);
      expect(AirportData.validateIcaoCode('KJFK'), isTrue);
    });

    test('should return false for invalid ICAO codes', () {
      expect(AirportData.validateIcaoCode('XXXX'), isFalse);
      expect(AirportData.validateIcaoCode('ZZZ0'), isFalse);
    });

    test('should return false for incorrect format', () {
      expect(AirportData.validateIcaoCode('ABC'), isFalse);
      expect(AirportData.validateIcaoCode('ABCDE'), isFalse);
      expect(AirportData.validateIcaoCode('abcd'), isFalse);
      expect(AirportData.validateIcaoCode(''), isFalse);
    });
  });

  group('getAirportCount', () {
    test('should return total count of all airports', () {
      final count = AirportData.getAirportCount();
      expect(count, greaterThan(5000));
    });

    test('should return count with type filter', () {
      final largeCount = AirportData.getAirportCount(
        const AirportFilter(type: 'large_airport'),
      );
      final totalCount = AirportData.getAirportCount();
      expect(largeCount, greaterThan(0));
      expect(largeCount, lessThan(totalCount));
    });

    test('should return count with country filter', () {
      final usCount = AirportData.getAirportCount(
        const AirportFilter(countryCode: 'US'),
      );
      expect(usCount, greaterThan(1000));
    });

    test('should return count with multiple filters', () {
      final count = AirportData.getAirportCount(
        const AirportFilter(countryCode: 'US', type: 'large_airport'),
      );
      expect(count, greaterThan(0));
      expect(count, lessThan(200));
    });
  });

  group('isAirportOperational', () {
    test('should return true for operational airports', () {
      expect(AirportData.isAirportOperational('SIN'), isTrue);
      expect(AirportData.isAirportOperational('LHR'), isTrue);
      expect(AirportData.isAirportOperational('JFK'), isTrue);
    });

    test('should work with both IATA and ICAO codes', () {
      expect(AirportData.isAirportOperational('SIN'), isTrue);
      expect(AirportData.isAirportOperational('WSSS'), isTrue);
    });

    test('should throw error for invalid airport code', () {
      expect(
        () => AirportData.isAirportOperational('INVALID'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
