import 'package:flutter/material.dart';
import '../../widgets/colors_utils.dart';

class LegalInfoScreen extends StatelessWidget {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información Legal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Bienvenido a nuestra aplicación dedicada a usuarios, comercios y criadores de perros. '
                'Por favor, lea detenidamente la información legal antes de continuar usando la aplicación.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Términos y Condiciones'),
              _buildBulletText(
                '1. Aceptación de Términos',
                'Al acceder y utilizar nuestra aplicación, aceptas cumplir con los términos y condiciones aquí descritos. '
                'Si no estás de acuerdo, por favor no utilices la aplicación.',
              ),
              _buildBulletText(
                '2. Uso de la Aplicación',
                'La aplicación está diseñada para conectar usuarios con comercios y criadores de perros. '
                'No garantizamos la disponibilidad ni la exactitud de la información proporcionada por terceros.',
              ),
              _buildBulletText(
                '3. Responsabilidad del Usuario',
                'Es responsabilidad del usuario proporcionar información precisa y completa en la aplicación. '
                'Nos reservamos el derecho de eliminar contenido inapropiado.',
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Política de Privacidad'),
              _buildBulletText(
                '1. Recolección de Información',
                'Recopilamos información personal necesaria para conectar a usuarios, comercios, y criadores de perros. '
                'Esta información incluye nombre, correo electrónico, y ubicación del comercio o criador.',
              ),
              _buildBulletText(
                '2. Uso de la Información',
                'Utilizamos la información para mejorar los servicios de la aplicación. No compartimos tu información personal '
                'con terceros sin tu consentimiento, excepto cuando sea necesario para proveer los servicios solicitados.',
              ),
              _buildBulletText(
                '3. Seguridad de la Información',
                'Tomamos medidas razonables para proteger tu información personal contra accesos no autorizados y divulgación.',
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Modificaciones de Términos'),
              Text(
                'Nos reservamos el derecho de modificar estos términos y condiciones en cualquier momento. '
                'Te notificaremos de cualquier cambio significativo en la aplicación. Se recomienda revisar esta sección periódicamente.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Contacto'),
              Text(
                'Si tienes preguntas sobre estos términos o sobre la política de privacidad, contáctanos a través de la sección de contacto en la aplicación.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper para el título de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // Widget Helper para el texto de los términos y condiciones
  Widget _buildBulletText(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.white),
          children: [
            TextSpan(
              text: '$title\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }
}
