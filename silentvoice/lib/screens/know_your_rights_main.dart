import 'package:flutter/material.dart';
import 'package:silentvoice/screens/rights_detail_screen.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

final List<String> didYouKnowMessages = [
  'If someone forces you to stay at home or limits where you can go, it is also abuse.',
  'Abuse does not have to be physical to be serious.',
  'Checking your phone without permission is not okay.',
  'You have the right to feel safe in your own home.',
  'Controlling who you talk to is a form of abuse.',
  'Threatening you, even without hitting you, is considered abuse.',
  'Being forced into unwanted actions is also abuse.',
  'Abuse can happen even if the person hurting you is a family member.',
  'You deserve respect, safety, and dignity.',
  'Asking for help is a sign of strength, not weakness.',
  'Constant insults or humiliation are forms of emotional abuse.',
  'Abuse can happen to anyone, and it is never your fault.',
  'Feeling scared of someone close to you is a warning sign.',
  'Help is available even if you are unsure what to do next.',
];

class KnowYourRightsHome extends StatefulWidget {
  const KnowYourRightsHome({super.key});

  @override
  State<KnowYourRightsHome> createState() => _KnowYourRightsHomeState();
}

class _KnowYourRightsHomeState extends State<KnowYourRightsHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late String selectedMessage;
  @override
  void initState() {
    super.initState();

    didYouKnowMessages.shuffle();
    selectedMessage = didYouKnowMessages.first;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Know Your Rights'),
        centerTitle: true,
        actions: [QuickExitButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Card(
                  elevation: 1,
                  color: const Color.fromARGB(255, 237, 246, 246),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Did you know?\n$selectedMessage',
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            _buildCard(
              title: 'What counts as abuse',
              icon: Icons.warning_amber_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RightsDetailScreen(sectionKey: 'abuse'),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),

            _buildCard(
              title: 'Your legal rights',
              icon: Icons.gavel_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RightsDetailScreen(sectionKey: 'legal'),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),

            _buildCard(
              title: 'Emergency helplines',
              icon: Icons.phone_in_talk_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RightsDetailScreen(sectionKey: 'helplines'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCard({
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 1,
    color: Colors.grey.shade100,

    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title),
      onTap: onTap,
    ),
  );
}
