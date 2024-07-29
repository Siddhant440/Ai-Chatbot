import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import '../utils/style.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  final List<Message> _messages = [];
  final Set<int> _loadingMessageIndices = <int>{};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FireStoreService _firestoreService = FireStoreService();
  bool _isDrawerOpen = false;

  static const apiKey = "AIzaSyC3131iduJlGnm3d3YmDCZMLkY_qi61jHc";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  void sendMessage() async {
    final userInput = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: userInput,
        date: DateTime.now(),
      ));
    });

    await _firestoreService.addMessage(userInput);

    final placeholderIndex = _messages.length;
    setState(() {
      _messages.add(Message(
        isUser: false,
        message: "",
        date: DateTime.now(),
      ));
      _loadingMessageIndices.add(placeholderIndex);
    });

    try {
      final content = [Content.text(userInput)];
      final response = await model.generateContent(content);

      setState(() {
        _messages[placeholderIndex] = Message(
          isUser: false,
          message: response.text ?? "Sorry, I couldn't generate a response.",
          date: DateTime.now(),
        );
        _loadingMessageIndices.remove(placeholderIndex);
      });
    } catch (e) {
      setState(() {
        _messages[placeholderIndex] = Message(
          isUser: false,
          message: "Couldn't generate response. Please restart the app.",
          date: DateTime.now(),
        );
        _loadingMessageIndices.remove(placeholderIndex);
      });
    }
  }

  void showResponseCard(String text) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: background,
      appBar: CustomAppBar(
        title: "AI Chat Bot",
        backgroundColor: background,
        textColor: uiText,
        logo: "assets/images/gemini_logo.png",
        iconButton: const Icon(Icons.history),
        onPressed: _toggleDrawer,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return GestureDetector(
                        onTap: () {
                          if (!message.isUser) {
                            showResponseCard(message.message);
                          }
                        },
                        child: Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            padding: const EdgeInsets.all(12.0),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUser ? userChat : aiChat,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: _loadingMessageIndices.contains(index)
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/gifs/piyush_loading.gif",
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(width: 30),
                                Text(
                                  "Generating response...",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              message.message,
                              style: TextStyle(
                                color: message.isUser ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLines: 6,
                          minLines: 1,
                          controller: _userMessage,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(25, 0, 16, 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            hintText: 'Ask Here',
                            hintStyle: hintText,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                if (_userMessage.text.isNotEmpty) {
                                  sendMessage();
                                }
                              },
                              child: Icon(
                                Icons.send,
                                color: _userMessage.text.isNotEmpty
                                    ? userChat
                                    : disable,
                              ),
                            ),
                          ),
                          style: promptText.copyWith(color: Colors.white),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isDrawerOpen ? 0 : -MediaQuery.of(context).size.width * 0.7,
            top: 0,
            bottom: 0,
            child: CustomDrawer(
              onClose: _toggleDrawer,
              messagesStream: _firestoreService.getMessagesStream(),
              firestoreService: _firestoreService,
            ),
          ),
        ],
      ),
    );
  }
}
