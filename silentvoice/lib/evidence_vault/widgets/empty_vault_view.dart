import 'package:flutter/material.dart';

class EmptyVaultView extends StatelessWidget {
  const EmptyVaultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No evidence added yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
