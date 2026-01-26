import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:silentvoice/emergency_sos/screens/trusted_contacts_screen.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';
import '../services/sos_service.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  final SosService _sosService = SosService();
  bool _sending = false;

  Future<void> _triggerSOS() async {
    HapticFeedback.heavyImpact();

    setState(() => _sending = true);

    try {
      await _sosService.sendSOS();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS message ready. Tap Send to notify contacts.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final error = e.toString();

      if (error == 'NO_CONTACTS') {
        _showErrorDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No Trusted Contacts',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          message:
              'You haven\'t added any trusted contacts yet.\n\n'
              'Please add at least one contact from Settings so SOS can notify them.',
          actionText: 'Go to Settings',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrustedContactsScreen()),
            );
          },
        );
      } else if (error == 'LOCATION_DENIED') {
        _showErrorDialog(
          title: Row(
            children: const [
              Icon(Icons.location_off, color: Colors.redAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location Access Needed',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          message:
              'Location permission is required to send your current '
              'location to trusted contacts.\n\n'
              'Please enable location access in app settings.',
          actionText: 'Open Settings',
          onAction: () {
            Geolocator.openAppSettings();
          },
        );
      } else {
        _showErrorDialog(
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SOS Failed',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          message: 'Something went wrong. Please try again.',
        );
      }
    } finally {
      setState(() => _sending = false);
    }
  }

  void _showErrorDialog({
    required Widget title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: title,
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (actionText != null && onAction != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        actions: [QuickExitButton()],
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          onPressed: _sending ? null : _triggerSOS,
          child: _sending
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sos, size: 22, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'SEND SOS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
