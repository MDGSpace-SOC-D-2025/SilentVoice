import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/screens/helper_chat_screen.dart';
import 'package:silentvoice/anonymous_chat/services/chat_request_service.dart';
import 'package:silentvoice/anonymous_chat/services/helper_status_service.dart';

class HelperDashboardScreen extends StatefulWidget {
  const HelperDashboardScreen({super.key});

  @override
  State<HelperDashboardScreen> createState() => _HelperDashboardScreenState();
}

class _HelperDashboardScreenState extends State<HelperDashboardScreen>
    with WidgetsBindingObserver {
  final HelperStatusService _statusService = HelperStatusService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> activeChatStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('helperId', isEqualTo: _uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots();
  }

  Stream<int> pendingRequestCount() {
    return FirebaseFirestore.instance
        .collection('chat_requests')
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _statusService.setOnline();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _statusService.setOffline();
    } else if (state == AppLifecycleState.resumed) {
      _statusService.setOnline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _statusService.setOffline();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          automaticallyImplyLeading: false,
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: activeChatStream(),
          builder: (context, chatSnapshot) {
            if (chatSnapshot.hasData && chatSnapshot.data!.docs.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HelperChatScreen()),
                );
              });

              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<int>(
                    stream: pendingRequestCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;

                      return Text(
                        count == 0
                            ? 'No users are waiting right now.'
                            : 'Pending requests: $count',
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final chatId = await ChatRequestService().takeNextUser();

                      if (chatId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No pending requests')),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelperChatScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text('Take Next User'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusService.setOffline();
    super.dispose();
  }
}
