import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home_screen.dart';
import '../../widgets/colors_utils.dart';
import 'legal_info_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _loginUser(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      final String email = formData?['email'];
      final String password = formData?['password'];

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Evita el solapamiento del teclado
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
          child: Center(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Evita que el contenido se extienda al fondo
                children: [
                  Image.asset(
                    'assets/images/dogland_logo.png',
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  FormBuilderTextField(
                    name: 'password',
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: FormBuilderValidators.required(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _loginUser(context),
                    child: Text('Iniciar Sesión'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Registrarse',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LegalInfoScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Términos y Política de Privacidad',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
