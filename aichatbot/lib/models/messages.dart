import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/style.dart';

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final Function onAnimatedTextFinished;

  const Messages({
    Key? key,
    required this.isUser,
    required this.message,
    required this.date,
    required this.onAnimatedTextFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? userChat : resChat,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: !isUser ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            GestureDetector(
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(text: message));
              },
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    message,
                    textStyle: messageText,
                  ),
                ],
                totalRepeatCount: 1,
                isRepeatingAnimation: false,
                onFinished: () {
                  onAnimatedTextFinished();
                },
              ),
            ),
          if (isUser)
            Text(
              message,
              style: messageText,
            ),
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              Text(
                "\n$date",
                style: dateText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
