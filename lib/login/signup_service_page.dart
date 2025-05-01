// signup_name_page.dart
import 'package:flutter/material.dart';
import 'package:rokafirst/login/signup_email_page.dart';
import 'dialog/show_duplicate_dialog.dart';
import 'signupflowdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rokafirst/login/utils/encryption.dart';
import 'package:rokafirst/login/signup_phone_page.dart';


class SignupServicePage extends StatefulWidget {
  final SignupFlowData data;

  SignupServicePage({super.key, required this.data});

  @override
  State<SignupServicePage> createState() => _SignupServicePageState();
}

class _SignupServicePageState extends State<SignupServicePage> {
  final TextEditingController _controller = TextEditingController();
  bool _nextAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _nextAvailable = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView( // 키보드 올라올 때 자동 스크롤
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const SizedBox(height: 120),
                    const Text(
                      "군번 7-8자리를 입력해주세요",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),

                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "예: 12345678",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextAvailable
                            ? () async {
                          // 1) 원본 입력에서 하이픈 제거
                          print("click==================================");
                          final rawInput = _controller.text.trim().replaceAll('-', '');

                          // 2) rawInput을 암호화 (deterministic CBC+0IV 덕분에 매번 같은 암호문)
                          final encryptedInput = await encryptServiceNumber(rawInput);

                          // 3) 암호문끼리 비교하는 where 쿼리
                          final snapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .where('serviceNumber', isEqualTo: encryptedInput)
                              .get();

                          // 4) 길이 검사 & 중복 처리
                          if (rawInput.length < 7 || rawInput.length > 8) {
                            showDuplicateDialog(context, "군번 오류", "숫자 7~8자리를 입력해주세요.");
                          } else if (snapshot.docs.isNotEmpty) {
                            showDuplicateDialog(context, "중복된 군번", "이미 등록된 군번입니다.");
                          } else {
                            // 중복 없으니 data에 암호문 저장 후 다음
                            widget.data.serviceNumber = encryptedInput;
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SignupEmailPage(data: widget.data),
                                transitionsBuilder: (_, animation, __, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  return SlideTransition(
                                    position: animation.drive(
                                      Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _nextAvailable ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("다음"),
                      ),
                    ),
                    SizedBox(height: 60,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

