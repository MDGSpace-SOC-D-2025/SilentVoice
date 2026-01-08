import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../widgets/google_map_widget.dart';
import '../services/nearby_places_service.dart';
import '../models/nearby_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';
import 'package:url_launcher/url_launcher.dart';

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

  double _distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  List<NearbyPlace> _filterPlaces(
    List<NearbyPlace> places,
    LatLng userLocation,
  ) {
    final relevant = places.where(
      (p) => p.type == 'hospital' || p.type == 'police',
    );

    final nearby = relevant.where((p) {
      final distance = _distanceInMeters(
        userLocation.latitude,
        userLocation.longitude,
        p.lat,
        p.lng,
      );
      return distance <= 5000;
    }).toList();

    final List<NearbyPlace> hospitals = [];
    final List<NearbyPlace> police = [];

    for (final place in nearby) {
      if (place.type == 'hospital' && hospitals.length < 10) {
        hospitals.add(place);
      } else if (place.type == 'police' && police.length < 10) {
        police.add(place);
      }
    }

    return [...hospitals, ...police];
  }

  String _formatDistance(LatLng user, NearbyPlace place) {
    final meters = Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      place.lat,
      place.lng,
    );

    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  void _openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  Future<void> _openDirections(NearbyPlace place) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${place.lat},${place.lng}'
      '&travelmode=walking',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final location = await _locationService.getCurrentLocation();
      final placesService = NearbyPlacesService();
      final rawPlaces = await placesService.fetchNearbyHelp(location);
      final filteredPlaces = _filterPlaces(rawPlaces, location);

      setState(() {
        _currentLocation = location;
        _markers = _markersFromPlaces(filteredPlaces);
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showPlaceActions(NearbyPlace place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                place.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    place.type == 'hospital'
                        ? Icons.local_hospital
                        : Icons.local_police,
                    size: 18,
                    color: const Color.fromARGB(255, 65, 64, 64),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    place.type == 'hospital' ? 'Hospital' : 'Police Station',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatDistance(_currentLocation!, place),
                style: TextStyle(
                  color: const Color.fromARGB(255, 66, 65, 65),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _openDirections(place);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _animateCameraTo(NearbyPlace place) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.lat, place.lng), 16),
    );
  }

  BitmapDescriptor _iconForPlaceType(String type) {
    switch (type) {
      case 'hospital':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'police':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Set<Marker> _markersFromPlaces(List<NearbyPlace> places) {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.name),
        position: LatLng(place.lat, place.lng),
        icon: _iconForPlaceType(place.type),
        infoWindow: InfoWindow(
          title: place.name,
          snippet:
              '${place.type == 'hospital' ? 'Hospital' : 'Police Station'} • '
              '${_formatDistance(_currentLocation!, place)} away',
        ),
        onTap: () {
          _animateCameraTo(place);
          _showPlaceActions(place);
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
    if (_markers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nearby Help')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No nearby emergency services found within this area.',
              textAlign: TextAlign.center,
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
