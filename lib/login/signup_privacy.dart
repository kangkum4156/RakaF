import 'package:flutter/material.dart';
import 'package:rokafirst/login/signup.dart';
import 'package:rokafirst/login/signupflowdata.dart';

class PrivacyConsentPage extends StatelessWidget {

  const PrivacyConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
< 제1조(개인정보 수집 및 이용 목적) >
이용자가 제공한 모든 정보는 다음의 목적을 위해 활용하며, 목적 이외의 용도로는 사용되지 않습니다.
 - 본인확인

< 제2조(개인정보 수집 및 이용 항목) >
개인정보 수집 목적을 위하여 다음과 같은 정보를 수집합니다.
- 성명, 전화번호, 이메일 및 군번

< 제3조(개인정보 보유 및 이용 기간) >
1. 수집한 개인정보는 수집〮이용 동의일로부터 개인정보 수집〮이용 목적을 달성할 때까지 보관 및 이용합니다.
2. 개인정보 보유기간의 경과, 처리목적의 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.

< 제4조(개인정보의 처리 위탁) >
회사가 취득한 개인정보는 정보통신망 이용촉진 및 정보보호 등에 관한 법률에 의하여 제3자에게 개인정보를 수집〮보관〮처리〮이용〮제공〮관리〮파기 등을 할 수 있도록 아래와 같이 개인정보처리 업무를 위탁합니다.
1. 개인정보를 위탁 받는 자 : 구글 파이어베이스
2. 개인정보 위탁 업무 내용: 회원가입 및 로그인


본인은 위의 동의서 내용을 충분히 숙지하였으며, 위와 같이 개인정보를 수집〮이용하는데 동의합니다.
본인은 위의 내용을 충분히 숙지하였으며, 위와 같이 개인정보를 제3자에게 제공하는데 동의합니다.
본인은 위의 내용을 충분히 숙지하였으며, 위와 같이 개인정보처리 업무를 위탁하는데 동의합니다.
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
                    child: const Text("모두 동의합니다"),
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
