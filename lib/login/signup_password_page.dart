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
                      "비밀번호는 영어와 숫자를 사용하여 6자리 이상으로 구성해주세요",
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
                            showDuplicateDialog(context, "형식 오류", "비밀번호는 6자리 이상이어야 합니다.");
                          }
                          else if(!isValidPassword(password)){
                            showDuplicateDialog(context, "형식 오류", "비밀번호는 영어와 숫자를 모두 사용하여야 합니다.");
                          }
                          else if(password != password2){
                            showDuplicateDialog(context, "비밀번호 오류", "비밀번호가 일치하지 않습니다.");
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
                              String errorMessage = "회원가입 중 문제가 발생했습니다.";
                              
                              // 구체적인 오류 메시지 표시
                              if (e.toString().contains('이미 사용 중인 이메일')) {
                                errorMessage = "이미 사용 중인 이메일입니다.";
                              } else if (e.toString().contains('비밀번호가 너무 약합니다')) {
                                errorMessage = "비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.";
                              } else if (e.toString().contains('올바르지 않은 이메일')) {
                                errorMessage = "올바르지 않은 이메일 형식입니다.";
                              } else if (e.toString().contains('데이터베이스 권한')) {
                                errorMessage = "데이터베이스 권한이 없습니다. 관리자에게 문의하세요.";
                              } else if (e.toString().contains('서버에 연결할 수 없습니다')) {
                                errorMessage = "서버에 연결할 수 없습니다. 네트워크를 확인해주세요.";
                              }
                              
                              showDuplicateDialog(context, "오류", errorMessage);
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

bool isValidPassword(String password) {
  // 영어와 숫자가 각각 최소 1개 이상 포함되어야 함, 전체 길이 6자 이상
  final passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
  );
  return passwordRegex.hasMatch(password);
}
