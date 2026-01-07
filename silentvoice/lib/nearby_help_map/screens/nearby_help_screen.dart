import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../widgets/google_map_widget.dart';
import '../services/nearby_places_service.dart';
import '../models/nearby_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

class NearbyHelpScreen extends StatefulWidget {
  const NearbyHelpScreen({super.key});

  @override
  State<NearbyHelpScreen> createState() => _NearbyHelpScreenState();
}

class _NearbyHelpScreenState extends State<NearbyHelpScreen> {
  final LocationService _locationService = LocationService();

  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _error;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  void _openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();

      final placesService = NearbyPlacesService();
      final places = await placesService.fetchNearbyHelp(location);

      setState(() {
        _currentLocation = location;
        _markers = _markersFromPlaces(places);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _animateCameraTo(NearbyPlace place) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lng), 16),
    );
  }

  Set<Marker> _markersFromPlaces(List<NearbyPlace> places) {
    return places.map((place) {
      final isHospital = place.type.contains('hospital');

      return Marker(
        markerId: MarkerId(place.name),
        position: LatLng(place.lat, place.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isHospital ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: isHospital ? 'Hospital' : 'Police Station',
        ),
        onTap: () {
          _animateCameraTo(place);
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Finding nearby help...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Location access is needed to find nearby help.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openLocationSettings,
                  child: const Text('Enable Location'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Help'),
        actions: [QuickExitButton()],
      ),
      body: GoogleMapWidget(
        initialLocation: _currentLocation!,
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
