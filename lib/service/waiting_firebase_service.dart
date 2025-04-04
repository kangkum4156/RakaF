import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rokafirst/data/product_data.dart';

Future<void> waitingPressed(BuildContext context, Function updateUI) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId = email;
  String? marketId = selectedRegion; // 현재 웨이팅할 매장 ID

  DocumentSnapshot userSnapshot =
  await firestore.collection("users").doc(userId).get();

  if (!userSnapshot.exists) {
    if (kDebugMode) {
      print("❌ 사용자 정보 없음");
    }
    return;
  }

  Map<String, dynamic> userData =
  userSnapshot.data() as Map<String, dynamic>;

  // 이미 웨이팅 중인지 확인
  if (userData.containsKey('waiting_market')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("이미 ${userData['waiting_market']}에서 웨이팅 중입니다.")),
    );
    return;
  }

  // Firestore에 웨이팅 정보 추가
  await firestore.collection("market").doc(marketId).collection("waiting").doc(userId).set({
    "name": userData['name'],
    "serviceNumber": userData['serviceNumber'],
    "timestamp": FieldValue.serverTimestamp(),
    "waitingStatus": false
  });

  // 사용자의 waiting_market 상태를 marketId로 업데이트
  await firestore.collection("users").doc(userId).update({
    "waiting_market": marketId,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("웨이팅이 완료되었습니다!")),
  );

  updateUI(); // ✅ UI 업데이트를 위해 `setState()` 호출
}
Future<void> cancelWaiting(BuildContext context, Function updateUI) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId = email; // 실제 사용자 ID로 변경
  String? waitingMarket = await getWaitingMarket(userId);

  if (waitingMarket == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("현재 웨이팅 중인 매장이 없습니다.")),
    );
    return;
  }

  // Firestore에서 해당 사용자의 웨이팅 정보 삭제
  await firestore
      .collection("market")
      .doc(waitingMarket)
      .collection("waiting")
      .doc(userId)
      .delete();

  // 사용자 문서에서 waiting_market 필드 삭제
  await firestore.collection("users").doc(userId).update({
    "waiting_market": FieldValue.delete(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("웨이팅이 취소되었습니다.")),
  );

  // UI 갱신
  updateUI();
}

// 웨이팅 중인 매장 정보를 가져오는 함수
Future<String?> getWaitingMarket(String? userId) async {
  DocumentSnapshot userSnapshot =
  await FirebaseFirestore.instance.collection("users").doc(userId).get();

  if (!userSnapshot.exists) return null;

  Map<String, dynamic> userData =
  userSnapshot.data() as Map<String, dynamic>;

  return userData['waiting_market']; // 웨이팅 중인 매장
}
Future<String?> getWaitingOrder(String? userId, String? waitingMarket) async {
  if (userId == null || waitingMarket == null) return null;

  try {
    // 해당 매장의 waiting 리스트를 timestamp 기준으로 정렬해서 가져옴
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("market")
        .doc(waitingMarket)
        .collection("waiting")
        .orderBy("timestamp")
        .get();

    List<QueryDocumentSnapshot> waitingList = snapshot.docs;

    int position = waitingList.indexWhere((doc) => doc.id == userId);
    if (position == -1) return null; // 유저가 웨이팅 리스트에 없을 경우

    return (position + 1).toString(); // 순번은 0부터 시작하니까 +1
  } catch (e) {
    print("getWaitingOrder error: $e");
    return null;
  }
}
