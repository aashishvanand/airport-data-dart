## 1.0.4

- Use official dart-lang reusable workflow for pub.dev publishing
- Simplify CI/CD: tag-based publish with dart-lang/setup-dart publish workflow

## 1.0.3

- Fix automated publishing: use tag-based publish triggered by release branch
- Upgrade actions/checkout to v6 for Node.js 24 compatibility

## 1.0.2

- Automate publishing via release branch with auto-tagging

## 1.0.1

- Add CI/CD workflows for automated testing and pub.dev publishing
- Add example, LICENSE, and CHANGELOG for improved pub.dev score
- Fix dart formatting

## 1.0.0

- Initial release
- Comprehensive airport database with worldwide coverage
- Search by IATA code, ICAO code, and airport name
- Geographic proximity search and distance calculation
- Filter by country, continent, airport type, and timezone
- Advanced multi-criteria filtering with `AirportFilter`
- Autocomplete suggestions for search interfaces
- External links (Wikipedia, Flightradar24, RadarBox, FlightAware)
- Statistical analysis by country and continent
- Bulk operations: multi-airport fetch, distance matrix, nearest airport
- Code validation utilities
- Cross-platform support (all Flutter platforms, Dart CLI/Server, and Web)
