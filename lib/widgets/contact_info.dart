// widgets/contact_info.dart
import 'package:flutter/material.dart';

class ContactInfo extends StatelessWidget {
  final String telefono;
  final String correo;

  const ContactInfo({required this.telefono, required this.correo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone),
              const SizedBox(width: 10),
              Text(telefono),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email),
              const SizedBox(width: 10),
              Text(correo),
            ],
          ),
        ],
      ),
    );
  }
}
