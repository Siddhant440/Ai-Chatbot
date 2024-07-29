import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference messages = FirebaseFirestore.instance.collection('messages');

  Future<void> addMessage(String message) {
    return messages.add({
      'message': message,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateMessage(String docID, String newMessage) {
    return messages.doc(docID).update({
      'message': newMessage,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteMessage(String docID) {
    return messages.doc(docID).delete();
  }

  Stream<QuerySnapshot> getMessagesStream() {
    final messagesStream = messages.orderBy('timestamp', descending: true).snapshots();
    return messagesStream;
  }
}
