import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trusted_contacts_service.dart';

class SosService {
  final TrustedContactsService _contactsService = TrustedContactsService();
  Future<void> sendSOS() async {
    final contacts = await _contactsService.loadContacts();
    if (contacts.isEmpty) {
      throw 'NO_CONTACTS';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw 'LOCATION_DENIED';
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final double lat = position.latitude;
    final double lng = position.longitude;

    final mapsLink =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    final message =
        'EMERGENCY\n\n'
        'I need help immediately.\n'
        'My current location:\n$mapsLink';

    final numbers = contacts.map((c) => c.phone).join(',');

    final Uri smsUri = Uri.parse(
      'smsto:$numbers?body=${Uri.encodeComponent(message)}',
    );

    if (!await launchUrl(smsUri)) {
      throw 'SMS_FAILED';
    }
  }
}
