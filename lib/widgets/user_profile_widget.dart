import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserProfileWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final FocusNode locationFocusNode;
  final Function(LatLng) onLocationSelected;
  final Function() onSave;
  final String role;
  final String email;

  UserProfileWidget({
    required this.nameController,
    required this.descriptionController,
    required this.phoneController,
    required this.locationController,
    required this.locationFocusNode,
    required this.onLocationSelected,
    required this.onSave,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de Usuario',
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        if (role != 'Usuario') ...[
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Número de Teléfono',
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          GooglePlaceAutoCompleteTextField(
            textEditingController: locationController,
            googleAPIKey: "AIzaSyCmf3PNr3CTGTwcGh5V5kFh1Fc4Tz8fjng",
            inputDecoration: InputDecoration(
              hintText: 'Buscar ubicación',
              filled: true,
              fillColor: Colors.white,
            ),
            focusNode: locationFocusNode,
            debounceTime: 800,
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (prediction) {
              onLocationSelected(LatLng(
                double.tryParse(prediction.lat ?? '0.0') ?? 0.0,
                double.tryParse(prediction.lng ?? '0.0') ?? 0.0,
              ));
            },
            itemClick: (prediction) {
              locationController.text = prediction.description ?? '';
              onLocationSelected(LatLng(
                double.tryParse(prediction.lat ?? '0.0') ?? 0.0,
                double.tryParse(prediction.lng ?? '0.0') ?? 0.0,
              ));
            },
          ),
          const SizedBox(height: 10),
        ],

        TextField(
          controller: TextEditingController(text: email),
          decoration: const InputDecoration(
            labelText: 'Correo Electrónico',
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          readOnly: true,
        ),
        const SizedBox(height: 20),
        
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Guardar Perfil'),
        ),
      ],
    );
  }
}
