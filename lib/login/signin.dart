import 'package:flutter/material.dart';
import 'package:rokafirst/body/home/home_body.dart';
import 'package:rokafirst/login/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rokafirst/service/firebase_login_service.dart';
import '../data/product_data.dart';
import 'package:rokafirst/login/signupflowdata.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if(user!= null){
      return HomeBody();
    } else{
      return LoginScreen();
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // 로그인 함수
  Future<void> _signIn() async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'asset/img/air_logo.png', // 로고 이미지 경로
                  width: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  '대한민국공군',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'REPUBLIC OF KOREA AIR FORCE',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                LoginForm(
                    onSignIn: _signIn, //  로그인 함수 전달
                    onRegister: () {
                    },
                    emailController: _emailController,
                    passwordController: _passwordController
          
                ), // 분리된 클래스를 사용
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// 정보 입력, 로그인 버튼 부분
class LoginForm extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  final emailController;
  final passwordController;
  const LoginForm({
    super.key,
    required this.onSignIn,
    required this.onRegister,
    required this.emailController,
    required this.passwordController});


  @override

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton (
            onPressed: () async {
              final result = await signInWithApproval(emailController.text, passwordController.text);
              switch(result) {
                case(0):
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그인 실패. 이메일과 비밀번호를 확인하세요.")),
                  );
                  break;
                case(1):
                  email = emailController.text;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeBody()),
                  );

                case(2):
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("관리자 승인 후 로그인 가능합니다.")),
                  );
                  break;

              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Sign In'),
          ),
          TextButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupNamePage(data: SignupFlowData(),)),
            );
          }, child: Text("Don't have account?"))
        ],
      ),
    );
  }
}
