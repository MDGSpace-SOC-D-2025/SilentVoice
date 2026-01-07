import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/nearby_place.dart';
import 'package:silentvoice/config/api_keys.dart';

class NearbyPlacesService {
  static const String _apiKey = ApiKeys.placesApiKey;

  Future<List<NearbyPlace>> fetchNearbyHelp(LatLng location) async {
    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:searchNearby',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.displayName,places.location,places.types',
      },
      body: jsonEncode({
        'locationRestriction': {
          'circle': {
            'center': {
              'latitude': location.latitude,
              'longitude': location.longitude,
            },
            'radius': 5000.0,
          },
        },
        'includedTypes': ['hospital', 'police'],
        'maxResultCount': 15,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch nearby places');
    }

    final decoded = jsonDecode(response.body);
    final places = decoded['places'] as List<dynamic>? ?? [];

    return places.map((p) {
      final List types = p['types'] ?? [];

      final String resolvedType = types.contains('hospital')
          ? 'hospital'
          : types.contains('police')
          ? 'police'
          : 'other';
      return NearbyPlace(
        name: p['displayName']['text'],
        lat: p['location']['latitude'],
        lng: p['location']['longitude'],
        type: resolvedType,
      );
    }).toList();
  }
}
