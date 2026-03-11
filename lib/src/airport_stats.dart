/// Statistics about airports in a country.
class AirportCountryStats {
  const AirportCountryStats({
    required this.total,
    required this.byType,
    required this.withScheduledService,
    required this.averageRunwayLength,
    required this.averageElevation,
    required this.timezones,
  });

  /// Total number of airports.
  final int total;

  /// Breakdown of airports by type.
  final Map<String, int> byType;

  /// Number of airports with scheduled commercial service.
  final int withScheduledService;

  /// Average runway length in feet across all airports (with data).
  final double averageRunwayLength;

  /// Average elevation in feet across all airports (with data).
  final double averageElevation;

  /// List of unique timezones represented.
  final List<String> timezones;

  Map<String, dynamic> toJson() => {
        'total': total,
        'byType': byType,
        'withScheduledService': withScheduledService,
        'averageRunwayLength': averageRunwayLength,
        'averageElevation': averageElevation,
        'timezones': timezones,
      };
}

/// Statistics about airports on a continent.
class AirportContinentStats {
  const AirportContinentStats({
    required this.total,
    required this.byType,
    required this.byCountry,
    required this.withScheduledService,
    required this.averageRunwayLength,
    required this.averageElevation,
    required this.timezones,
  });

  /// Total number of airports.
  final int total;

  /// Breakdown of airports by type.
  final Map<String, int> byType;

  /// Breakdown of airport count by country code.
  final Map<String, int> byCountry;

  /// Number of airports with scheduled commercial service.
  final int withScheduledService;

  /// Average runway length in feet across all airports (with data).
  final double averageRunwayLength;

  /// Average elevation in feet across all airports (with data).
  final double averageElevation;

  /// List of unique timezones represented.
  final List<String> timezones;

  Map<String, dynamic> toJson() => {
        'total': total,
        'byType': byType,
        'byCountry': byCountry,
        'withScheduledService': withScheduledService,
        'averageRunwayLength': averageRunwayLength,
        'averageElevation': averageElevation,
        'timezones': timezones,
      };
}

/// External links associated with an airport.
class AirportLinks {
  const AirportLinks({
    this.website,
    this.wikipedia,
    this.flightradar24,
    this.radarbox,
    this.flightaware,
  });

  final String? website;
  final String? wikipedia;
  final String? flightradar24;
  final String? radarbox;
  final String? flightaware;

  Map<String, String?> toJson() => {
        'website': website,
        'wikipedia': wikipedia,
        'flightradar24': flightradar24,
        'radarbox': radarbox,
        'flightaware': flightaware,
      };
}

/// Result of a distance matrix calculation.
class DistanceMatrix {
  const DistanceMatrix({
    required this.airports,
    required this.distances,
  });

  /// Information about each airport in the matrix.
  final List<DistanceMatrixAirport> airports;

  /// Distance map: distances[code1][code2] = distance in km.
  final Map<String, Map<String, double>> distances;

  Map<String, dynamic> toJson() => {
        'airports': airports.map((a) => a.toJson()).toList(),
        'distances': distances,
      };
}

/// Airport info used in distance matrix results.
class DistanceMatrixAirport {
  const DistanceMatrixAirport({
    required this.code,
    required this.name,
    required this.iata,
    required this.icao,
  });

  final String code;
  final String name;
  final String iata;
  final String icao;

  Map<String, String> toJson() => {
        'code': code,
        'name': name,
        'iata': iata,
        'icao': icao,
      };
}

/// Filters for advanced airport search.
class AirportFilter {
  const AirportFilter({
    this.countryCode,
    this.continent,
    this.type,
    this.hasScheduledService,
    this.minRunwayFt,
  });

  final String? countryCode;
  final String? continent;
  final String? type;
  final bool? hasScheduledService;
  final int? minRunwayFt;
}
