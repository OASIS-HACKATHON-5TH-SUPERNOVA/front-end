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
    const apiKey = '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';
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
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Who won the world series in 2020?"},
            {"role": "assistant", "content": "The Los Angeles Dodgers won the World Series in 2020."},
            {"role": "user", "content": "Where was it played?"}
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
