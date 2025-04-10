import 'package:firebase_auth/firebase_auth.dart';
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
  String? email;

  void refreshUI() => setState(() {});

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  void _getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWaitingStatus(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.list, color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(email).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("사용자 정보를 찾을 수 없습니다."));
          }
          return _buildCommonWaitingUI();
        },
      ),
    );
  }

  Widget _buildCommonWaitingUI() {
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

        return _buildCommonUI(totalWaiting);
      },
    );
  }

  void _showWaitingStatus(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("users").doc(email).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(child: Text("사용자 정보를 찾을 수 없습니다."));
            }

            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String? waitingMarket = userData['waiting_market'];

            if (waitingMarket == null) {
              return _buildBottomSheetContent(
                "웨이팅하려는 매장: $selectedRegion",
                "웨이팅하기",
                    () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                  await waitingPressed(context, refreshUI);
                  Navigator.pop(context); // 로딩 다이얼로그
                  Navigator.pop(context); // 바텀시트
                },
              );
            } else {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("market")
                    .doc(waitingMarket)
                    .collection("waiting")
                    .doc(email)
                    .get(),
                builder: (context, waitingSnapshot) {
                  String? waitingOrder;
                  String? waitingTime;

                  if (waitingSnapshot.hasData && waitingSnapshot.data!.exists) {
                    var data = waitingSnapshot.data!.data() as Map<String, dynamic>;
                    Timestamp? ts = data["timestamp"];
                    waitingTime = ts != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(ts.toDate())
                        : "알 수 없음";
                  }

                  return FutureBuilder<String?>(
                    future: getWaitingOrder(email, waitingMarket),
                    builder: (context, orderSnapshot) {
                      waitingOrder = orderSnapshot.data;

                      return _buildBottomSheetContent(
                        "웨이팅한 매장: $waitingMarket",
                        "웨이팅취소",
                            () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
                          await cancelWaiting(context, refreshUI);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        waitingOrder: waitingOrder,
                        waitingTime: waitingTime,
                      );
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBottomSheetContent(
      String text,
      String buttonText,
      VoidCallback onPressed, {
        String? waitingOrder,
        String? waitingTime,
      }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (waitingOrder != null && waitingTime != null) ...[
            const SizedBox(height: 10),
            Text('내 순번: $waitingOrder\n웨이팅 시간: $waitingTime',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonUI(int totalWaiting) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoBox('매장 : ${selectedRegion}', false),
            _buildInfoBox('현재 매장 대기자 수 : \n$totalWaiting', true, textColor: Colors.orange),
          ],
        ),
        _buildMarketBox(selectedRegion!),
      ],
    );
  }

  Widget _buildInfoBox(String text, bool refresh, {Color textColor = Colors.black}) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: 170,
          decoration: _boxDecoration(),
          child: Center(
            child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ),
        ),
        if (refresh)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                onPressed: refreshUI,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMarketBox(String marketId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("market").doc(marketId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("매장 정보를 불러올 수 없습니다."));
        }

        var marketData = snapshot.data!.data() as Map<String, dynamic>;
        String location = marketData['location'] ?? '위치 정보 없음';
        String openTime = marketData['openTime'] ?? '운영시간 정보 없음';

        return Container(
          height: 360,
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: _boxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📍 위치: $location', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 5),
              Text('⏰ 운영시간: $openTime', style: const TextStyle(fontSize: 15)),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
    );
  }
}
