import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silentvoice/widgets/quick_exit_appbar_action.dart';

const Color _headingColor = Color.fromARGB(255, 4, 106, 94);

class RightsDetailScreen extends StatelessWidget {
  final String sectionKey;

  RightsDetailScreen({super.key, required this.sectionKey});

  Future<Map<String, dynamic>> _loadRightsData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/rights_content.json',
    );

    final Map<String, dynamic> data = jsonDecode(jsonString);
    return data[sectionKey];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [QuickExitButton()]),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadRightsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load content'));
          }

          final sectionData = snapshot.data!;
          final List<dynamic> content = sectionData['content'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  sectionData['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...content.map((text) {
                  final String line = text.toString();

                  // Headings (no bullet, bold)
                  if (line.endsWith(':')) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _headingColor,
                        ),
                      ),
                    );
                  }

                  // Closing or important statements (no bullet)
                  if (line.startsWith('If ') ||
                      line.startsWith('Remember') ||
                      line.startsWith('Everyone') ||
                      line.startsWith('In India') ||
                      line.startsWith('You have') ||
                      line.startsWith('You can')) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        line,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    );
                  }
                  // Helpline numbers
                  if (line.contains('—')) {
                    return _helplineRow(line);
                  }
                  // Bullet points
                  return _bulletPoint(line);
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _bulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  ', style: TextStyle(fontSize: 18, height: 1.4)),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    ),
  );
}

Widget _helplineRow(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        const Icon(Icons.phone, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    ),
  );
}
