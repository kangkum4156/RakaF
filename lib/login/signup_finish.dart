import 'package:flutter/material.dart';
import 'package:rokafirst/login/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rokafirst/service/firebase_login_service.dart';

class SignupFinish extends StatelessWidget {
  final String userName;


  const SignupFinish({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.asset('asset/img/signup_finish.png')),
            Text("$userName님 반갑습니다.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            Text("관리자의 승인 이후 사용 가능합니다."),
            SizedBox(height: 160,),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                onPressed:(){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen(),));

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("로그인 화면"),
              ),
            ),
            SizedBox(height: 60,),
          ],
        ),
      ),
    );
  }
}
