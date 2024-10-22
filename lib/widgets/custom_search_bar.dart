// widgets/custom_search_bar.dart

import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLocationFilterPressed;

  CustomSearchBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onLocationFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.location_on),
                label: Text('Filtrar por Ubicación'),
                onPressed: onLocationFilterPressed,
              ),
              // Puedes añadir otros filtros aquí
            ],
          ),
        ],
      ),
    );
  }
}
