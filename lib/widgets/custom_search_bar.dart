// widgets/custom_search_bar.dart
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLocationFilterPressed;
  final List<String> razas;
  final ValueChanged<String?> onRazaFilterChanged;
  final ValueChanged<String?> onSexoFilterChanged;
  final ValueChanged<int> onMinPriceChanged;
  final ValueChanged<int> onMaxPriceChanged;
  final bool showFilters;
  final bool showLocationFilter;

  CustomSearchBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onLocationFilterPressed,
    required this.razas,
    required this.onRazaFilterChanged,
    required this.onSexoFilterChanged,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
    required this.showFilters,
    this.showLocationFilter = false,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String? selectedRaza;
  String? selectedSexo;
  int? minPrice;
  int? maxPrice;

  void _openPriceFilterDialog() {
    int? tempMinPrice = minPrice;
    int? tempMaxPrice = maxPrice;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Filtrar por Precio"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Precio mínimo"),
              onChanged: (value) => tempMinPrice = int.tryParse(value),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Precio máximo"),
              onChanged: (value) => tempMaxPrice = int.tryParse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Quitar filtro"),
            onPressed: () {
              setState(() {
                minPrice = null;
                maxPrice = null;
              });
              widget.onMinPriceChanged(0);
              widget.onMaxPriceChanged(1000);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Aplicar"),
            onPressed: () {
              setState(() {
                minPrice = tempMinPrice;
                maxPrice = tempMaxPrice;
              });
              widget.onMinPriceChanged(minPrice ?? 0);
              widget.onMaxPriceChanged(maxPrice ?? 1000);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Búsqueda por texto
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

          // Filtros de raza, sexo, precio y ubicación
          if (widget.showFilters) ...[
            Row(
              children: [
                // Filtro de raza
                Expanded(
                  child: _buildFilterButton(
                    label: selectedRaza ?? 'Raza',
                    items: widget.razas,
                    onSelected: (value) {
                      setState(() {
                        selectedRaza = value;
                      });
                      widget.onRazaFilterChanged(value);
                    },
                  ),
                ),
                SizedBox(width: 8.0),

                // Filtro de sexo
                Expanded(
                  child: _buildFilterButton(
                    label: selectedSexo ?? 'Sexo',
                    items: ['Macho', 'Hembra'],
                    onSelected: (value) {
                      setState(() {
                        selectedSexo = value;
                      });
                      widget.onSexoFilterChanged(value);
                    },
                  ),
                ),
                SizedBox(width: 8.0),

                // Filtro de precio con botón que abre el diálogo
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openPriceFilterDialog,
                    child: Text(
                      minPrice != null || maxPrice != null
                          ? 'Precio: ${minPrice ?? 0} - ${maxPrice ?? '∞'}€'
                          : 'Precio',
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Botón de ubicación si `showLocationFilter` es `true`
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

  // Widget personalizado para el botón de filtro
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
              height: 300,
              child: ListView.builder(
                itemCount: items.length + 1,
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
