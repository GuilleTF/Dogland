import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../utils/colors_utils.dart';
import '../home_screen.dart';
import '../../data/tags.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  LatLng? _locationCoordinates;
  String? _selectedRole = 'Usuario';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  List<String> _selectedTags = [];

  Future<void> _registerUser() async {
    bool isFormValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isFormValid) return;

    final formData = _formKey.currentState?.value ?? {};
    String? email = formData['email'];
    String? password = formData['password'];
    String? confirmPassword = formData['confirm_password'];
    String? username = formData['username'];
    String? role = formData['role'];
    String? phoneNumber = formData['phone_number'];

    // Condicionales específicos para cada campo
    if (username == null || username.isEmpty) {
      _showError("Por favor, ingresa un nombre de usuario.");
      return;
    }

    if (email == null || email.isEmpty) {
      _showError("Por favor, ingresa un correo electrónico.");
      return;
    }

    if (password == null || password.isEmpty) {
      _showError("Por favor, ingresa una contraseña.");
      return;
    }

    if (confirmPassword == null || confirmPassword.isEmpty) {
      _showError("Por favor, confirma la contraseña.");
      return;
    }

    if (password != confirmPassword) {
      _showError("Las contraseñas no coinciden.");
      return;
    }

      if (role == null || role.isEmpty) {
      _showError("Por favor, selecciona un rol.");
      return;
    }

    if ((role == 'Comercio' || role == 'Criador') && _locationCoordinates == null) {
      _showError("Por favor, selecciona una ubicación.");
      return;
    }

    if ((role == 'Comercio' || role == 'Criador') && (phoneNumber == null || phoneNumber.isEmpty)) {
      _showError("Por favor, ingresa un número de teléfono.");
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'location': _locationCoordinates != null
            ? GeoPoint(_locationCoordinates!.latitude, _locationCoordinates!.longitude)
            : null,
        'tags': _selectedRole == 'Comercio' ? _selectedTags : null,
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError("Error al registrar el usuario: ${e.message}");
    } catch (e) {
      _showError("Error desconocido: $e");
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("CB2B93"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: ListView(
              children: [
                Image.asset(
                  'assets/images/dogland_logo.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'username',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre de Usuario',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                FormBuilderTextField(
                  name: 'email',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                FormBuilderTextField(
                  name: 'password',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: FormBuilderValidators.required(),
                ),
                FormBuilderTextField(
                  name: 'confirm_password',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    labelStyle: TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    (val) {
                      if (_formKey.currentState?.fields['password']?.value != val) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ]),
                ),
                FormBuilderDropdown<String>(
                  name: 'role',
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Selecciona tu Rol',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  items: ['Usuario', 'Comercio', 'Criador']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(color: Colors.black),
                            ),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.required(),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                if (_selectedRole == 'Comercio' || _selectedRole == 'Criador')
                  FormBuilderTextField(
                    name: 'phone_number',
                    focusNode: _phoneFocusNode,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Número de Teléfono',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.minLength(9, errorText: 'El número debe tener al menos 9 dígitos'),
                    ]),
                  ),
                if (_selectedRole == 'Comercio' || _selectedRole == 'Criador')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _locationController,
                      googleAPIKey: "AIzaSyCmf3PNr3CTGTwcGh5V5kFh1Fc4Tz8fjng",
                      inputDecoration: InputDecoration(
                        hintText: 'Buscar ubicación',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      debounceTime: 800,
                      isLatLngRequired: true,
                      focusNode: _locationFocusNode,
                      getPlaceDetailWithLatLng: (prediction) {
                        setState(() {
                          _locationCoordinates = LatLng(
                            double.tryParse(prediction.lat.toString()) ?? 0.0,
                            double.tryParse(prediction.lng.toString()) ?? 0.0,
                          );
                        });
                      },
                      itemClick: (prediction) {
                        _locationController.text = prediction.description ?? '';
                        setState(() {
                          _locationCoordinates = LatLng(
                            double.tryParse(prediction.lat.toString()) ?? 0.0,
                            double.tryParse(prediction.lng.toString()) ?? 0.0,
                          );
                        });
                      },
                    ),
                  ),
                if (_selectedRole == 'Comercio')
                  MultiSelectDialogField(
                    items: etiquetasDeComercio.map((tag) => MultiSelectItem(tag, tag)).toList(),
                    title: Text(
                      "Selecciona etiquetas",
                      style: TextStyle(color: Colors.black),
                    ),
                    selectedColor: Colors.blue,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    buttonText: Text(
                      "Etiquetas",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      setState(() {
                        _selectedTags = results.cast<String>();
                      });
                    },
                    chipDisplay: MultiSelectChipDisplay(
                      chipColor: Colors.white,
                      textStyle: TextStyle(color: Colors.black),
                      onTap: (value) {
                        setState(() {
                          _selectedTags.remove(value);
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerUser,
                  child: Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
