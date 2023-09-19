import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CNP Chat Bot',
      theme: ThemeData(
        primaryColor: Colors.red[900],
        hintColor: Colors.redAccent[700],
        brightness: Brightness.light,
        primarySwatch: Colors.red,
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.red[900],
        hintColor: Colors.redAccent[700],
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('CNP designs AI assistant, warning Deathstar deletes chat, cant be undone!'),
            const SizedBox(height: 20),
            ElevatedButton(child: const Text('Start Chat'),
              onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatScreen()),
               );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController textEditingController = TextEditingController();
  final String apiKey = 'pk-this-is-a-real-free-pool-token-for-everyone'; // Replace with your API key
  final String apiUrl = 'https://ai.fakeopen.com/v1/chat/completions'; final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadChatMessages().then((loadedMessages) {
      setState(() {
        messages = loadedMessages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CNPbot'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.deathStarVariant),
            onPressed: () {
              deleteChat();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Reverse the order of messages
              controller: scrollController, // Attach the ScrollController
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final reversedIndex = messages.length - 1 - index;
                final message = messages[reversedIndex];
                const userAvatar = AssetImage('assets/user_avatar.png');
                const assistantAvatar =
                AssetImage('assets/assistant_avatar.png');
                if (kDebugMode) {
                  print('userAvatar: $userAvatar');
                }
                if (kDebugMode) {
                  print('assistantAvatar: $assistantAvatar');
                }


                return ChatBubble(
                  message: message,
                  userAvatar: const AssetImage('assets/images/user_avatar.png'),
                  assistantAvatar:
                  const AssetImage('assets/images/assistant_avatar.png'),

                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextField(
                      cursorColor: Colors.red,
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(16),
                        fillColor: Colors.transparent,
                      ),
                      maxLines: null,
                      onSubmitted: (text) {
                        sendMessage(text);
                        textEditingController.clear();
                      }),
                ),
                IconButton(
                  icon: Icon(MdiIcons.deathlyHallows),
                  onPressed: () {
                    sendMessage(textEditingController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        messages.add(Message(
          text: text,
          sender: 'You',
          timestamp: DateTime.now(),
        ));
      });
      textEditingController.clear();

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'messages': [
              {'role': 'system', 'content': 'user'},
              {'role': 'user', 'content': text},
            ],
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          final assistantReply = result['choices'][0]['message']['content'];

          setState(() {
            messages.add(Message(
              text: assistantReply,
              sender: 'CNPbot',
              timestamp: DateTime.now(),
            ));
          });

          // Scroll to the latest message
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          // Save chat messages
          await saveChatMessages(messages);
        } else {
          if (kDebugMode) {
            print('Error: ${response.statusCode}${response.reasonPhrase}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error sending message: $e');
        }
      }
    }
  }

  Future<void> saveChatMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages =
    messages.map((message) => message.toJson()).toList();
    await prefs.setString('chat_messages', jsonEncode(encodedMessages));
  }

  Future<List<Message>> loadChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages = prefs.getString('chat_messages');
    if (encodedMessages != null) {
      final decodedMessages = jsonDecode(encodedMessages) as List<dynamic>;
      final messages =
      decodedMessages.map((data) => Message.fromJson(data)).toList();
      return messages;
    }
    return [];
  }

  // void resetChat() async {
  //   setState(() {
  //     messages.clear();
  //   });
  //   textEditingController.clear();
  //   await saveChatMessages(messages);
  // }

  void deleteChat() async {
    setState(() {
      messages.clear();
    });
    textEditingController.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
  }
}

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final AssetImage userAvatar;
  final AssetImage assistantAvatar;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.userAvatar,
    required this.assistantAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'You';

    final formattedTime = DateFormat('h:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  backgroundImage: assistantAvatar,
                  radius: 14.0,
                ),
                const SizedBox(width: 6.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${message.sender}:',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: isUser ? TextAlign.end : TextAlign.start,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isUser ? Colors.grey[300] : Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        message.text,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: isUser ? Colors.black : Colors.white,
                        ),
                        textAlign: isUser ? TextAlign.end : TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundImage: userAvatar,
                  radius: 14.0,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 12.0),
            textAlign: isUser ? TextAlign.end : TextAlign.start,
          ),
        ],
      ),
    );
  }
}