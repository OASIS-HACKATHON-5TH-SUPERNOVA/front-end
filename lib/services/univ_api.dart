import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://univcert.com/api/v1';

  // 인증 코드 발송
  Future<bool> certifyEmail(String apiKey, String email, String univName, bool univCheck) async {
    final url = Uri.parse('$baseUrl/certify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'key': apiKey,
        'email': email,
        'univName': univName,
        'univ_check': univCheck,
      }),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // 인증 코드 검증
  Future<bool> verifyCode(String apiKey, String email, String univName, int code) async {
    final url = Uri.parse('$baseUrl/certifycode');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'key': apiKey,
        'email': email,
        'univName': univName,
        'code': code,
      }),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // 이메일 인증 상태 확인
  Future<Map<String, dynamic>> checkEmailStatus(String apiKey, String email) async {
    final url = Uri.parse('$baseUrl/status');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'key': apiKey,
        'email': email,
      }),
    );
    return jsonDecode(response.body);
  }

  // 인증된 유저 리스트 가져오기
  Future<Map<String, dynamic>> getCertifiedList(String apiKey) async {
    final url = Uri.parse('$baseUrl/certifiedlist');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'key': apiKey,
      }),
    );
    return jsonDecode(response.body);
  }

  // 인증 가능한 대학교 명 체크
  Future<bool> checkUniversity(String univName) async {
    final url = Uri.parse('$baseUrl/check');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'univName': univName,
      }),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // 인증 상태 초기화
  Future<bool> clearCertifiedList(String apiKey) async {
    final url = Uri.parse('$baseUrl/clear');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'key': apiKey,
      }),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }
}
