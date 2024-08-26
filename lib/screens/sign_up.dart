import 'package:flutter/material.dart';
import '../services/univ_api.dart';
import 'register.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _apiKey = ''; // 자신의 API Key로 변경
  bool _isEmailCertified = false;

  final ApiService _apiService = ApiService();

  String? _selectedUnivName;

  // 학교 목록
  final List<String> _univNames = [
    '전북대학교', '전주대학교', '전주기전대학교', '전주비전대학교', '전북과학대학교',
    '전남도립대학교', '전주교육대학교', '원광대학교', '원광디지털대학교', '원광보건대학교',
    '광주대학교', '광주가톨릭대학교', '광주교육대학교', '광주여자대학교', '광양보건대학교',
    '호남대학교', '호남신학대학교', '순천대학교', '순천향대학교', '순천제일대학교',
    '목포대학교', '목포해양대학교', '목포가톨릭대학교', '전남대학교', '전남과학대학교'
  ];

  String _getDomainFromEmail(String email) {
    final domain = email.split('@').last;
    return domain;
  }

  Future<void> _sendCertificationEmail() async {
    final email = _emailController.text;
    final univName = _selectedUnivName ?? ''; // 드롭다운에서 선택한 학교 이름
    final emailDomain = _getDomainFromEmail(email);

    // 도메인과 대학명이 일치하는지 확인
    if (emailDomain != univName) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('오류'),
          content: Text('이메일 도메인과 선택한 대학명이 일치하지 않습니다.'),
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
    final univName = _selectedUnivName ?? ''; // 드롭다운에서 선택한 학교 이름
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '학교 이메일'),
              ),
              DropdownButton<String>(
                value: _selectedUnivName,
                hint: Text('대학교명 선택'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnivName = newValue;
                  });
                },
                items: _univNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
