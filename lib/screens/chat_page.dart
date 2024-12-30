import 'package:flutter/material.dart';

import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService chatService = ChatService();
  List<Map<String, dynamic>> chats = [];
  List<Map<String, dynamic>> messages = [];
  String? selectedUserEmail;
  bool isLoading = true;
  final TextEditingController _messageController = TextEditingController();

  final Color secondaryColor = const Color(0xFFB2EBF2);

  @override
  void initState() {
    super.initState();
    _fetchAllChats();
  }

  Future<void> _fetchAllChats() async {
    setState(() {
      isLoading = true;
    });

    final chatData = await chatService.getAllChats();

    setState(() {
      chats = chatData.map((chat) {
        chat['unreadCount'] = chat['unreadCount'] ?? 0;
        chat['lastUpdated'] = chat['lastUpdated'] ?? DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
        return chat;
      }).toList();
      chats.sort((a, b) {
        if (b['unreadCount'] != a['unreadCount']) {
          return b['unreadCount'].compareTo(a['unreadCount']);
        }
        return b['lastUpdated'].compareTo(a['lastUpdated']);
      });

      isLoading = false;
    });
  }




  Future<void> _fetchUserMessages(String userEmail) async {
    setState(() {
      isLoading = true;
      selectedUserEmail = userEmail;
    });

    final messageData = await chatService.getUserMessages(userEmail);

    setState(() {
      messages = messageData;

      final chatIndex = chats.indexWhere((chat) => chat['userEmail'] == userEmail);
      if (chatIndex != -1) {
        final updatedChat = chats.removeAt(chatIndex);
        updatedChat['unreadCount'] = 0; 
        updatedChat['lastUpdated'] = DateTime.now().toIso8601String(); 
        chats.insert(0, updatedChat); 
      }
      isLoading = false;
    });
  }



  Future<void> _sendMessage(String userEmail, String message) async {
    await chatService.sendMessageToUser(userEmail, message);
    _fetchUserMessages(userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat System'),
        backgroundColor: secondaryColor,
        centerTitle: true,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: isLoading && chats.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundColor: secondaryColor.withOpacity(0.7),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        if (chat['unreadCount'] > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${chat['unreadCount']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      chat['userEmail'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      chat['lastMessage'] ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    onTap: () {
                      _fetchUserMessages(chat['userEmail']);
                      setState(() {
                        chat['unreadCount'] = 0; 
                      });
                    },
                  ),

                );
              },
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: selectedUserEmail == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Select a chat to view messages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : Column(
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSentByAdmin =
                          message['sentBy'] == 'admin';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: Align(
                          alignment: isSentByAdmin
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSentByAdmin
                                    ? [
                                  secondaryColor,
                                  secondaryColor.withOpacity(0.8),
                                ]
                                    : [
                                  Colors.grey[300]!,
                                  Colors.grey[200]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              message['body'] ?? '',
                              style: TextStyle(
                                color: isSentByAdmin
                                    ? Colors.black
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            fillColor: Colors.grey[200],
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                        ),
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(
                              selectedUserEmail!,
                              _messageController.text,
                            );
                            _messageController.clear();
                          }
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.send, color: Color(0xFF5AA5B1)),
                            SizedBox(width: 8),
                            Text('Send', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
