import 'package:flutter/material.dart';

Future<void> showLoginRequiredDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Login Required'),
      content: const Text('This feature is available after login.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/auth');
          },
          child: const Text('Login'),
        ),
      ],
    ),
  );
} 