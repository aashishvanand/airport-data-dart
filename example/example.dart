import 'package:airport_data/airport_data.dart';

void main() {
  // Search by IATA code
  final airports = AirportData.getAirportByIata('SIN');
  print('Airport: ${airports.first.airport}'); // Singapore Changi Airport
  print('Country: ${airports.first.countryCode}'); // SG
  print('Timezone: ${airports.first.time}'); // Asia/Singapore

  // Search by ICAO code
  final icaoResult = AirportData.getAirportByIcao('EGLL');
  print(
      '\nICAO lookup: ${icaoResult.first.airport}'); // London Heathrow Airport

  // Search by name
  final searchResults = AirportData.searchByName('Tokyo');
  print('\nAirports matching "Tokyo": ${searchResults.length}');
  for (final airport in searchResults) {
    print('  - ${airport.airport} (${airport.iata})');
  }

  // Find nearby airports within 50km
  final nearby = AirportData.findNearbyAirports(1.35019, 103.994003, 50);
  print('\nAirports within 50km of Singapore Changi:');
  for (final airport in nearby) {
    print(
        '  - ${airport.airport} (${airport.distance?.toStringAsFixed(1)} km)');
  }

  // Calculate distance between two airports
  final distance = AirportData.calculateDistance('LHR', 'JFK');
  print('\nLHR to JFK: ${distance.toStringAsFixed(0)} km');

  // Filter airports by country
  final sgAirports = AirportData.getAirportByCountryCode('SG');
  print('\nAirports in Singapore: ${sgAirports.length}');

  // Advanced multi-criteria filtering
  final filtered = AirportData.findAirports(const AirportFilter(
    countryCode: 'GB',
    type: 'large_airport',
    hasScheduledService: true,
  ));
  print('\nLarge airports in GB with scheduled service: ${filtered.length}');

  // Validate codes
  print('\nIs "SIN" a valid IATA code? ${AirportData.validateIataCode('SIN')}');
  print('Is "XXXX" a valid ICAO code? ${AirportData.validateIcaoCode('XXXX')}');

  // Get total airport count
  print('\nTotal airports in database: ${AirportData.getAirportCount()}');
}
