/// Represents an airport with all its associated data.
class Airport {
  /// Creates an [Airport] instance.
  const Airport({
    required this.iata,
    required this.icao,
    required this.time,
    required this.utc,
    required this.countryCode,
    required this.continent,
    required this.airport,
    required this.latitude,
    required this.longitude,
    required this.elevationFt,
    required this.type,
    required this.scheduledService,
    required this.wikipedia,
    required this.website,
    required this.runwayLength,
    required this.flightradar24Url,
    required this.radarboxUrl,
    required this.flightawareUrl,
    this.distance,
  });

  /// Creates an [Airport] from a JSON map.
  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iata: (json['iata'] ?? '').toString(),
      icao: (json['icao'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      utc: (json['utc'] is num) ? json['utc'] as num : 0,
      countryCode: (json['country_code'] ?? '').toString(),
      continent: (json['continent'] ?? '').toString(),
      airport: (json['airport'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      elevationFt: (json['elevation_ft'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      scheduledService: _toBool(json['scheduled_service']),
      wikipedia: (json['wikipedia'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      runwayLength: (json['runway_length'] ?? '').toString(),
      flightradar24Url: (json['flightradar24_url'] ?? '').toString(),
      radarboxUrl: (json['radarbox_url'] ?? '').toString(),
      flightawareUrl: (json['flightaware_url'] ?? '').toString(),
    );
  }

  /// 3-letter IATA code (may be empty for some airports).
  final String iata;

  /// 4-letter ICAO code.
  final String icao;

  /// Timezone identifier (e.g., "Asia/Singapore").
  final String time;

  /// UTC offset in hours.
  final num utc;

  /// 2-letter ISO country code.
  final String countryCode;

  /// 2-letter continent code (AS, EU, NA, SA, AF, OC, AN).
  final String continent;

  /// Full airport name.
  final String airport;

  /// Latitude coordinate.
  final double latitude;

  /// Longitude coordinate.
  final double longitude;

  /// Elevation in feet (may be empty string in source data).
  final String elevationFt;

  /// Airport type (large_airport, medium_airport, small_airport, heliport, seaplane_base).
  final String type;

  /// Whether the airport has scheduled commercial service.
  final bool scheduledService;

  /// Wikipedia URL for the airport.
  final String wikipedia;

  /// Official airport website URL.
  final String website;

  /// Longest runway length in feet (may be empty string in source data).
  final String runwayLength;

  /// FlightRadar24 tracking URL.
  final String flightradar24Url;

  /// RadarBox tracking URL.
  final String radarboxUrl;

  /// FlightAware tracking URL.
  final String flightawareUrl;

  /// Optional distance field populated by proximity searches.
  final double? distance;

  /// Creates a copy of this airport with an optional distance field.
  Airport copyWithDistance(double distance) {
    return Airport(
      iata: iata,
      icao: icao,
      time: time,
      utc: utc,
      countryCode: countryCode,
      continent: continent,
      airport: airport,
      latitude: latitude,
      longitude: longitude,
      elevationFt: elevationFt,
      type: type,
      scheduledService: scheduledService,
      wikipedia: wikipedia,
      website: website,
      runwayLength: runwayLength,
      flightradar24Url: flightradar24Url,
      radarboxUrl: radarboxUrl,
      flightawareUrl: flightawareUrl,
      distance: distance,
    );
  }

  /// Converts this airport to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'iata': iata,
      'icao': icao,
      'time': time,
      'utc': utc,
      'country_code': countryCode,
      'continent': continent,
      'airport': airport,
      'latitude': latitude,
      'longitude': longitude,
      'elevation_ft': elevationFt,
      'type': type,
      'scheduled_service': scheduledService,
      'wikipedia': wikipedia,
      'website': website,
      'runway_length': runwayLength,
      'flightradar24_url': flightradar24Url,
      'radarbox_url': radarboxUrl,
      'flightaware_url': flightawareUrl,
    };
    if (distance != null) {
      map['distance'] = distance;
    }
    return map;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toUpperCase() == 'TRUE' || value.toLowerCase() == 'yes';
    }
    return false;
  }

  @override
  String toString() => 'Airport($iata/$icao: $airport)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Airport &&
          runtimeType == other.runtimeType &&
          icao == other.icao;

  @override
  int get hashCode => icao.hashCode;
}
