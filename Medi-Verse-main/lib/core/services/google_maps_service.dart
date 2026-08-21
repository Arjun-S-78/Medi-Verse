import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/google_maps_config.dart';

/// Helper service for Google Maps markers, polylines, camera bounds, and telemetry mapping.
class GoogleMapsService {
  /// Converts fleet data maps to interactive Google Maps Marker set.
  static Set<Marker> buildFleetMarkers({
    required List<Map<String, dynamic>> fleet,
    required int selectedIndex,
    required void Function(int index, String unitId) onMarkerTap,
  }) {
    final Set<Marker> markers = {};

    for (int i = 0; i < fleet.length; i++) {
      final amb = fleet[i];
      final LatLng pos = _getAmbulanceLatLng(amb);
      final bool isSelected = i == selectedIndex;
      final Color badgeColor = amb['badgeColor'] as Color? ?? Colors.red;

      // Select Marker Bitmap Hue based on status
      double hue = BitmapDescriptor.hueRed;
      if (amb['status'] == 'Available') {
        hue = BitmapDescriptor.hueGreen;
      } else if (amb['status'] == 'On Scene') {
        hue = BitmapDescriptor.hueOrange;
      } else if (amb['status'] == 'Maintenance') {
        hue = BitmapDescriptor.hueViolet;
      } else if (badgeColor == Colors.blue) {
        hue = BitmapDescriptor.hueAzure;
      }

      markers.add(
        Marker(
          markerId: MarkerId('amb_${amb['id']}'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: '${amb['id']} (${amb['type']})',
            snippet: 'Status: ${amb['status']} • Speed: ${amb['speed']} km/h',
          ),
          zIndexInt: isSelected ? 10 : 5,
          onTap: () => onMarkerTap(i, amb['id']),
        ),
      );

      // Add Hospital Destination Marker for selected ambulance if route exists
      if (isSelected && amb['destination'] != null) {
        final LatLng? destPos = GoogleMapsConfig.hospitalLocations[amb['destination']];
        if (destPos != null) {
          markers.add(
            Marker(
              markerId: MarkerId('hospital_${amb['id']}'),
              position: destPos,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
              infoWindow: InfoWindow(
                title: amb['destination'],
                snippet: 'Bay: ${amb['traumaBay']} • ETA: ${amb['etaMinutes']} mins',
              ),
              zIndexInt: 8,
            ),
          );
        }
      }
    }

    return markers;
  }

  /// Map raw offset points to actual LatLng around city center
  static LatLng _getAmbulanceLatLng(Map<String, dynamic> amb) {
    if (amb['lat'] != null && amb['lng'] != null) {
      return LatLng(amb['lat'] as double, amb['lng'] as double);
    }
    // Determine base center from city or destination
    LatLng baseCenter = GoogleMapsConfig.defaultCenter;
    final String? city = amb['city'] as String?;
    if (city != null && GoogleMapsConfig.cityCenters.containsKey(city)) {
      baseCenter = GoogleMapsConfig.cityCenters[city]!;
    } else if (amb['destination'] != null && GoogleMapsConfig.hospitalLocations.containsKey(amb['destination'])) {
      final dest = GoogleMapsConfig.hospitalLocations[amb['destination']]!;
      baseCenter = LatLng(dest.latitude - 0.01, dest.longitude - 0.01);
    }

    // Compute synthetic LatLng based on ID hash for demo fleet
    final int hash = amb['id'].hashCode;
    final double latOffset = ((hash % 100) - 50) / 3500.0;
    final double lngOffset = (((hash ~/ 100) % 100) - 50) / 3500.0;
    return LatLng(
      baseCenter.latitude + latOffset,
      baseCenter.longitude + lngOffset,
    );
  }

  /// Builds route Polylines between Ambulance position, Waypoints, and Destination
  static Set<Polyline> buildFleetRoutePolylines({
    required List<Map<String, dynamic>> fleet,
    required int selectedIndex,
    required bool showTraffic,
    required double simulatedProgress,
  }) {
    final Set<Polyline> polylines = {};
    if (selectedIndex < 0 || selectedIndex >= fleet.length) return polylines;

    final selectedAmb = fleet[selectedIndex];
    final LatLng ambPos = _getAmbulanceLatLng(selectedAmb);
    final LatLng? destPos = GoogleMapsConfig.hospitalLocations[selectedAmb['destination']];

    if (destPos != null) {
      // Create active route polyline
      final List<LatLng> routePoints = [
        ambPos,
        LatLng(
          ambPos.latitude + (destPos.latitude - ambPos.latitude) * 0.4 + 0.002,
          ambPos.longitude + (destPos.longitude - ambPos.longitude) * 0.3 - 0.003,
        ),
        LatLng(
          ambPos.latitude + (destPos.latitude - ambPos.latitude) * 0.7 - 0.001,
          ambPos.longitude + (destPos.longitude - ambPos.longitude) * 0.8 + 0.002,
        ),
        destPos,
      ];

      polylines.add(
        Polyline(
          polylineId: PolylineId('route_${selectedAmb['id']}'),
          points: routePoints,
          color: showTraffic ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
          width: 5,
          jointType: JointType.round,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
        ),
      );
    }

    return polylines;
  }

  /// Calculates LatLngBounds containing all fleet units for fitting camera
  static LatLngBounds getBoundsForFleet(List<Map<String, dynamic>> fleet) {
    double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;

    for (final amb in fleet) {
      final pos = _getAmbulanceLatLng(amb);
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.005, minLng - 0.005),
      northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
    );
  }
}
