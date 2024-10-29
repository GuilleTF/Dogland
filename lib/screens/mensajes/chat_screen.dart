import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String userId;
  final String recipientId;

  ChatScreen({required this.chatId, required this.userId, required this.recipientId});

  final _controller = TextEditingController();

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    FirebaseFirestore.instance.collection('chats/$chatId/messages').add({
      'text': text,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats/$chatId/messages')
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
                    final isMe = message['senderId'] == userId;
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
