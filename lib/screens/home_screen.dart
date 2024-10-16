import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navbar.dart';
import 'login/login_screen.dart';
import 'comercios/comercios_screen.dart';
import 'perros/razas_screen.dart';
import 'perfil_screen.dart';
import 'comercios/comercio_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _comerciosIndex = 0;
  Map<String, dynamic>? _selectedComercioData;

  final String userRole = 'comerciante';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectComercio(Map<String, dynamic> comercioData) {
    setState(() {
      _selectedComercioData = comercioData;
      _comerciosIndex = 1;
    });
  }

  void _goBackToComercios() {
    setState(() {
      _comerciosIndex = 0;
      _selectedComercioData = null;
    });
  }

  void _goBackToInicio() {
    setState(() {
      _selectedIndex = 0; // Regresa a Inicio
    });
  }

  String _getTitle() {
    if (_selectedIndex == 4 && _comerciosIndex == 1 && _selectedComercioData != null) {
      return _selectedComercioData!['username'] ?? 'Comercio';
    }
    switch (_selectedIndex) {
      case 1:
        return 'Favoritos';
      case 2:
        return 'Mensajes';
      case 3:
        return 'Perfil';
      case 4:
        return 'Comercios';
      case 5:
        return 'Razas de Perros';
      default:
        return 'Inicio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          _getTitle(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: (_selectedIndex == 4)
            ? IconButton(
                icon: Icon(
                  _comerciosIndex == 1 ? Icons.arrow_back : Icons.home,
                  color: Colors.white,
                ),
                onPressed: _comerciosIndex == 1 ? _goBackToComercios : _goBackToInicio,
              )
            : null,
        actions: [
          if (_selectedIndex == 3)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                });
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          Container(color: Colors.red),
          Container(color: Colors.blue),
          PerfilScreen(role: userRole),
          _buildComerciosStack(),
          RazasScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildComerciosStack() {
    return IndexedStack(
      index: _comerciosIndex,
      children: [
        ComerciosScreen(onComercioSelected: _selectComercio),
        if (_selectedComercioData != null)
          ComercioScreen(
            nombre: _selectedComercioData!['username'] ?? 'Nombre no disponible',
            descripcion: _selectedComercioData!['description'] ?? 'Sin descripción',
            imagenes: List<String>.from(_selectedComercioData!['businessImages'] ?? []),
            telefono: _selectedComercioData!['phoneNumber'] ?? 'No disponible',
            correo: _selectedComercioData!['email'] ?? 'No disponible',
            ubicacion: _selectedComercioData!['location'] != null
                ? LatLng(
                    _selectedComercioData!['location'].latitude,
                    _selectedComercioData!['location'].longitude,
                  )
                : LatLng(0, 0),
          ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _onItemTapped(4),
            child: Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 100, color: Colors.black),
                    Text('Comercios', style: TextStyle(fontSize: 24, color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _onItemTapped(5),
            child: Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 100, color: Colors.black),
                    Text('Perros', style: TextStyle(fontSize: 24, color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
