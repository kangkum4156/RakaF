import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // 추가
import 'package:rokafirst/login/signup.dart';
import 'package:rokafirst/login/signupflowdata.dart';

class PrivacyConsentPage extends StatelessWidget {
  const PrivacyConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "개인정보 수집 및 이용 동의",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SfPdfViewer.asset('asset/privacy_agreement.pdf'),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
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
          ),
        ],
      ),
    );
  }
}
