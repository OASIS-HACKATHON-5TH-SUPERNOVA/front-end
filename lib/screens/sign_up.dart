import 'package:flutter/material.dart';
import '../services/univ_api.dart';
import 'register.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _univNameController = TextEditingController();
  final _apiKey = ''; // 자신의 API Key로 변경
  bool _isEmailCertified = false;
  final _codeController = TextEditingController();

  final ApiService _apiService = ApiService();

  Future<void> _sendCertificationEmail() async {
    final email = _emailController.text;
    final univName = _univNameController.text;
    final success = await _apiService.certifyEmail(_apiKey, email, univName, true);

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('이메일 인증 코드 발송'),
          content: Text('이메일로 인증 코드가 발송되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
      setState(() {
        _isEmailCertified = true;
      });
    } else {
      // 처리 실패 시
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('오류'),
          content: Text('이메일 인증 코드 발송에 실패했습니다.'),
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

  Future<void> _verifyCode() async {
    final email = _emailController.text;
    final univName = _univNameController.text;
    final code = int.tryParse(_codeController.text);

    if (code == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('오류'),
          content: Text('유효한 인증 코드를 입력해 주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final success = await _apiService.verifyCode(_apiKey, email, univName, code);

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RegistrationPage(email: email),
        ),
      );
    } else {
      // 인증 실패 시
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('오류'),
          content: Text('인증 코드가 올바르지 않습니다.'),
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
          title: Text('성공'),
          content: Text('인증된 유저 목록이 초기화되었습니다.'),
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
          content: Text('인증된 유저 목록 초기화에 실패했습니다.'),
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
    return WillPopScope(
      onWillPop: () async {
        if (_isEmailCertified) {
          final shouldClear = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('초기화 확인'),
              content: Text('인증된 상태라면 초기화 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text('예'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text('아니요'),
                ),
              ],
            ),
          );

          if (shouldClear == true) {
            await _clearCertifiedList();
          }
        }
        return true; // 페이지가 정상적으로 닫히도록 true 반환
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('회원가입'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '학교 이메일'),
              ),
              TextField(
                controller: _univNameController,
                decoration: InputDecoration(labelText: '대학교명'),
              ),
              ElevatedButton(
                onPressed: _sendCertificationEmail,
                child: Text('인증 코드 발송'),
              ),
              if (_isEmailCertified) ...[
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: '인증 코드 입력'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: Text('인증하기'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
