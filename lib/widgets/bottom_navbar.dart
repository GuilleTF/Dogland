import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,  // Ajusta la altura del BottomNavigationBar
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // Fija el tipo para que siempre se muestre el texto
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(size: 35),  // Aumentar tamaño del ícono seleccionado
        unselectedIconTheme: IconThemeData(size: 30), // Aumentar tamaño del ícono no seleccionado
        selectedLabelStyle: TextStyle(fontSize: 14),  // Tamaño del texto para ítems seleccionados
        unselectedLabelStyle: TextStyle(fontSize: 12), // Tamaño del texto para ítems no seleccionados
        onTap: onTap,
      ),
    );
  }
}
