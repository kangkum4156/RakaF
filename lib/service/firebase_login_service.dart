import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rokafirst/login/utils/encryption.dart';

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
    print('Firebase Auth 계정 생성 성공: $uid');

    // 2. 토큰 준비를 위한 짧은 대기
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 3. 이메일 인증 이메일 전송
    await userCredential.user!.sendEmailVerification();
    print('이메일 인증 이메일 전송 완료');

    // 4. Firestore에 사용자 정보 저장
    final encrypted = await encryptServiceNumber(serviceNumber);
    print('서비스 번호 암호화 완료');
    
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'uid': uid,
      'name': name,
      'serviceNumber': encrypted,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'isApproved': false,
    });
    print('Firestore에 회원정보 저장 완료!');
    
  } on FirebaseAuthException catch (e) {
    print('Firebase Auth 오류: ${e.code} / ${e.message}');
    if (e.code == 'email-already-in-use') {
      throw Exception('이미 사용 중인 이메일입니다.');
    } else if (e.code == 'weak-password') {
      throw Exception('비밀번호가 너무 약합니다.');
    } else if (e.code == 'invalid-email') {
      throw Exception('올바르지 않은 이메일 형식입니다.');
    } else {
      throw Exception('회원가입 중 오류가 발생했습니다: ${e.message}');
    }
  } catch (e) {
    print('회원가입 중 오류 발생: $e');
    if (e.toString().contains('PERMISSION_DENIED')) {
      throw Exception('데이터베이스 권한이 없습니다. 관리자에게 문의하세요.');
    } else if (e.toString().contains('UNAVAILABLE')) {
      throw Exception('서버에 연결할 수 없습니다. 네트워크를 확인해주세요.');
    }
    rethrow;
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

    // 2. 이메일 인증 확인
    if (!user.emailVerified) {
      await FirebaseAuth.instance.signOut();
      return 3; // 이메일 인증 안 됨
    }

    // 3. Firestore에서 승인 여부 확인 (doc ID = email)
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
//비밀번호 재설정 이메일 전송
Future<void> sendPasswordResetEmail(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    print("비밀번호 재설정 이메일 전송 완료");
  } catch (e) {
    print("비밀번호 재설정 실패: $e");
    rethrow;
  }
}

//아이디(이메일) 찾기 기능
Future<String?> findEmailByNameAndPhone(String name, String phone) async {
  print("DEBUG: 검색 중 - name: $name, phone: $phone");
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('name', isEqualTo: name)
      .where('phone', isEqualTo: phone)
      .get();

  if (snapshot.docs.isEmpty) return null;

  return snapshot.docs.first.id; // 문서 ID = 이메일
}

// 이메일 인증 이메일 전송
Future<void> sendEmailVerification() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print("이메일 인증 이메일 전송 완료");
    }
  } catch (e) {
    print("이메일 인증 전송 실패: $e");
    rethrow;
  }
}

// 이메일 인증 상태 확인
bool isEmailVerified() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.emailVerified ?? false;
}

// 이메일 인증 상태 새로고침
Future<void> reloadUser() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
    }
  } catch (e) {
    print("사용자 정보 새로고침 실패: $e");
    rethrow;
  }
}

