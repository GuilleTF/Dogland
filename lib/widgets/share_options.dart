// widgets/share_options.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ShareOptions extends StatelessWidget {
  final String shareText;
  final String url;

  const ShareOptions({
    Key? key,
    required this.shareText,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Compartir'),
          onTap: () {
            // Verifica que el texto no esté vacío antes de compartir
            if (url.isNotEmpty) {
              Share.share('$shareText $url');
            }
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.link),
          title: Text('Copiar enlace'),
          onTap: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Enlace copiado al portapapeles')),
            );
          },
        ),
      ],
    );
  }
}
