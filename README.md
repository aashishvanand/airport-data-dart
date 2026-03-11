# Airport Data Dart

A comprehensive Dart library for retrieving airport information by IATA codes, ICAO codes, and various other criteria. This library provides easy access to a large dataset of airports worldwide with detailed information including coordinates, timezone, type, and external links.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  airport_data:
    git:
      url: https://github.com/aashishvanand/airport-data-dart.git
```

## Platform Support

| Platform | Supported |
|---|---|
| Flutter Android | Yes |
| Flutter iOS | Yes |
| Flutter macOS | Yes |
| Flutter Windows | Yes |
| Flutter Linux | Yes |
| Flutter Web | Yes |
| Dart CLI / Server | Yes |

On `dart:io` platforms (mobile, desktop, CLI), gzip decompression uses the native codec for maximum performance. On web, a pure-Dart fallback from `package:archive` is used automatically — no configuration needed.

## Features

- Comprehensive airport database with worldwide coverage
- Works on all Flutter platforms including web
- Search by IATA codes, ICAO codes, country, continent, and more
- Geographic proximity search with customizable radius
- External links to Wikipedia, airport websites, and flight tracking services
- Distance calculation between airports
- Filter by airport type (large_airport, medium_airport, small_airport, heliport, seaplane_base)
- Timezone-based airport lookup
- Autocomplete suggestions for search interfaces
- Advanced multi-criteria filtering
- Statistical analysis by country and continent
- Bulk operations for multiple airports
- Code validation utilities
- Airport ranking by runway length and elevation

## Airport Data Structure

Each `Airport` object contains the following fields:

```dart
Airport(
  iata: 'SIN',                    // 3-letter IATA code
  icao: 'WSSS',                   // 4-letter ICAO code
  time: 'Asia/Singapore',         // Timezone identifier
  utc: 8,                         // UTC offset
  countryCode: 'SG',              // 2-letter country code
  continent: 'AS',                // 2-letter continent code (AS, EU, NA, SA, AF, OC, AN)
  airport: 'Singapore Changi Airport',  // Airport name
  latitude: 1.35019,              // Latitude coordinate
  longitude: 103.994003,          // Longitude coordinate
  elevationFt: '22',              // Elevation in feet
  type: 'large_airport',          // Airport type
  scheduledService: true,         // Has scheduled commercial service
  wikipedia: 'https://en.wikipedia.org/wiki/Singapore_Changi_Airport',
  website: 'https://www.changiairport.com',
  runwayLength: '13200',          // Longest runway in feet
  flightradar24Url: 'https://www.flightradar24.com/airport/SIN',
  radarboxUrl: 'https://www.radarbox.com/airport/WSSS',
  flightawareUrl: 'https://www.flightaware.com/live/airport/WSSS',
)
```

## Basic Usage

```dart
import 'package:airport_data/airport_data.dart';

// Get airport by IATA code
final airports = AirportData.getAirportByIata('SIN');
print(airports.first.airport); // "Singapore Changi Airport"

// Get airport by ICAO code
final airports = AirportData.getAirportByIcao('WSSS');
print(airports.first.countryCode); // "SG"

// Search airports by name
final airports = AirportData.searchByName('Singapore');
print(airports.length); // Multiple airports matching "Singapore"

// Find nearby airports (within 50km of coordinates)
final nearby = AirportData.findNearbyAirports(1.35019, 103.994003, 50);
print(nearby); // Airports near Singapore Changi
```

## API Reference

### Core Search Functions

#### `AirportData.getAirportByIata(String iataCode)`
Finds airports by their 3-letter IATA code.

```dart
final airports = AirportData.getAirportByIata('LHR');
// Returns list of airports with IATA code 'LHR'
```

#### `AirportData.getAirportByIcao(String icaoCode)`
Finds airports by their 4-character ICAO code.

```dart
final airports = AirportData.getAirportByIcao('EGLL');
// Returns list of airports with ICAO code 'EGLL'
```

#### `AirportData.searchByName(String query)`
Searches for airports by name (case-insensitive, minimum 2 characters).

```dart
final airports = AirportData.searchByName('Heathrow');
// Returns airports with 'Heathrow' in their name
```

### Geographic Functions

#### `AirportData.findNearbyAirports(double lat, double lon, double radiusKm)`
Finds airports within a specified radius of given coordinates.

```dart
final nearby = AirportData.findNearbyAirports(51.5074, -0.1278, 100);
// Returns airports within 100km of London coordinates
```

#### `AirportData.calculateDistance(String code1, String code2)`
Calculates the great-circle distance between two airports using IATA or ICAO codes.

```dart
final distance = AirportData.calculateDistance('LHR', 'JFK');
// Returns distance in kilometers (approximately 5541)
```

### Filtering Functions

#### `AirportData.getAirportByCountryCode(String countryCode)`
Finds all airports in a specific country.

```dart
final usAirports = AirportData.getAirportByCountryCode('US');
```

#### `AirportData.getAirportByContinent(String continentCode)`
Finds all airports on a specific continent.

```dart
final asianAirports = AirportData.getAirportByContinent('AS');
// Continent codes: AS, EU, NA, SA, AF, OC, AN
```

#### `AirportData.getAirportsByType(String type)`
Finds airports by their type.

```dart
final largeAirports = AirportData.getAirportsByType('large_airport');
// Available types: large_airport, medium_airport, small_airport, heliport, seaplane_base

// Convenience search for all airports
final allAirports = AirportData.getAirportsByType('airport');
// Returns large_airport, medium_airport, and small_airport
```

#### `AirportData.getAirportsByTimezone(String timezone)`
Finds all airports within a specific timezone.

```dart
final londonAirports = AirportData.getAirportsByTimezone('Europe/London');
```

### Advanced Functions

#### `AirportData.findAirports(AirportFilter filters)`
Finds airports matching multiple criteria.

```dart
// Find large airports in Great Britain with scheduled service
final airports = AirportData.findAirports(const AirportFilter(
  countryCode: 'GB',
  type: 'large_airport',
  hasScheduledService: true,
));

// Find airports with minimum runway length
final longRunwayAirports = AirportData.findAirports(const AirportFilter(
  minRunwayFt: 10000,
));
```

#### `AirportData.getAutocompleteSuggestions(String query)`
Provides autocomplete suggestions for search interfaces (returns max 10 results).

```dart
final suggestions = AirportData.getAutocompleteSuggestions('Lon');
// Returns up to 10 airports matching 'Lon' in name or IATA code
```

#### `AirportData.getAirportLinks(String code)`
Gets external links for an airport using IATA or ICAO code.

```dart
final links = AirportData.getAirportLinks('SIN');
// Returns AirportLinks with:
//   website, wikipedia, flightradar24, radarbox, flightaware
```

### Statistical & Analytical Functions

#### `AirportData.getAirportStatsByCountry(String countryCode)`
Gets comprehensive statistics about airports in a specific country.

```dart
final stats = AirportData.getAirportStatsByCountry('US');
print(stats.total);                  // Total airport count
print(stats.byType['large_airport']); // Count of large airports
print(stats.averageRunwayLength);     // Average runway length in feet
print(stats.timezones);               // List of timezones
```

#### `AirportData.getAirportStatsByContinent(String continentCode)`
Gets comprehensive statistics about airports on a specific continent.

```dart
final stats = AirportData.getAirportStatsByContinent('AS');
print(stats.total);
print(stats.byCountry); // Breakdown by country code
```

#### `AirportData.getLargestAirportsByContinent(String continentCode, [int limit, String sortBy])`
Gets the largest airports on a continent by runway length or elevation.

```dart
// Get top 5 airports in Asia by runway length
final airports = AirportData.getLargestAirportsByContinent('AS', 5, 'runway');

// Get top 10 airports in South America by elevation
final highAltitude = AirportData.getLargestAirportsByContinent('SA', 10, 'elevation');
```

### Bulk Operations

#### `AirportData.getMultipleAirports(List<String> codes)`
Fetches multiple airports by their IATA or ICAO codes in one call.

```dart
final airports = AirportData.getMultipleAirports(['SIN', 'LHR', 'JFK', 'WSSS']);
// Returns list of Airport? (null for codes not found)
```

#### `AirportData.calculateDistanceMatrix(List<String> codes)`
Calculates distances between all pairs of airports in a list.

```dart
final matrix = AirportData.calculateDistanceMatrix(['SIN', 'LHR', 'JFK']);
print(matrix.distances['SIN']!['LHR']); // Distance in km
print(matrix.distances['LHR']!['JFK']); // Distance in km
```

#### `AirportData.findNearestAirport(double lat, double lon, [AirportFilter? filters])`
Finds the single nearest airport to given coordinates, optionally with filters.

```dart
// Find nearest airport to coordinates
final nearest = AirportData.findNearestAirport(1.35019, 103.994003);
print(nearest.airport);   // Airport name
print(nearest.distance);  // Distance in km

// Find nearest large airport with scheduled service
final nearestHub = AirportData.findNearestAirport(1.35019, 103.994003, const AirportFilter(
  type: 'large_airport',
  hasScheduledService: true,
));
```

### Validation & Utilities

#### `AirportData.validateIataCode(String code)`
Validates if an IATA code exists in the database.

```dart
AirportData.validateIataCode('SIN');  // true
AirportData.validateIataCode('XYZ');  // false
AirportData.validateIataCode('ABCD'); // false (wrong format)
```

#### `AirportData.validateIcaoCode(String code)`
Validates if an ICAO code exists in the database.

```dart
AirportData.validateIcaoCode('WSSS'); // true
AirportData.validateIcaoCode('XXXX'); // false
```

#### `AirportData.getAirportCount([AirportFilter? filters])`
Gets the count of airports matching the given filters.

```dart
final total = AirportData.getAirportCount();
final usLargeCount = AirportData.getAirportCount(const AirportFilter(
  countryCode: 'US',
  type: 'large_airport',
));
```

#### `AirportData.isAirportOperational(String code)`
Checks if an airport has scheduled commercial service.

```dart
AirportData.isAirportOperational('SIN'); // true
```

## Error Handling

Functions throw exceptions for invalid input or when no data is found:

```dart
try {
  AirportData.getAirportByIata('XYZ');
} on StateError catch (e) {
  print(e.message); // "No data found for IATA code: XYZ"
}
```

## Data Source

This library uses a comprehensive dataset of worldwide airports with regular updates to ensure accuracy and completeness.

## License

This project is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/aashishvanand/airport-data-dart/issues).
