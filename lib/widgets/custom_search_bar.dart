import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLocationFilterPressed;
  final List<String> razas;
  final ValueChanged<String> onRazaFilterChanged;
  final ValueChanged<String> onSexoFilterChanged;
  final ValueChanged<RangeValues> onPriceFilterChanged;
  final bool showFilters; // Nueva bandera para controlar la visibilidad de los filtros

  CustomSearchBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onLocationFilterPressed,
    required this.razas,
    required this.onRazaFilterChanged,
    required this.onSexoFilterChanged,
    required this.onPriceFilterChanged,
    required this.showFilters,  // Parámetro requerido para controlar los filtros
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
            // Dropdown para filtrar por raza
            DropdownButtonFormField<String>(
              value: selectedRaza,
              decoration: InputDecoration(
                labelText: 'Filtrar por Raza',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: widget.razas.map((raza) {
                return DropdownMenuItem(
                  value: raza,
                  child: Text(raza),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRaza = value;
                });
                widget.onRazaFilterChanged(value!);
              },
            ),
            SizedBox(height: 8.0),

            // Dropdown para filtrar por sexo
            DropdownButtonFormField<String>(
              value: selectedSexo,
              decoration: InputDecoration(
                labelText: 'Filtrar por Sexo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: ['Macho', 'Hembra'].map((sexo) {
                return DropdownMenuItem(
                  value: sexo,
                  child: Text(sexo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSexo = value;
                });
                widget.onSexoFilterChanged(value!);
              },
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

          // Botón de filtro por ubicación (opcional en ambos casos)
          ElevatedButton.icon(
            icon: Icon(Icons.location_on),
            label: Text('Filtrar por Ubicación'),
            onPressed: widget.onLocationFilterPressed,
          ),
        ],
      ),
    );
  }
}
