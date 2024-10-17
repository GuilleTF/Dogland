// home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dogland/widgets/home_app_bar.dart';
import 'package:dogland/widgets/home_content.dart';
import 'package:dogland/widgets/comercios_stack.dart';
import 'package:dogland/screens/perfil_screen.dart';
import 'package:dogland/screens/perros/razas_screen.dart';
import 'package:dogland/widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _comerciosIndex = 0;
  Map<String, dynamic>? _selectedComercioData;

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
      _selectedIndex = 0;
    });
  }

  String _getTitle() {
    if (_selectedIndex == 4 && _comerciosIndex == 1 && _selectedComercioData != null) {
      return _selectedComercioData!['username'] ?? 'Comercio';
    }
    switch (_selectedIndex) {
      case 1: return 'Favoritos';
      case 2: return 'Mensajes';
      case 3: return 'Perfil';
      case 4: return 'Comercios';
      case 5: return 'Razas de Perros';
      default: return 'Inicio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: _getTitle(),
        onLogout: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        },
        onBackPressed: _comerciosIndex == 1 ? _goBackToComercios : _goBackToInicio,
        showBackButton: _selectedIndex == 4,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeContent(
            onComerciosTapped: () => _onItemTapped(4),
            onPerrosTapped: () => _onItemTapped(5),
          ),
          Container(color: Colors.red), // Placeholder for Favoritos
          Container(color: Colors.blue), // Placeholder for Mensajes
          PerfilScreen(role: 'comerciante'),
          ComerciosStack(
            comerciosIndex: _comerciosIndex,
            selectedComercioData: _selectedComercioData,
            onComercioSelected: _selectComercio,
            onBackPressed: _goBackToComercios,
          ),
          RazasScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
