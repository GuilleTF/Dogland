import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String recipientId;

  ChatScreen({required this.chatId, required this.userId, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    printUserUID(); // Llama a la función al inicio para ver el UID del usuario
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  Future<Map<String, dynamic>?> getRecipientInfo() async {
    final recipientDoc = await FirebaseFirestore.instance.collection('users').doc(widget.recipientId).get();
    return recipientDoc.exists ? recipientDoc.data() : null;
  }

  void printUserUID() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("UID del usuario autenticado: ${user.uid}");
    } else {
      print("Ningún usuario autenticado.");
    }
  }

  /// Función para imprimir los datos del chat desde Firestore
  Future<void> printChatDocument(String chatId) async {
    try {
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        print("Datos del chat:");
        print(chatDoc.data());  // Imprime los datos completos del documento de chat
        final users = chatDoc.data()?['users'] as List<dynamic>?;
        if (users != null) {
          print("Usuarios en el chat: ${users.join(', ')}");
        } else {
          print("El array 'users' no existe en el documento de chat.");
        }
      } else {
        print("No se encontró el documento de chat con el ID: $chatId");
      }
    } catch (e) {
      print("Error al obtener el documento de chat: $e");
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Llama a printChatDocument para ver el contenido del chat antes de enviar el mensaje
      await printChatDocument(widget.chatId);

      // Intenta enviar el mensaje
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': text,
        'senderId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Actualizar el último mensaje en el documento del chat
      await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final updatedChat = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
      print("Estado del chat después de enviar el mensaje: ${updatedChat.data()}");
      
      _controller.clear(); // Limpiar el campo de texto después de enviar

    } catch (e) {
      print("Error al enviar mensaje: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: getRecipientInfo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Cargando...");
            }
            final recipientInfo = snapshot.data!;
            final profileImageUrl = recipientInfo['profileImage'];
            final userName = recipientInfo['username'] ?? 'Usuario';

            return Center(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null ? Icon(Icons.person) : null,
                  ),
                  SizedBox(width: 10),
                  Text(
                    userName,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats/${widget.chatId}/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == widget.userId;
                    return ChatBubble(
                      clipper: ChatBubbleClipper5(type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
                      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                      margin: EdgeInsets.only(top: 10),
                      backGroundColor: isMe ? Colors.blue : Colors.grey[300],
                      child: Text(
                        message['text'],
                        style: TextStyle(color: isMe ? Colors.white : Colors.black),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Escribe un mensaje...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
