import 'package:flutter/material.dart';
import 'package:rokafirst/login/signup.dart';
import 'package:rokafirst/login/signupflowdata.dart';

class PrivacyConsentPage extends StatelessWidget {

  const PrivacyConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("개인정보 수집 동의")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "개인정보 수집 및 이용 동의",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
다음과 같은 개인정보를 수집〮이용합니다.

1. 수집 항목
- 이름
- 군번
- 이메일
- 전화번호

2. 수집 목적
- 사용자 인증 및 식별
- 앱 기능 제공

※ 본인은 위 내용을 충분히 이해하였으며, 개인정보 수집 및 이용에 동의합니다.
                  ''',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupNamePage(data: SignupFlowData()),
                        ),
                      );
                    },
                    child: const Text("동의합니다"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
