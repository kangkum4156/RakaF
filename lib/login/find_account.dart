// signup_name_page.dart
import 'package:flutter/material.dart';
import 'package:rokafirst/login/dialog/show_duplicate_dialog.dart';
import 'package:rokafirst/service/firebase_login_service.dart';
import 'package:rokafirst/login/dialog/show_loading_dialog.dart';


class FindAccount extends StatefulWidget {
  const FindAccount({super.key});

  @override
  State<FindAccount> createState() => _FindAccountState();
}

class _FindAccountState extends State<FindAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _nextAvailable = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkFields);
    _phoneController.addListener(_checkFields); // 추가
  }

  void _checkFields() {
    setState(() {
      _nextAvailable = _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty; // 둘 다 입력되었는지
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                      "계정찾기",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10,),
                    const Text(
                      "이름과 전화번호를 입력해 주세요",
                      style: TextStyle(fontSize: 16,),
                    ),
                    const Spacer(),

                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "이름",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.man_rounded),
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "전화번호",
                        border: UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextAvailable
                            ? ()async {
                          print("==========click=========");
                          final name = _nameController.text.trim();
                          final phone = _phoneController.text.trim();
                          showLoadingDialog(context);
                          final email = await findEmailByNameAndPhone(name, phone);

                          Navigator.pop(context);
                          if (email != null) {
                            showDuplicateDialog(
                                context, "계정 찾기 완료", "가입된 이메일은\n$email 입니다.");
                          } else {
                            showDuplicateDialog(
                                context, "계정 찾기 실패", "일치하는 정보를 찾을 수 없습니다.");
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
                        child: const Text("아이디 찾기"),
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