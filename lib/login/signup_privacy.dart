import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 표시
import 'package:rokafirst/login/signup.dart';
import 'package:rokafirst/login/signupflowdata.dart';

class PrivacyConsentPage extends StatefulWidget {
  const PrivacyConsentPage({super.key});

  @override
  State<PrivacyConsentPage> createState() => _PrivacyConsentPageState();
}

enum ConsentChoice { none, agree, disagree }

class _PrivacyConsentPageState extends State<PrivacyConsentPage> {
  bool allAgree = false;

  ConsentChoice c1 = ConsentChoice.none; // 개인정보 수집·이용
  ConsentChoice c2 = ConsentChoice.none; // 개인정보 제3자 제공
  ConsentChoice c3 = ConsentChoice.none; // 개인정보 처리 위탁

  bool get canProceed =>
      c1 == ConsentChoice.agree &&
          c2 == ConsentChoice.agree &&
          c3 == ConsentChoice.agree;

  void _toggleAll(bool? value) {
    final agree = value ?? false;
    setState(() {
      allAgree = agree;
      c1 = agree ? ConsentChoice.agree : ConsentChoice.none;
      c2 = agree ? ConsentChoice.agree : ConsentChoice.none;
      c3 = agree ? ConsentChoice.agree : ConsentChoice.none;
    });
  }

  void _setChoice(int idx, ConsentChoice choice) {
    setState(() {
      switch (idx) {
        case 1:
          c1 = choice;
          break;
        case 2:
          c2 = choice;
          break;
        case 3:
          c3 = choice;
          break;
      }
      allAgree = (c1 == ConsentChoice.agree &&
          c2 == ConsentChoice.agree &&
          c3 == ConsentChoice.agree);
    });
  }

  Widget _agreeRow({
    required String title,
    required String body,
    required int index,
    required ConsentChoice value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Checkbox(
                  value: value == ConsentChoice.agree,
                  onChanged: (_) => _setChoice(
                      index,
                      value == ConsentChoice.agree
                          ? ConsentChoice.none
                          : ConsentChoice.agree),
                ),
                const Text('동의함'),
                const SizedBox(width: 20),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: value == ConsentChoice.disagree,
                  onChanged: (_) => _setChoice(
                      index,
                      value == ConsentChoice.disagree
                          ? ConsentChoice.none
                          : ConsentChoice.disagree),
                ),
                const Text('동의하지 않음'),
              ],
            ),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 동의'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 본문 내용
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // 머리말
                  Text(
                    "밀리샵(이하 '회사'라고 합니다)은 개인정보보호법 등 관련 법령상의 개인정보보호 규정을 준수하며 귀하의 개인정보보호에 최선을 다하고 있습니다. "
                        "회사는 개인정보보호보호법에 근거하여 다음과 같은 내용으로 개인정보를 수집 및 처리하고자 합니다.\n\n"
                        "다음의 내용을 자세히 읽어보시고 모든 내용을 이해하신 후에 동의 여부를 결정해주시기 바랍니다.\n",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  // 제1조
                  Text("제 1조(개인정보 수집 및 이용 목적)",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text(
                    "이용자가 제공한 모든 정보는 본인확인의 목적을 위해 활용되며, 목적 이외의 용도로는 사용되지 않습니다.\n",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  // 제2조
                  Text("제2조(개인정보 수집 및 이용 항목)",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text(
                    "회사는 개인정보 수집 목적을 위해 다음과 같은 정보를 수집합니다.\n성명, 전화번호, 이메일 및 군번\n",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  // 제3조
                  Text("제3조(개인정보 보유 및 이용 기간)",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text(
                    "수집한 개인정보는 수집,이용 동의일로부터 개인정보 수집,이용 목적을 달성할 때까지 보관 및 이용합니다. "
                        "개인정보 보유기간의 경과, 처리목적의 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.\n",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),

            // 동의 섹션들(체크박스 포함) + 날짜
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _agreeRow(
                    title: "개인정보 수집 및 이용 동의",
                    body:
                    "본인은 위의 동의서 내용을 충분히 숙지하였으며, 위와 같이 개인정보를 수집, 이용하는데 동의합니다.",
                    index: 1,
                    value: c1,
                  ),
                  const Text("개인정보 제3자 제공 동의",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text(
                    "본인은 위의 내용을 충분히 숙지하였으며, 위와같이 개인정보를 제 3자에게 제공하는데 동의 합니다.",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  _agreeRow(
                    title: "개인정보 제3자 제공 동의",
                    body: "개인정보 제3자 제공에 동의함 여부를 선택해 주세요.",
                    index: 2,
                    value: c2,
                  ),
                  const Text("제4조(개인정보의 처리 위탁)",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text(
                    "회사가 취득한 개인정보는 정보통신망 이용촉진 및 정보보호 등에 관한 법률에 의하여 제3자에게 개인정보를 수집, 보관, 처리, 이용, 제공, 관리, 파기 등을 할 수 있도록 아래와 같이 개인정보처리 업무를 위탁합니다.\n"
                        "• 개인정보를 위탁 받는 자: Google Firebase\n"
                        "• 개인정보 위탁 업무 내용: 회원가입 및  로그인\n",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  _agreeRow(
                    title: "개인정보 처리업무 위탁 동의",
                    body: "본인은 위의 내용을 충분히 숙지하였으며, 위와 같이 개인정보처리 업무를 위탁하는데 동의합니다.",
                    index: 3,
                    value: c3,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("서명일자: $today",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ),
                ],
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SignupNamePage(data: SignupFlowData()),
                      ),
                    );
                  }
                      : null,
                  child: const Text('모두 동의합니다'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
