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
 // 사용자 ID
  void refreshUI() => setState(() {});
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserEmail();
  }
  void _getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email; // 현재 로그인된 사용자의 이메일 저장
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

          Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
          String? waitingMarket = userData['waiting_market'];

          return _buildCommonWaitingUI(waitingMarket == null ? false : true);
        },
      ),
    );
  }

  Widget _buildCommonWaitingUI(bool waiting) {
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
          waiting ? "현재 대기중인 매장이 있습니다" : "현재 대기 중이 아닙니다.",
          totalWaiting,
          selectedRegion!,
          "웨이팅하기",
              () async => await waitingPressed(context, refreshUI),
        );
      },
    );
  }
  void _showWaitingStatus(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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

            Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String? waitingMarket = userData['waiting_market'];

            if (waitingMarket == null) {
              // 웨이팅하지 않는 경우
              return _buildBottomSheetContent(
                "웨이팅하려는 매장: $selectedRegion",
                "웨이팅하기",
                      () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    await waitingPressed(context, refreshUI); // 작업 수행

                    Navigator.pop(context); // 로딩 다이얼로그 닫기
                    Navigator.pop(context); // 바텀시트 닫기
                  },
              );
            } else {
              // 웨이팅 중인 경우: 순번과 시작 시간 표시
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("market")
                    .doc(waitingMarket)
                    .collection("waiting")
                    .doc(email)
                    .get(),
                builder: (context, waitingSnapshot) {
                  if (waitingSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

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
                      if (orderSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

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

                          await cancelWaiting(context, refreshUI); // 작업 수행

                          Navigator.pop(context); // 로딩 다이얼로그 닫기
                          Navigator.pop(context); // 바텀시트 닫기
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
        String? waitingOrder, // optional 순번
        String? waitingTime,  // optional 시작 시간
      }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (waitingOrder != null && waitingTime != null) ...[
            const SizedBox(height: 10),
            Text(
              '내 순번: $waitingOrder\n웨이팅 시간: $waitingTime',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
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

  Widget _buildCommonUI(
      String leftText, int totalWaiting, String market, String buttonText, VoidCallback onPressed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoBox(leftText, false),
            _buildInfoBox('현재 매장 대기자 수 : \n$totalWaiting', true, textColor: Colors.orange),
          ],
        ),
        _buildMarketBox(market),

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
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ),
        if(refresh)Positioned(
            top: 8, // 상단 여백
            right: 8, // 오른쪽 여백
            child: Container(
              width: 25, // 컨테이너 너비 설정
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                shape: BoxShape.circle, // 원형 모양 설정
              ),
              child: IconButton(
                icon: Icon(Icons.refresh, size: 20, color: Colors.grey),
                onPressed: refreshUI,
                padding: EdgeInsets.zero,
              ),
            )
        ),
      ],
    );
  }

  Widget _buildMarketBox(String market) {
    return Container(
      height: 360,
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