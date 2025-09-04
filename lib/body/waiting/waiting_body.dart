import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rokafirst/service/waiting_firebase_service.dart';
import '../../data/product_data.dart';
import 'package:rokafirst/body/waiting/festival_service.dart'; // ✅ 세미콜론


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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canOpenSheet = email != null && selectedRegion != null && selectedRegion!.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: canOpenSheet ? () => _showWaitingStatus(context) : null,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.list, color: Colors.white),
      ),
      body: (email == null)
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<DocumentSnapshot>(
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
    if (selectedRegion == null || selectedRegion!.isEmpty) {
      return const Center(child: Text("매장을 먼저 선택하세요."));
    }

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
        final totalWaiting = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _buildCommonUI(totalWaiting);
      },
    );
  }

  void _showWaitingStatus(BuildContext context) {
    if (email == null) return;

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

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final String? waitingMarket = userData['waiting_market'] as String?;

            // 이미 웨이팅 중인 경우: 취소 UI
            if (waitingMarket != null) {
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
                    final data = waitingSnapshot.data!.data() as Map<String, dynamic>;
                    final ts = data["timestamp"] as Timestamp?;
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
                          try {
                            await cancelWaiting(context, refreshUI);
                          } catch (_) {
                            // cancelWaiting 내부에서 SnackBar 처리됨
                          } finally {
                            if (mounted) Navigator.pop(context); // 로딩
                            if (mounted) Navigator.pop(context); // 바텀시트
                          }
                        },
                        waitingOrder: waitingOrder,
                        waitingTime: waitingTime,
                      );
                    },
                  );
                },
              );
            }

            // 아직 웨이팅 안 한 경우: 축제 상태 확인 후 버튼 제어
            if (selectedRegion == null || selectedRegion!.isEmpty) {
              return _buildBottomSheetContent(
                "매장을 먼저 선택하세요.",
                "확인",
                    () => Navigator.pop(context),
                enabled: false,
              );
            }

            // 아직 웨이팅 안 한 경우: 축제 상태 확인 후 버튼 제어
            return FutureBuilder<FestivalCheckResult>(
              future: FestivalService.getFestivalStatusForUser(
                marketId: selectedRegion!, // null 아님 가정
                email: email,
              ),
              builder: (context, fesSnap) {
                if (fesSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final result = fesSnap.data ?? const FestivalCheckResult(FestivalGate.noFestival, null);

                String helperText = '웨이팅하려는 매장: $selectedRegion';
                bool enabled = false;

                switch (result.gate) {
                  case FestivalGate.noFestival:
                    helperText = '참여할 수 있는 행사가 없습니다';
                    enabled = false;
                    break;
                  case FestivalGate.alreadyParticipated:
                    helperText = '이미 참여한 행사입니다.';
                    enabled = false;
                    break;
                  case FestivalGate.eligible:
                    enabled = true; // 축제 있고 미참여 → 가능
                    break;
                }

                return _buildBottomSheetContent(
                  helperText,
                  "웨이팅하기",
                      () async {
                    if (!enabled) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      await waitingPressed(context, refreshUI);
                    } finally {
                      if (mounted) Navigator.pop(context); // 로딩
                      if (mounted) Navigator.pop(context); // 바텀시트
                    }
                  },
                  enabled: enabled, // ✅ 버튼 활성/비활성 전달
                );
              },
            );

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
        bool enabled = true,
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
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonUI(int totalWaiting) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoBox('매장 : ${selectedRegion ?? "-"}', false),
                _buildInfoBox('현재 매장 대기자 수 : \n$totalWaiting', true, textColor: Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedRegion != null && selectedRegion!.isNotEmpty)
              _buildMarketBox(selectedRegion!)
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text, bool refresh, {Color textColor = Colors.black}) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(16),
          decoration: _boxDecoration(),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ),
        if (refresh)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
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

        final marketData = snapshot.data!.data() as Map<String, dynamic>;
        final location = marketData['location'] ?? '위치 정보 없음';
        final openTime = marketData['openTime'] ?? '운영시간 정보 없음';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 위치: $location', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 10),
              Text('⏰ 운영시간: $openTime', style: const TextStyle(fontSize: 15)),

              // 🎪 축제 카드: 매장 블록 아래에 표시
              const SizedBox(height: 12),
              FutureBuilder<FestivalData?>(
                future: FestivalService.fetchFirstFestival(marketId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator(minHeight: 2);
                  }
                  if (snap.hasError) {
                    return _festivalCard(
                      title: '⚠️ 행사 정보를 불러올 수 없습니다',
                      subtitle: '네트워크/권한을 확인해 주세요.',
                      tint: Colors.red,
                    );
                  }

                  final fes = snap.data;
                  if (fes == null) {
                    return _festivalCard(
                      title: '🎪 참여할 수 있는 행사가 없습니다',
                      subtitle: null,
                      tint: Colors.grey,
                    );
                  }

                  return _festivalCard(
                    title: '🎉 행사 안내',
                    subtitle: [
                      if ((fes.detail ?? '').isNotEmpty) '설명: ${fes.detail}',
                      '기간: ${fes.dateRangeText()}',
                    ].join('\n'),
                    tint: Colors.orange,
                  );
                },
              ),
            ],
          ),
        );

      },
    );
  }


  Widget _festivalCard({required String title, String? subtitle, Color tint = Colors.orange}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tint)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ],
      ),
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
