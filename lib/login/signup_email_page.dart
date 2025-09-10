// signup_name_page.dart
import 'package:flutter/material.dart';
import 'package:rokafirst/login/signup_service_page.dart';
import 'signupflowdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rokafirst/login/signup_phone_page.dart';
import 'package:rokafirst/login/dialog/show_duplicate_dialog.dart';


class SignupEmailPage extends StatefulWidget {
  final SignupFlowData data;

  SignupEmailPage({super.key, required this.data});

  @override
  State<SignupEmailPage> createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {
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
                      "이메일을 입력해주세요",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),

                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "예: happy@gmail.com",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextAvailable
                            ? ()async {
                          final email = _controller.text.trim();
                          final doc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(email)
                              .get();
                          if(!isValidEmail(email)){
                            showDuplicateDialog(context, "이메일오류", "올바른 이메일 형식이 아닙니다");
                          } else if(!doc.exists){
                            widget.data.email = email;
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => SignupServicePage(data: widget.data),
                                transitionsBuilder: (_, animation, __, child) {
                                  const begin = Offset(1.0, 0.0); // 오른쪽에서 왼쪽으로
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          } else {
                            showDuplicateDialog(
                                context,
                                "중복된 이메일",
                                "이미 등록된 이메일입니다.");
                          }


                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _nextAvailable ? Colors.green : Colors.grey,
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
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  return emailRegex.hasMatch(email);
}

