import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rokafirst/data/product_data.dart';
import 'package:flutter/foundation.dart';

final _auth = FirebaseAuth.instance;
final _db = FirebaseFirestore.instance;



Future<void> waitingPressed(BuildContext context, VoidCallback updateUI) async {
  // ── [CP0] 시작 ────────────────────────────────────────────────────────────────
  final startedAt = DateTime.now();
  debugPrint('🟨 [waitingPressed] start @ ${startedAt.toIso8601String()}');

  try {
    // ── [CP1] 인증 확인 ─────────────────────────────────────────────────────────
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('🟨 [CP1] currentUser: '
        'exists=${user != null}, '
        'uid=${user?.uid}, '
        'email=${user?.email}, '
        'isAnonymous=${user?.isAnonymous}, '
        'providers=${user?.providerData.map((p)=>p.providerId).toList()}');

    if (user == null || user.email == null || user.email!.isEmpty) {
      debugPrint('🔴 [CP1] no user email → abort');
      throw Exception('로그인이 필요합니다.');
    }

    final email = user.email!;
    final marketId = selectedRegion;
    debugPrint('🟨 [CP1] email="$email" marketId="$marketId"');

    if (marketId == null || marketId.isEmpty) {
      debugPrint('🔴 [CP1] selectedRegion(=marketId) empty → abort');
      throw Exception('웨이팅할 매장을 먼저 선택하세요.');
    }

    final db = FirebaseFirestore.instance;

    // ── [CP2] users/{email} 존재 보장(없으면 seed) ──────────────────────────────
    final userRef = db.collection('users').doc(email);
    final userSnap0 = await userRef.get();
    debugPrint('🟨 [CP2] check users/$email exists=${userSnap0.exists}');

    if (!userSnap0.exists) {
      debugPrint('ℹ️ [CP2] seed users/$email create');
      await userRef.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ [CP2] users/$email created');
    }

    final userSnap = await userRef.get();
    final userData = userSnap.data() ?? {};
    debugPrint('🟨 [CP2] users/$email data keys=${userData.keys.toList()}');

    // ── [CP3] 이미 웨이팅 중인지 검사(users.waiting_market) ───────────────────
    final waitingMarket = userData['waiting_market'] as String?;
    debugPrint('🟨 [CP3] waiting_market="$waitingMarket"');
    if (waitingMarket != null && waitingMarket.isNotEmpty) {
      debugPrint('🟡 [CP3] already waiting at "$waitingMarket" → show snack & return');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 $waitingMarket 에서 웨이팅 중입니다.')),
      );
      return;
    }

    // ── [CP4] 쓰기 대상 경로 로그 ───────────────────────────────────────────────
    final waitingRef = db
        .collection('market').doc(marketId)
        .collection('waiting').doc(email);
    debugPrint('🟨 [CP4] write path: market/$marketId/waiting/$email');

    // 표시용 필드(없으면 공백)
    final name = (userData['name'] ?? '') as String;
    final fcm = (userData['FCM'] ?? '') as String;
    final serviceNumber = (userData['serviceNumber'] ?? '') as String;

    // ── [CP5] 트랜잭션 실행 ────────────────────────────────────────────────────
    await db.runTransaction((tx) async {
      debugPrint('🟨 [CP5] transaction begin');
      final wSnap = await tx.get(waitingRef);
      debugPrint('🟨 [CP5] current waiting doc exists=${wSnap.exists}');

      if (wSnap.exists) {
        debugPrint('🔴 [CP5] doc already exists → throw');
        throw Exception('이미 웨이팅 중입니다.');
      }

      // waiting 문서 쓰기
      tx.set(waitingRef, {
        'email': email, // 규칙과 일치시키려면 문서 ID==email, 필드로도 저장(편의)
        'name': name,
        'FCM': fcm,
        'serviceNumber': serviceNumber,
        'marketId': marketId,
        'waitingStatus': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [CP5] set waiting doc');

      // users 문서 업데이트
      tx.set(userRef, {
        'email': email,
        'waiting_market': marketId,
      }, SetOptions(merge: true));
      debugPrint('✅ [CP5] set users/$email waiting_market="$marketId"');
    });

    // ── [CP6] 완료 ─────────────────────────────────────────────────────────────
    debugPrint('🎉 [CP6] waitingPressed success');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('웨이팅이 완료되었습니다!')),
    );
    updateUI();
  } on FirebaseException catch (e, st) {
    // Firestore 권한/경로/필드 오류 등을 정확히 확인
    debugPrint('🔥 [ERR][FirebaseException] code=${e.code} message=${e.message}');
    debugPrint('🔥 [ERR] stack=\n$st');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('웨이팅 등록 실패(Firebase): ${e.code}')),
    );
    rethrow; // UI 쪽에서 finally로 로딩 닫을 수 있게
  } catch (e, st) {
    debugPrint('🔥 [ERR][Generic] $e');
    debugPrint('🔥 [ERR] stack=\n$st');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('웨이팅 등록 실패: $e')),
    );
    rethrow;
  } finally {
    final endedAt = DateTime.now();
    debugPrint('🟨 [waitingPressed] end @ ${endedAt.toIso8601String()} '
        '(elapsed: ${endedAt.difference(startedAt).inMilliseconds}ms)');
  }
}


// 웨이팅 취소
Future<void> cancelWaiting(BuildContext context, VoidCallback updateUI) async {
  final user = _auth.currentUser;
  if (user == null || user.email == null || user.email!.isEmpty) {
    throw Exception('로그인이 필요합니다.');
  }
  final email = user.email!;

  final userRef = _db.collection('users').doc(email);
  final userSnap = await userRef.get();
  final waitingMarket = userSnap.data()?['waiting_market'] as String?;
  if (waitingMarket == null || waitingMarket.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('현재 웨이팅 중인 매장이 없습니다.')),
    );
    return;
  }

  final waitingRef = _db
      .collection('market').doc(waitingMarket)
      .collection('waiting').doc(email);

  await _db.runTransaction((tx) async {
    final wSnap = await tx.get(waitingRef);
    if (wSnap.exists) {
      tx.delete(waitingRef);
    }
    tx.set(userRef, {'email': email, 'waiting_market': null}, SetOptions(merge: true));
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('웨이팅이 취소되었습니다.')),
  );
  updateUI();
}

// 현재 웨이팅 매장
Future<String?> getWaitingMarket(String? _ignored) async {
  final email = _auth.currentUser?.email;
  if (email == null || email.isEmpty) return null;
  final snap = await _db.collection('users').doc(email).get();
  return snap.data()?['waiting_market'] as String?;
}

// 내 순번 (email 기준)
Future<String?> getWaitingOrder(String? userEmail, String? marketId) async {
  if (userEmail == null || userEmail.isEmpty || marketId == null || marketId.isEmpty) return null;
  try {
    final q = await _db
        .collection('market').doc(marketId)
        .collection('waiting')
        .orderBy('timestamp')
        .get();

    final idx = q.docs.indexWhere((d) => d.id == userEmail);
    if (idx == -1) return null;
    return (idx + 1).toString();
  } catch (_) {
    return null;
  }
}
