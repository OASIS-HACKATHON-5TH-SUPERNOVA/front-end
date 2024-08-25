import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // inputFormatter에 필요
import 'login.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 다루기 위해 사용

class RegistrationPage extends StatefulWidget {
  final String email;
  RegistrationPage({required this.email});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();

  String? _selectedYear;

  final List<String> _years = ['1', '2', '3', '4', '졸업유예'];

  @override
  void dispose() {
    // 컨트롤러는 사용 후 반드시 dispose() 호출해야 함
    _nameController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // 현재 날짜가 기본 선택
      firstDate: DateTime(1900), // 선택 가능한 첫 번째 날짜
      lastDate: DateTime.now(),  // 오늘까지 선택 가능
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked); // 선택한 날짜를 텍스트 필드에 설정
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 정보 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: '학과'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedYear,
              items: _years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                  _yearController.text = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: '학년'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: '휴대폰 번호'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}-?\d{0,4}-?\d{0,4}$')), // 숫자와 하이픈만 허용
                PhoneNumberFormatter(),
              ],
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: '현재 거주 지역'),
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: '생년월일',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context); // 달력 열기
                  },
                ),
              ),
              readOnly: true, // 사용자가 직접 입력할 수 없고 달력에서 선택만 가능
            ),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(labelText: '성별'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom TextInputFormatter for phone number formatting
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length >= 11) {
      final buffer = StringBuffer();
      buffer.write(text.substring(0, 3)); // 010
      if (text.length > 3) {
        buffer.write('-');
        buffer.write(text.substring(3, 7)); // xxxx
      }
      if (text.length > 7) {
        buffer.write('-');
        buffer.write(text.substring(7, 11)); // xxxx
      }
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    }
    return newValue;
  }
}
