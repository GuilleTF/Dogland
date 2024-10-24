import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLocationFilterPressed;
  final List<String> razas;
  final ValueChanged<String?> onRazaFilterChanged;
  final ValueChanged<String?> onSexoFilterChanged;
  final ValueChanged<RangeValues> onPriceFilterChanged;
  final bool showFilters;
  final bool showLocationFilter; // Nueva bandera para controlar la visibilidad del botón de ubicación

  CustomSearchBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onLocationFilterPressed,
    required this.razas,
    required this.onRazaFilterChanged,
    required this.onSexoFilterChanged,
    required this.onPriceFilterChanged,
    required this.showFilters,
    this.showLocationFilter = false, // El botón de ubicación estará oculto por defecto
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String? selectedRaza;
  String? selectedSexo;
  RangeValues priceRange = RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // TextField para la búsqueda por texto
          TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
          SizedBox(height: 8.0),

          // Mostrar los filtros adicionales solo si showFilters es true
          if (widget.showFilters) ...[
            // Colocar filtros de raza y sexo en una fila (Row)
            Row(
              children: [
                // Botón de filtro de raza
                Expanded(
                  child: _buildFilterButton(
                    label: selectedRaza ?? 'Filtrar por Raza',
                    items: widget.razas,
                    onSelected: (value) {
                      setState(() {
                        selectedRaza = value;
                      });
                      widget.onRazaFilterChanged(value);
                    },
                  ),
                ),
                SizedBox(width: 8.0), // Espacio entre los dos botones

                // Botón de filtro de sexo
                Expanded(
                  child: _buildFilterButton(
                    label: selectedSexo ?? 'Filtrar por Sexo',
                    items: ['Macho', 'Hembra'],
                    onSelected: (value) {
                      setState(() {
                        selectedSexo = value;
                      });
                      widget.onSexoFilterChanged(value);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),

            // RangeSlider para el intervalo de precios
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filtrar por Precio (€):'),
                RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 10,
                  labels: RangeLabels(
                    '${priceRange.start.toInt()}€',
                    '${priceRange.end.toInt()}€',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      priceRange = values;
                    });
                    widget.onPriceFilterChanged(values);
                  },
                ),
              ],
            ),
          ],

          // Mostrar el botón de ubicación solo si showLocationFilter es true
          if (widget.showLocationFilter)
            ElevatedButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Filtrar por Ubicación'),
              onPressed: widget.onLocationFilterPressed,
            ),
        ],
      ),
    );
  }

  // Widget personalizado para el botón de filtro que muestra un BottomSheet con scroll
  Widget _buildFilterButton({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onSelected,
  }) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: 300,  // Tamaño fijo para que no ocupe toda la pantalla
              child: ListView.builder(
                itemCount: items.length + 1,  // Incluye la opción de quitar filtro
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: Text('Quitar filtro'),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(null);
                      },
                    );
                  }
                  return ListTile(
                    title: Text(items[index - 1]),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(items[index - 1]);
                    },
                  );
                },
              ),
            );
          },
        );
      },
      child: Text(label),
    );
  }
}
