import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../utils/style.dart';
import 'message_card.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final Stream<QuerySnapshot> messagesStream;
  final FireStoreService firestoreService;

  const CustomDrawer({
    super.key,
    required this.onClose,
    required this.messagesStream,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        color: Colors.grey.shade900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                color: Colors.grey.shade900,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: onClose,
                        ),
                        Text('History', style: TextStyle(color: uiText, fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No History Available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final messageText = message['message'] ?? '';
                      final timestamp = (message['timestamp'] as Timestamp?)?.toDate();
                      final docID = message.id;

                      return MessageCard(
                        messageText: messageText,
                        timestamp: timestamp,
                        onDelete: () {
                          firestoreService.deleteMessage(docID);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

