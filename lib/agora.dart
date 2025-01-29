import 'package:flutter/material.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class AgoraChatConfig {
  static const String appKey = "43473c32f2d34edda79c9bf75ce6a909";
  static const String userId = "Nag Isa";
  static const String agoraToken = "<#User Token#>";
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController scrollController = ScrollController();
  String? _messageContent, _chatId;
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("User ID: ${AgoraChatConfig.userId}"),
            const Text("Token: ${AgoraChatConfig.agoraToken}"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text("Sign In"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _signOut,
                    child: const Text("Sign Out"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(hintText: "Recipient User ID"),
              onChanged: (value) => _chatId = value,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Message Content"),
              onChanged: (value) => _messageContent = value,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text("Send Message"),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _logText.length,
                itemBuilder: (context, index) => Text(_logText[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SDK Initialization
  void _initSDK() async {
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
  }

  // Chat Listener
  void _addChatListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      "CHAT_HANDLER",
      ChatEventHandler(onMessagesReceived: _onMessagesReceived),
    );
  }

  void _onMessagesReceived(List<ChatMessage> messages) {
    for (var message in messages) {
      if (message.body.type == MessageType.TXT) {
        ChatTextMessageBody body = message.body as ChatTextMessageBody;
        _addLog("Message from ${message.from}: ${body.content}");
      }
    }
  }

  // Sign In
  void _signIn() async {
    try {
      await ChatClient.getInstance.loginWithToken(
        AgoraChatConfig.userId,
        AgoraChatConfig.agoraToken,
      );
      _addLog("Signed in successfully.");
    } catch (e) {
      _addLog("Sign in failed: $e");
    }
  }

  // Sign Out
  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLog("Signed out successfully.");
    } catch (e) {
      _addLog("Sign out failed: $e");
    }
  }

  // Send Message
  void _sendMessage() async {
    if (_chatId == null || _messageContent == null) {
      _addLog("Recipient or message content is missing.");
      return;
    }

    var message = ChatMessage.createTxtSendMessage(
      targetId: _chatId!,
      content: _messageContent!,
    );

    try {
      await ChatClient.getInstance.chatManager.sendMessage(message);
      _addLog("Message sent to $_chatId: $_messageContent");
    } catch (e) {
      _addLog("Message sending failed: $e");
    }
  }

  // Add Log
  void _addLog(String log) {
    setState(() {
      _logText.add("${DateTime.now()}: $log");
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler("CHAT_HANDLER");
    super.dispose();
  }
}
