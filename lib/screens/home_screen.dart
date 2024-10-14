import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navbar.dart';
import 'login/login_screen.dart';
import 'comercios/comercios_screen.dart';
import 'perros/razas_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeContent(), // Pantalla de inicio con botones dinámicos
      Container(color: Colors.red), // Favoritos (Placeholder)
      Container(color: Colors.blue), // Mensajes (Placeholder)
      Container(color: Colors.green), // Perfil (Placeholder)
      ComerciosScreen(), // Pantalla de Comercios
      RazasScreen(), // Pantalla de Razas de Perros
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Favoritos';
      case 2:
        return 'Mensajes';
      case 3:
        return ''; // Perfil sin AppBar
      case 4:
        return 'Comercios';
      case 5:
        return 'Razas de Perros';
      default:
        return 'Inicio';
    }
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 4; // Navegar a Comercios
              });
            },
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
                    Icon(
                      Icons.store,
                      size: 100,
                      color: Colors.black,
                    ),
                    Text(
                      'Comercios',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 5; // Navegar a Razas de Perros
              });
            },
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
                    Icon(
                      Icons.pets,
                      size: 100,
                      color: Colors.black,
                    ),
                    Text(
                      'Perros',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 3 ? null : AppBar(
        backgroundColor: Colors.purple,
        title: Text(_getTitle()),
        leading: (_selectedIndex == 4 || _selectedIndex == 5)
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _onItemTapped(0), // Regresar a inicio
              )
            : null,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(Icons.logout),
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
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex <= 3 ? _selectedIndex : 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
