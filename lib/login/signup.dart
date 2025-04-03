import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rokafirst/service/firebase_login_service.dart';

// 회원가입 화면
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  int tab = 0; // 현재 단계 (0: 이름 → 1: 군번 → 2: 이메일 → 3: 비밀번호)

  // 각 단계의 입력을 저장할 TextEditingController들
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _serviceNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 다음 버튼 눌렀을 때 실행될 함수
  void _goNext() async {
    if (tab < 4) {
      // 아직 마지막 단계가 아니면 다음 단계로 이동
      setState(() {
        tab++;
      });
    } else {
      // Firebase 연동: 회원가입 정보 저장
      await registerToFirestore(
        name: _nameController.text.trim(),
        studentId: _serviceNumberController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(), // auth에만 사용되고 store에 저장은 안함
        phone: _phoneController.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('승인 대기중입니다. 관리자 승인 후 로그인할 수 있습니다.'),
            ),
          ),
        ),
      );
    }
  }

  void _goBack() {
    if (tab > 0) {
      setState(() {
        tab--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 단계(tab)에 따라 입력창 텍스트, 설명, 컨트롤러 선택
    late final String description;
    late final String labelText;
    late final TextEditingController controller;
    late final Icon icon;

    switch (tab) {
      case 0:
        description = '이름을 입력하세요';
        labelText = '예: 홍길동';
        controller = _nameController;
        icon = const Icon(Icons.person);
        break;
      case 1:
        description = '군번을 입력하세요';
        labelText = '예: 20231234';
        controller = _serviceNumberController;
        icon = const Icon(Icons.badge);
        break;
      case 2:
        description = '이메일을 입력하세요';
        labelText = '예: example@domain.com';
        controller = _emailController;
        icon = const Icon(Icons.email);
        break;
      case 3:
        description = '전화번호를 입력하세요';
        labelText = '예: 01011112222';
        controller = _phoneController;
        icon = const Icon(Icons.phone);
        break;
      case 4:
        description = '비밀번호를 입력하세요';
        labelText = '6자 이상';
        controller = _passwordController;
        icon = const Icon(Icons.lock);
        break;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SignupInput(
          description: description,
          labelText: labelText,
          controller: controller,
          icon: icon,
          obscureText: tab == 4,
          onNext: _goNext,
          onBack: _goBack,
          showBackButton: tab > 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serviceNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// 재사용 가능한 입력 위젯
class SignupInput extends StatelessWidget {
  final String description;                    // 상단 안내 문구
  final String labelText;                      // TextField 힌트 텍스트
  final TextEditingController controller;      // 연결된 입력 컨트롤러
  final Icon icon;                             // TextField 우측 아이콘
  final VoidCallback onBack;                   // 이전 버튼 클릭 시 호출될 함수
  final VoidCallback onNext;                   // 다음 버튼 클릭 시 호출될 함수
  final bool showBackButton;                   // 이전 버튼 표시 여부
  final bool obscureText;                      // 텍스트 숨김 여부 (비밀번호용)

  const SignupInput({
    super.key,
    required this.description,
    required this.labelText,
    required this.controller,
    required this.icon,
    required this.onNext,
    required this.onBack,
    required this.showBackButton,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 화면 중앙에 컴팩트하게 정렬
        children: [
          Text(description, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          // 사용자 입력 필드
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
              suffixIcon: icon,
            ),
          ),
          const SizedBox(height: 24),
          // 이전/다음 버튼 영역
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                if (showBackButton)
                  TextButton(
                    onPressed: onBack,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("이전"),
                  )
                else
                  const SizedBox(width: 80),
                TextButton(
                  onPressed: onNext,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("다음"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
