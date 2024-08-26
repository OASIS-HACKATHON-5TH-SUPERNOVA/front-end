import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼 동작: 이전 화면으로 돌아가기
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요', // 검색창에 표시될 힌트 텍스트
            border: InputBorder.none, // 검색창의 기본 테두리를 제거
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 버튼 눌렀을 때 동작 (필요에 따라 추가 가능)
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Training Page Content'), // 여기에 실제 내용을 추가하세요.
      ),
    );
  }
}
