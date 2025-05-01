import 'package:flutter/material.dart';
import 'package:rokafirst/login/utils/encryption.dart'; // 방금 만든 파일 경로

class DecryptTestPage extends StatefulWidget {
  const DecryptTestPage({super.key});

  @override
  State<DecryptTestPage> createState() => _DecryptTestPageState();
}

class _DecryptTestPageState extends State<DecryptTestPage> {
  final TextEditingController _controller = TextEditingController();
  String? _decryptedResult;

  void _decrypt() async {
    try {
      final decrypted = await decryptServiceNumber(_controller.text.trim());

      setState(() {
        _decryptedResult = decrypted;
      });
    } catch (e) {
      setState(() {
        _decryptedResult = '복호화 실패: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('군번 복호화 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '암호화된 군번 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _decrypt,
              child: const Text('복호화'),
            ),
            const SizedBox(height: 24),
            if (_decryptedResult != null)
              Text(
                '복호화 결과: $_decryptedResult',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}