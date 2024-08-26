import 'package:flutter/material.dart';
import '../screens/main_page.dart';
import '../screens/login.dart'; // 로그인 페이지 파일을 가져옵니다.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // 디버그 배너 비활성화
      home: MainPage(),
    );
  }
}
