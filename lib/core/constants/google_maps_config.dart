import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Centralized Configuration and Utilities for Google Maps Platform Integration
class GoogleMapsConfig {
  /// Default Google Maps API Key configuration.
  /// Pass the key via environment variable:
  /// --dart-define=GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
  );

  /// Supported Tamil Nadu Cities
  static const List<String> supportedCities = ['Coimbatore', 'Tirupur', 'Chennai'];

  /// Tamil Nadu City Center Coordinates
  static const Map<String, LatLng> cityCenters = {
    'Coimbatore': LatLng(11.0168, 76.9558),
    'Tirupur': LatLng(11.1085, 77.3411),
    'Chennai': LatLng(13.0827, 80.2707),
  };

  /// Default Center set to Coimbatore, Tamil Nadu
  static const LatLng defaultCenter = LatLng(11.0168, 76.9558);
  static const double defaultZoom = 13.0;
  static const double detailedZoom = 15.0;

  /// Default Camera Position for Tamil Nadu Fleet Radar Visual
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: defaultCenter,
    zoom: defaultZoom,
    tilt: 35.0,
  );

  /// Real Tamil Nadu Hospital Coordinates
  static const Map<String, LatLng> hospitalLocations = {
    // Coimbatore Hospitals
    'PSG Hospitals': LatLng(11.0264, 76.9934),
    'Ganga Hospital': LatLng(11.0183, 76.9515),
    'KMCH (Kovai Medical Center)': LatLng(11.0425, 77.0396),
    'Sri Ramakrishna Hospital': LatLng(11.0227, 76.9742),
    'GKNM Hospital': LatLng(11.0125, 76.9760),

    // Tirupur Hospitals
    'Revathi Medical Center': LatLng(11.1215, 77.3412),
    'Sri Kumaran Hospital': LatLng(11.0965, 77.3524),
    'Govt Head Quarters Hospital Tirupur': LatLng(11.1062, 77.3468),
    'Velan Specialty Hospital': LatLng(11.0988, 77.3610),

    // Chennai Hospitals
    'Apollo Hospitals (Greams Rd)': LatLng(13.0604, 80.2512),
    'Fortis Malar Hospital': LatLng(13.0067, 80.2570),
    'MIOT International': LatLng(13.0232, 80.1770),
    'Rajiv Gandhi Govt General Hospital': LatLng(13.0805, 80.2783),
    'SIMS Hospital (Vadapalani)': LatLng(13.0512, 80.2120),
    'Kauvery Hospital': LatLng(13.0360, 80.2510),
  };

  /// Pickup / Emergency Scene Coordinates by City in Tamil Nadu
  static const Map<String, LatLng> cityPickupLocations = {
    'Coimbatore': LatLng(11.0200, 76.9650), // Gandhipuram / Avinashi Rd
    'Tirupur': LatLng(11.1100, 77.3450), // Avinashi Rd Sector
    'Chennai': LatLng(13.0620, 80.2580), // Nungambakkam / Greams Line
  };

  static const LatLng defaultPickupLocation = LatLng(11.0200, 76.9650);

  /// Google Maps Dark Theme JSON Styling for High-Contrast Emergency Dashboard
  static const String darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8ec3b9"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1a3646"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b687a"}]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b687a"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#334e68"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6f9ba5"}]
  },
  {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [{"color": "#3d1e2e"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3e606f"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#304a7d"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#2c456b"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1f2835"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#b0d5ce"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#3a4762"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#4e6d7c"}]
  }
]
''';
}
