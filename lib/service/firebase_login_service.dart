import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//firestore에 저장하는 함수
Future <void> registerToFirestore({
  required String name,
  required String serviceNumber,
  required String phone,
  required String email,
  required String password,
})
async {
  try {
    // 1. Firebase Authentication에 계정 생성
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    String uid = userCredential.user!.uid;

    // 2. Firestore에 사용자 정보 저장
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'uid': uid,
      'name': name,
      'serviceNumber': serviceNumber,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'isApproved': false, // 기본값: 승인되지 않음
    });

    print('Firestore에 회원정보 저장 완료!');
  } catch (e) {
    print('회원가입 중 오류 발생: $e');
    rethrow; // 위쪽에서 오류 처리 가능하도록 다시 던짐
  }
}
//관리자가 승인했는지 확인하고 로그인 시키는 함수
Future<int> signInWithApproval(String email, String password) async {
  try {
    // 1. Firebase 로그인
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;
    if (user == null) return 0;

    // 2. Firestore에서 승인 여부 확인 (doc ID = email)
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .get();

    if (!doc.exists) return 0;

    final isApproved = doc.data()?['isApproved'] ?? false;

    if (isApproved) {
      return 1; // 승인됨
    } else {
      await FirebaseAuth.instance.signOut(); // 승인 안 됐으면 로그아웃
      return 2; // 승인 안 됨
    }
  } on FirebaseAuthException catch (e) {
    print('로그인 에러: ${e.code} / ${e.message}');
    return 0; // 로그인 실패
  } catch (e) {
    print('기타 에러: $e');
    return 0; // 예외 처리
  }
}
//email 중복 확인
Future<bool> isEmailDuplicate(String email) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(email).get();
  return doc.exists;
}
//군번 중복 확인
Future<bool> isServiceNumberDuplicate(String serviceNumber) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('serviceNumber', isEqualTo: serviceNumber)
      .get();
  return snapshot.docs.isNotEmpty;
}