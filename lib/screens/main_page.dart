import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CareerPage(),
    CareerEditPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('호적메이트'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '커리어 작성',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: '커리어 수정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: SizedBox.shrink(),
      ),
    );
  }
}

class CareerPage extends StatefulWidget {
  @override
  _CareerPageState createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String responseText = "커리어 저장 후 분석 결과가 여기에 표시됩니다.";

  Future<void> _saveCareer() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    // Send data to OpenAI for analysis
    await _getResponseFromOpenAI(title, description);

    // Show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('커리어가 저장되었습니다.')),
    );
  }

  Future<void> _getResponseFromOpenAI(String title, String description) async {
    const apiKey = 'YOUR_API_KEY_HERE';  // Replace with your API Key
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "You are a helpful assistant that analyzes career entries."},
            {"role": "user", "content": "Analyze this career data: Title: $title, Description: $description"},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          responseText = data['choices'][0]['message']['content'];
        });
      } else {
        setState(() {
          responseText = "Failed to get a response from OpenAI.";
        });
      }
    } catch (e) {
      setState(() {
        responseText = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개인 커리어 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '커리어 제목'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '경력 상세 설명'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCareer,
              child: Text('작성 완료'),
            ),
            SizedBox(height: 20),
            Text(
              responseText,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class CareerEditPage extends StatefulWidget {
  @override
  _CareerEditPageState createState() => _CareerEditPageState();
}

class _CareerEditPageState extends State<CareerEditPage> {
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editDescriptionController = TextEditingController();

  String? savedEditTitle;
  String? savedEditDescription;

  void _editCareer() {
    setState(() {
      savedEditTitle = _editTitleController.text;
      savedEditDescription = _editDescriptionController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('커리어가 수정되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개인 커리어 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _editTitleController,
              decoration: InputDecoration(labelText: '수정할 커리어 제목'),
            ),
            TextField(
              controller: _editDescriptionController,
              decoration: InputDecoration(labelText: '경력 상세 수정 내용'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editCareer,
              child: Text('수정 완료'),
            ),
            if (savedEditTitle != null && savedEditDescription != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '수정된 커리어:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('제목: $savedEditTitle'),
                    Text('설명: $savedEditDescription'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
