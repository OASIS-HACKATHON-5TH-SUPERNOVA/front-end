import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String responseText = "Awaiting response...";

  Future<void> getResponseFromOpenAI() async {
    const apiKey = '';
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
            {"role": "system", "content": "당신은 사용자의 입력을 바탕으로 자기 소개서를 분석해야 합니다."},
            {"role": "user", "content": "안녕하세요! 서버 개발에 열정을 가진 김도현입니다. 🌟 서버 개발의 세계에 매료되어, 안정적이고 효율적인 시스템을 설계하고 구현하는 데 주력하고 있습니다. 자연어 처리와 인공지능 분야에도 큰 관심을 가지고 있으며, 최신 기술을 활용한 스마트한 서버 솔루션을 만드는 것이 제 목표입니다. 💻 다양한 프로젝트 경험을 통해 웹 애플리케이션, 모바일 백엔드, 대규모 데이터베이스 시스템 등 여러 분야에서 서버 개발의 기초와 심화 기술을 쌓아왔습니다. 특히, 클라우드 기반의 서버 환경 구축과 성능 최적화에서 두각을 나타내고 있습니다. ☁️ 제 개발 철학은 '끊임없는 학습과 도전'입니다. 새로운 기술에 대한 호기심을 가지고, 매번 새로운 문제에 도전하며 해결해 나가는 것을 즐깁니다. 또한, 협업을 통해 팀원들과의 시너지를 극대화하며, 프로젝트의 성공적인 완수를 위해 항상 최선을 다하고 있습니다. 🔧 서버 개발의 무궁무진한 가능성을 탐색하고, 이를 통해 더 나은 사용자 경험을 제공하는 것이 제 꿈입니다. 항상 발전하는 기술에 발맞추어 나아가며, 함께 성장해 나갈 수 있는 기회를 기다리고 있습니다. 🚀 감사합니다!"},
            {"role": "assistant", "content": "기술 스택 : 서버 개발, 클라우드, 데이터베이스 \n 관심 분야 : 서버 개발 및 최적화, 자연어 처리 및 인공지능, 새로운 기술과 문제 해결"}
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
  void initState() {
    super.initState();
    getResponseFromOpenAI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenAI Chat'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            responseText,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
