import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../widgets/google_map_widget.dart';
import '../services/nearby_places_service.dart';
import '../models/nearby_place.dart';

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

  @override
  void initState() {
    super.initState();
    _loadLocation();
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

  Set<Marker> _markersFromPlaces(List<NearbyPlace> places) {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.name),
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(title: place.name, snippet: place.type),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Help')),
      body: GoogleMapWidget(
        initialLocation: _currentLocation!,
        markers: _markers,
      ),
    );
  }
}
