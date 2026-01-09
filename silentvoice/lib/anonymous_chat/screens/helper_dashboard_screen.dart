import 'package:flutter/material.dart';
import 'package:silentvoice/anonymous_chat/services/helper_status_service.dart';

class HelperDashboardScreen extends StatefulWidget {
  HelperDashboardScreen({super.key});

  @override
  State<HelperDashboardScreen> createState() => _HelperDashboardScreenState();
}

class _HelperDashboardScreenState extends State<HelperDashboardScreen> {
  @override
  void initState() {
    super.initState();
    HelperStatusService().setOnline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Helper Dashboard', style: TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  void dispose() {
    HelperStatusService().setOffline();
    super.dispose();
  }
}
