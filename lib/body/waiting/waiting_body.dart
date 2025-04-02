import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rokafirst/service/waiting_firebase_service.dart';
import '../../data/product_data.dart';

class WaitingBody extends StatefulWidget {
  const WaitingBody({super.key});

  @override
  State<WaitingBody> createState() => _WaitingBodyState();
}

class _WaitingBodyState extends State<WaitingBody> {

  String? userId = email; // 사용자 ID
  void refreshUI() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("사용자 정보를 찾을 수 없습니다."));
        }

        Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
        String? waitingMarket = userData['waiting_market'];

        return waitingMarket == null
            ? _buildNotWaitingUI()
            : _buildWaitingUI(waitingMarket);
      },
    );
  }

  Widget _buildNotWaitingUI() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("market")
          .doc(selectedRegion)
          .collection("waiting")
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        int totalWaiting = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return _buildCommonUI(
          "현재 대기 중이 아닙니다.",
          totalWaiting,
          selectedRegion!,
          "웨이팅하기",
              () async => await waitingPressed(context, refreshUI),
        );
      },
    );
  }

  Widget _buildWaitingUI(String waitingMarket) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("market")
          .doc(waitingMarket)
          .collection("waiting")
          .orderBy("timestamp")
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<QueryDocumentSnapshot> waitingList = snapshot.data!.docs;
        int totalWaiting = waitingList.length;
        int userPosition = waitingList.indexWhere((doc) => doc.id == userId) + 1;

        var userDoc = waitingList.firstWhere((doc) => doc.id == userId);
        String waitingTime = DateFormat('HH:mm:ss').format((userDoc['timestamp'] as Timestamp).toDate());

        return _buildCommonUI(
          '현재 내 순번 : $userPosition\n웨이팅한 시간 : $waitingTime',
          totalWaiting,
          waitingMarket,
          "웨이팅 취소",
              () async => await cancelWaiting(context, refreshUI),
        );
      },
    );
  }

  Widget _buildCommonUI(
      String leftText, int totalWaiting, String market, String buttonText, VoidCallback onPressed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoBox(leftText),
            _buildInfoBox('현재 매장 대기자 수 : \n$totalWaiting', textColor: Colors.orange),
          ],
        ),
        _buildMarketBox(market),
        SizedBox(
          width: 360,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.orange,
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text, {Color textColor = Colors.black}) {
    return Container(
      height: 250,
      width: 170,
      decoration: _boxDecoration(),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  Widget _buildMarketBox(String market) {
    return Container(
      height: 300,
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(),
      child: Center(
        child: Text(
          '현재 보고 있는 매장: $market',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}
