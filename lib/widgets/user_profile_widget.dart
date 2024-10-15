import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController phoneController;
  final String location;
  final Function(String) onLocationChanged;
  final Function() onSave;
  final String role;
  final String email;

  UserProfileWidget({
    required this.nameController,
    required this.descriptionController,
    required this.phoneController,
    required this.location,
    required this.onLocationChanged,
    required this.onSave,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nombre de Usuario - siempre visible
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de Usuario',
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        
        if (role != 'Usuario') ...[
        
          // Descripción - visible solo si el rol no es "Usuario"
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          // Teléfono - visible solo si el rol no es "Usuario"
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Número de Teléfono',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
        
          // Ubicación - visible solo si el rol no es "Usuario"
          TextField(
            controller: TextEditingController(text: location),
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            onChanged: onLocationChanged,
          ),
        
        const SizedBox(height: 10),
        ],

        // Correo Electrónico - siempre visible, pero solo lectura
        TextField(
          controller: TextEditingController(text: email),
          decoration: const InputDecoration(
            labelText: 'Correo Electrónico',
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          readOnly: true,
        ),
        
        const SizedBox(height: 10),

        // Rol - siempre visible
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rol:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                role,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        
        // Botón de Guardar Perfil - siempre visible
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Guardar Perfil'),
        ),
      ],
    );
  }
}
