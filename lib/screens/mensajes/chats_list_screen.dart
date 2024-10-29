import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogland/screens/mensajes/chat_screen.dart';

class ChatsListScreen extends StatelessWidget {
  final String userId;

  ChatsListScreen({required this.userId});

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final recipientId = users.firstWhere((id) => id != userId, orElse: () => 'Desconocido');
              final lastMessage = (chat.data() as Map<String, dynamic>).containsKey('lastMessage')
                  ? chat['lastMessage']
                  : '';

              return FutureBuilder<Map<String, dynamic>?>(
                future: getUserInfo(recipientId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(title: Text("Cargando..."));
                  }
                  final userInfo = userSnapshot.data!;
                  final profileImageUrl = userInfo['profileImage'];
                  final userName = userInfo['username'] ?? 'Usuario';

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                         backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl as String)  // Explicitly cast to String
                            : null,
                        child: profileImageUrl == null
                            ? Icon(Icons.person, size: 30, color: Colors.grey)
                            : null,
                      ),
                      title: Text(userName, style: TextStyle(color: Colors.black)),
                      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
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
