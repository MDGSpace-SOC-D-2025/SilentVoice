import 'package:flutter/material.dart';

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:silentvoice/fake_call/fake_call_in_progress_screen.dart';

import 'package:silentvoice/anonymous_chat/screens/start_chat_screen.dart';
import 'package:silentvoice/emergency_sos/screens/emergency_sos_screen.dart';
import 'package:silentvoice/evidence_vault/screens/vault_lock_screen.dart';
import 'package:silentvoice/fake_call/callkit_helper.dart';
import 'package:silentvoice/nearby_help_map/screens/nearby_help_screen.dart';
import 'package:silentvoice/screens/settings_screen.dart';
import 'calculator_screen.dart';
import 'know_your_rights_main.dart';

class HiddenDashboardScreen extends StatefulWidget {
  const HiddenDashboardScreen({super.key});

  @override
  State<HiddenDashboardScreen> createState() => _HiddenDashboardScreenState();
}

class _HiddenDashboardScreenState extends State<HiddenDashboardScreen> {
  @override
  void initState() {
    super.initState();
    listenToCallEvents();
  }

  void listenToCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallAccept:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FakeCallInProgressScreen()),
          );
          break;

        case Event.actionCallDecline:
          CallKitHelper.endAllCalls();
          break;

        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 32),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.calculate_outlined, size: 32),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalculatorScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 45),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  DashboardPillButton(
                    title: 'Anonymous Chat',
                    gradient: const [Color(0xFF5C9DFF), Color(0xFF8BB8FF)],
                    icon: Icons.chat_bubble_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StartChatScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DashboardPillButton(
                    title: 'Emergency SOS',
                    gradient: const [Color(0xFFFFB347), Color(0xFFFFCC80)],
                    icon: Icons.warning_amber_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EmergencySosScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DashboardPillButton(
                    title: ' Evidence Vault',
                    gradient: const [Color(0xFF9C7CFF), Color(0xFFC3B1FF)],
                    icon: Icons.lock_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VaultLockScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DashboardPillButton(
                    title: 'Nearby Help Map',
                    icon: Icons.location_on_outlined,
                    gradient: const [Color(0xFF5FD38D), Color(0xFF9BE7B2)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NearbyHelpScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DashboardPillButton(
                    title: 'Know Your Rights',
                    icon: Icons.menu_book_outlined,
                    gradient: const [Color(0xFF4DB6AC), Color(0xFF80DEEA)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KnowYourRightsHome(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  DashboardPillButton(
                    title: 'Incoming Call',
                    icon: Icons.call,
                    gradient: const [
                      Color.fromARGB(255, 96, 125, 139),
                      Color.fromARGB(255, 144, 164, 174),
                    ],
                    onTap: () {
                      CallKitHelper.showIncomingCall();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPillButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const DashboardPillButton({
    super.key,
    required this.title,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
