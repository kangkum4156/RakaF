// signup_name_page.dart
import 'package:flutter/material.dart';
import 'package:rokafirst/login/dialog/show_duplicate_dialog.dart';
import 'package:rokafirst/service/firebase_login_service.dart';
import 'package:rokafirst/login/dialog/show_loading_dialog.dart';


class FindPassword extends StatefulWidget {
  const FindPassword({super.key});

  @override
  State<FindPassword> createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPassword> {
  final TextEditingController _controller = TextEditingController();

  bool _nextAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkFields);

  }

  void _checkFields() {
    setState(() {
      _nextAvailable = _controller.text.trim().isNotEmpty;
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
                      "E-mail 입력",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    const Text(
                      "비밀번호 재설정 메일을 보내드립니다.",
                      style: TextStyle(fontSize: 16,),
                    ),
                    const Spacer(),

                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "email",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.email),
                      ),
                    ),
                    SizedBox(height: 20,),

                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextAvailable
                            ? ()async {
                          print("==========click=========");
                          final email = _controller.text.trim();

                          showLoadingDialog(context);
                          await sendPasswordResetEmail(email);

                          Navigator.pop(context);
                          showDuplicateDialog(
                              context, "전송 완료!", "e-mail을 확인해주세요");

                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _nextAvailable ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("비밀번호 찾기"),
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