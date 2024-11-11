// home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dogland/widgets/home_app_bar.dart';
import 'package:dogland/widgets/home_content.dart';
import 'package:dogland/widgets/comercios_stack.dart';
import 'package:dogland/screens/perfil_screen.dart';
import 'package:dogland/widgets/bottom_navbar.dart';
import 'package:dogland/screens/login/login_screen.dart';
import 'package:dogland/screens/perros/mis_perros_screen.dart';
import 'package:dogland/screens/perros/perro_form_screen.dart';
import 'package:dogland/widgets/perros_stack.dart';
import 'package:dogland/screens/favorites_screen.dart'; // Importación manual de FavoritesScreen
import 'package:dogland/screens/mensajes/chats_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _comerciosIndex = 0;
  int _perrosIndex = 0;
  int? _misPerrosIndex;
  Map<String, dynamic>? _selectedCriadorData;
  Map<String, dynamic>? _selectedPerroData;
  Map<String, dynamic>? _selectedComercioData;

  static const int agregarPerroIndex = 2;
  static const int editarPerroIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _misPerrosIndex = null;
      _comerciosIndex = 0;
      _perrosIndex = 0;
    });
  }

  void _selectComercio(Map<String, dynamic> comercioData) {
    setState(() {
      if (comercioData.containsKey('id') && comercioData['id'] != null) {
        _selectedComercioData = {
          'comercioId': comercioData['id'], // Asegura que 'id' no esté vacío
          'username': comercioData['username'] ?? 'Nombre no disponible',
          'description': comercioData['description'] ?? 'Descripción no disponible',
          'businessImages': List<String>.from(comercioData['businessImages'] ?? []),
          'phoneNumber': comercioData['phoneNumber'] ?? 'No disponible',
          'email': comercioData['email'] ?? 'No disponible',
          'location': comercioData['location'],
          'profileImage': comercioData['profileImage'] ?? ''
        };
        _comerciosIndex = 1;
      } else {
        print("Error: comercioId no disponible en comercioData");
      }
    });
  }

  void _goBackToComercios() {
    setState(() {
      _comerciosIndex = 0;
      _selectedComercioData = null;
    });
  }

  void _selectCriador(Map<String, dynamic> criadorData) {
    setState(() {
      _selectedCriadorData = criadorData;
      _perrosIndex = 1;
    });
  }

  void _selectPerro(Map<String, dynamic> perroData) {
    setState(() {
      _selectedPerroData = perroData;
      _perrosIndex = 2;
    });
  }

  void _goBackToPerros() {
    setState(() {
      _perrosIndex = _perrosIndex > 1 ? 1 : 0;
      if (_perrosIndex == 0) _selectedCriadorData = null;
      _selectedPerroData = null;
    });
  }

  void _goBackToInicio() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  void _goToMisPerros() {
    setState(() {
      _misPerrosIndex = 1;
    });
  }

  void _goToAgregarPerro() {
    setState(() {
      _misPerrosIndex = agregarPerroIndex;
    });
  }

  void _onPerroGuardado() {
    setState(() {
      _misPerrosIndex = 1;
    });
  }

  void _goToEditarPerro(Map<String, dynamic> perro) {
    setState(() {
      _selectedPerroData = perro;
      _misPerrosIndex = editarPerroIndex;
    });
  }

  String _getTitle() {
    if (_misPerrosIndex == agregarPerroIndex) return 'Agregar Perro';
    if (_misPerrosIndex == editarPerroIndex) return 'Editar Perro';
    if (_misPerrosIndex == 1) return 'Mis Perros';
    if (_selectedIndex == 4 && _comerciosIndex == 1 && _selectedComercioData != null) {
      return _selectedComercioData!['username'] ?? 'Comercio';
    }
    if (_selectedIndex == 5 && _perrosIndex == 1 && _selectedCriadorData != null) {
      return _selectedCriadorData!['username'] ?? 'Criador';
    }
    if (_selectedIndex == 5 && _perrosIndex == 2 && _selectedPerroData != null) {
      return _selectedPerroData!['raza'] ?? 'Perro';
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
        return 'Perros';
      default:
        return 'Inicio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: _getTitle(),
        onLogout: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          });
        },
        onBackPressed: () {
          if (_misPerrosIndex == 1) {
            setState(() {
              _misPerrosIndex = null;
              _selectedIndex = 3;
            });
          } else if (_misPerrosIndex == agregarPerroIndex ||
              _misPerrosIndex == editarPerroIndex) {
            setState(() {
              _misPerrosIndex = 1;
            });
          } else if (_comerciosIndex == 1) {
            _goBackToComercios();
          } else if (_perrosIndex == 1 || _perrosIndex == 2) {
            _goBackToPerros();
          } else {
            _goBackToInicio();
          }
        },
        showBackButton: _misPerrosIndex != null ||
            _comerciosIndex == 1 ||
            _selectedIndex == 4 ||
            _perrosIndex > 0 ||
            _selectedIndex == 5,
      ),
      body: IndexedStack(
        index: _misPerrosIndex != null ? 6 : _selectedIndex,
        children: [
          HomeContent(
            onComerciosTapped: () => _onItemTapped(4),
            onPerrosTapped: () => _onItemTapped(5),
          ),
          FavoritesScreen(
            onPerroSelected: (perroData) async {
              final criadorSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(perroData['criador'])
                  .get();
              if (criadorSnapshot.exists) {
                final criadorData = criadorSnapshot.data() as Map<String, dynamic>;
                setState(() {
                  _selectedPerroData = {
                    'perroId': perroData['perroId'],
                    'perro': perroData['perro'],
                    'criador': criadorData,
                  };
                  _perrosIndex = 2;
                  _selectedIndex = 5;
                });
              }
            },
            onComercioSelected: (comercioData) {
              setState(() {
                _selectedComercioData = comercioData;
                _comerciosIndex = 1;
                _selectedIndex = 4;
              });
            },
          ),
          ChatsListScreen(userId: FirebaseAuth.instance.currentUser!.uid),
          PerfilScreen(onMisPerrosTapped: _goToMisPerros),
          ComerciosStack(
            comerciosIndex: _comerciosIndex,
            selectedComercioData: _selectedComercioData,
            onComercioSelected: _selectComercio,
            onBackPressed: _goBackToComercios,
          ),
          PerrosStack(
            perrosIndex: _perrosIndex,
            selectedCriadorData: _selectedCriadorData,
            selectedPerroData: _selectedPerroData,
            onCriadorSelected: _selectCriador,
            onPerroSelected: _selectPerro,
            onBackPressed: _goBackToPerros,
          ),
          _misPerrosIndex == agregarPerroIndex
              ? PerroFormScreen(onPerroGuardado: _onPerroGuardado)
              : _misPerrosIndex == editarPerroIndex && _selectedPerroData != null
                  ? PerroFormScreen(perro: _selectedPerroData, onPerroGuardado: _onPerroGuardado)
                  : MisPerrosScreen(
                      onAgregarPerroTapped: _goToAgregarPerro,
                      onEditarPerroTapped: _goToEditarPerro,
                    ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
