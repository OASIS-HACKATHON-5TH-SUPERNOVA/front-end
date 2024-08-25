import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 페이지'),
        // actions 속성을 제거하여 오른쪽 상단 버튼을 없앰
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '환영합니다!',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            Text(
              '여기에서 앱의 주요 기능을 이용하실 수 있습니다.',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 다른 페이지로 이동하는 코드 예시
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AnotherPage(),
                  ),
                );
              },
              child: Text('다른 페이지로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다른 페이지'),
      ),
      body: Center(
        child: Text('이곳은 다른 페이지입니다.'),
      ),
    );
  }
}
