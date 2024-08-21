import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'main.dart';

class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  List<String> chatRooms = [
    '채팅방 1',
    '채팅방 2',
    '채팅방 3',
  ];

  final TextEditingController _newRoomController = TextEditingController();

  void _addChatRoom() {
    final String newRoomName = _newRoomController.text.trim();
    if (newRoomName.isNotEmpty) {
      setState(() {
        chatRooms.add(newRoomName);
        _newRoomController.clear();
      });
      Navigator.of(context).pop(); // 다이얼로그 닫기
    }
  }

  void _showAddChatRoomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 채팅방 추가'),
          content: TextField(
            controller: _newRoomController,
            decoration: InputDecoration(hintText: '채팅방 이름을 입력하세요'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: _addChatRoom,
            ),
          ],
        );
      },
    );
  }

  void _removeChatRoom(String roomName) {
    setState(() {
      chatRooms.remove(roomName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddChatRoomDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(chatRooms[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    roomName: chatRooms[index],
                    onLeaveRoom: () => _removeChatRoom(chatRooms[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text('홈으로 이동'),
          ),
        ),
      ),
    );
  }
}
