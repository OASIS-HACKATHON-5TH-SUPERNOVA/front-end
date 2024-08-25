import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sign_up.dart';
import 'main_page.dart';
import '../services/univ_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final _apiKey = '469b7054-f161-4e0d-865f-ddbe6d800a8f'; // 자신의 API Key로 변경

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // 여기서 실제 로그인 요청을 서버에 보내는 로직을 구현해야 합니다.
    // 이 예제에서는 로컬에서 간단한 예제 로직을 구현합니다.
    if (email == 'user@example.com' && password == 'password') {
      // 로그인 성공 시 로컬 저장소에 이메일 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setBool('isLoggedIn', true);

      // 메인 페이지로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    } else {
      // 로그인 실패 시 에러 메시지 표시
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('로그인 실패'),
          content: Text('이메일 또는 비밀번호가 올바르지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _clearCertifiedList() async {
    final success = await _apiService.clearCertifiedList(_apiKey);

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('초기화 완료'),
          content: Text('모든 인증된 이메일이 초기화되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('오류'),
          content: Text('인증된 이메일 초기화에 실패했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login, // 로그인 버튼 클릭 시 로그인 로직 실행
                  child: Text('로그인'),
                ),
                TextButton(
                  onPressed: () {
                    // 회원가입 버튼 클릭 시 회원가입 페이지로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignupPage(),
                      ),
                    );
                  },
                  child: Text('회원가입'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearCertifiedList,
              child: Text('인증 이메일 초기화'),
            ),
          ],
        ),
      ),
    );
  }
}
