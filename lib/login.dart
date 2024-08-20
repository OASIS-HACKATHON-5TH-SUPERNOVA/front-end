import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _sendMessage({String? text, File? file, bool isImage = false}) {
    if (text != null && text.isNotEmpty) {
      setState(() {
        messages.add(Message(text: text, isMine: true));
        _controller.clear();
      });
    }

    if (file != null) {
      setState(() {
        messages.add(Message(file: file, isImage: isImage, isMine: true));
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _sendMessage(file: File(pickedFile.path), isImage: true);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      _sendMessage(file: File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return Align(
                  alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: message.isMine ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: message.isImage
                        ? Image.file(message.file!)
                        : message.file != null
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.attach_file, color: message.isMine ? Colors.white : Colors.black87),
                        Text(
                          message.file!.path.split('/').last,
                          style: TextStyle(
                            color: message.isMine ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      message.text!,
                      style: TextStyle(
                        color: message.isMine ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                  color: Colors.blueAccent,
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _pickFile,
                  color: Colors.blueAccent,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                    ),
                    onSubmitted: (value) {
                      _sendMessage(text: value);
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(text: _controller.text),
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String? text;
  final File? file;
  final bool isMine;
  final bool isImage;

  Message({this.text, this.file, required this.isMine, this.isImage = false});
}
