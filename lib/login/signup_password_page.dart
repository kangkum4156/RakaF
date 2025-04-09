// signup_name_page.dart
import 'package:flutter/material.dart';
import 'package:rokafirst/login/dialog/show_duplicate_dialog.dart';
import 'package:rokafirst/login/signup_finish.dart';
import 'package:rokafirst/service/firebase_login_service.dart';
import 'signupflowdata.dart';
import 'package:rokafirst/login/dialog/show_loading_dialog.dart';


class SignupPasswordPage extends StatefulWidget {
  final SignupFlowData data;

  SignupPasswordPage({super.key, required this.data});

  @override
  State<SignupPasswordPage> createState() => _SignupPasswordPageState();
}

class _SignupPasswordPageState extends State<SignupPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
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
    _controller2.dispose();
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
                      "비밀번호를 입력해주세요",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    const Text(
                      "비밀번호는 영어와 문자를 사용하여 6자리 이상으로 구성해주세요",
                      style: TextStyle(fontSize: 16,),
                    ),
                    const Spacer(),

                    TextField(
                      obscureText: true,
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "비밀번호",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.lock),
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      obscureText: true,
                      controller: _controller2,
                      decoration: const InputDecoration(
                        labelText: "다시한번 입력해주세요",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextAvailable
                            ? ()async {
                          final password = _controller.text.trim();
                          final password2 = _controller2.text.trim();
                          if(password.length < 6){
                            showDuplicateDialog(context, "비밀번호 오류", "비밀번호는 6자리 이상이어야 합니다.");
                          }
                          else if(password != password2){
                            showDuplicateDialog(context, "비밀번호", "비밀번호가 다릅니다.");
                          }
                          else{
                            widget.data.password = password;
                            showLoadingDialog(context);
                            try{
                              await registerToFirestore(
                                  name: widget.data.name,
                                  serviceNumber: widget.data.serviceNumber,
                                  phone: widget.data.phone,
                                  email: widget.data.email,
                                  password: widget.data.password);
                              if(mounted){
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => SignupFinish(userName: widget.data.name),
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
                              }
                            } catch (e){
                              Navigator.pop(context); // 로딩 종료
                              showDuplicateDialog(context, "오류", "회원가입 중 문제가 발생했습니다.");
                            }




                          }
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
                        child: const Text("회원가입"),
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


