import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('홈 화면'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // (로그인 화면으로 이동)
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '대학생 여러분, 환영합니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // 예를 들어, 다른 화면으로 이동하는 코드
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnotherScreen()),
                );
              },
              child: Text('다른 화면으로 이동'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 예시로 추가된 다른 화면
class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다른 화면'),
      ),
      body: Center(
        child: Text('이곳은 다른 화면입니다.'),
      ),
    );
  }
}
