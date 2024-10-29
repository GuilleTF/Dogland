// mensajes/chats_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/screens/mensajes/chat_screen.dart';

class ChatsListScreen extends StatelessWidget {
  final String userId;

  ChatsListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);

              // Encuentra el ID del otro usuario en el chat (excluyendo el ID del usuario actual)
              final recipientId = users.firstWhere((id) => id != userId, orElse: () => 'Desconocido');

              return ListTile(
                title: Text('Chat with $recipientId'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                        userId: userId,
                        recipientId: recipientId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
