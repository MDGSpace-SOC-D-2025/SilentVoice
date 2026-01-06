import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final LatLng initialLocation;
  final Set<Marker> markers;

  const GoogleMapWidget({
    super.key,
    required this.initialLocation,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialLocation, zoom: 14),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: markers,
    );
  }
}
