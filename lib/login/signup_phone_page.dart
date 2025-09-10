// signup_name_page.dart
import 'package:flutter/material.dart';
import 'package:rokafirst/login/dialog/show_duplicate_dialog.dart';
import 'package:rokafirst/login/signup_password_page.dart';
import 'signupflowdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rokafirst/login/signup_phone_page.dart';


class SignupPhonePage extends StatefulWidget {
  final SignupFlowData data;

  SignupPhonePage({super.key, required this.data});

  @override
  State<SignupPhonePage> createState() => _SignupPhonePageState();
}

class _SignupPhonePageState extends State<SignupPhonePage> {
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
                      "전화번호를 입력해주세요",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),

                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "예: 010-0000-0000",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextAvailable
                            ? () async {
                          // 1) 전화번호 정규화(숫자만 남김) + 형식검사
                          final phone = _controller.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
                          final isValid = RegExp(r'^01[016789]\d{7,8}$').hasMatch(phone); // 예: 01012345678 (10~11자리)
                          if (!isValid) {
                            showDuplicateDialog(context, "전화번호 오류", "숫자만 10~11자리로 입력해주세요.\n예: 01012345678");
                            return;
                          }

                          try {
                            // 2) ✅ 문서 ID가 아니라 'phone' 필드로 검색해야 중복 확인 가능
                            final qs = await FirebaseFirestore.instance
                                .collection('users')
                                .where('phone', isEqualTo: phone)
                                .limit(1)
                                .get();

                            if (qs.docs.isNotEmpty) {
                              // 이미 다른 사용자 문서에 같은 phone이 있음
                              showDuplicateDialog(context, "중복된 전화번호", "이미 등록된 전화번호입니다.");
                              return;
                            }

                            // 3) 통과 → 다음 단계로 진행
                            widget.data.phone = phone;
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SignupPasswordPage(data: widget.data),
                                transitionsBuilder: (_, animation, __, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                              ),
                            );
                          } on FirebaseException catch (e) {
                            if (e.code == 'permission-denied') {
                              // ⚠️ 회원가입 중(비로그인) 규칙 때문에 users 읽기 불가한 경우
                              showDuplicateDialog(
                                context,
                                "권한 오류",
                                "회원가입 단계에서는 전화번호 중복 확인을 할 수 없습니다.\n"
                                    "계정 생성/로그인 후 다시 시도해 주세요.",
                              );
                            } else {
                              showDuplicateDialog(context, "오류", "잠시 후 다시 시도해주세요.\n${e.message}");
                            }
                          } catch (e) {
                            showDuplicateDialog(context, "오류", "잠시 후 다시 시도해주세요.\n$e");
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _nextAvailable ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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


