import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final String messageText;
  final DateTime? timestamp;
  final VoidCallback onDelete;

  const MessageCard({super.key,
    required this.messageText,
    required this.timestamp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            messageText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')} ${timestamp!.day}/${timestamp!.month}/${timestamp!.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.red,
                      size: 20
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
