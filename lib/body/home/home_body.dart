import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rokafirst/data/product_data.dart'; // productByRegion 가져오기
import 'package:rokafirst/screen/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class ChatArguments {
  final RemoteMessage message;

  ChatArguments(this.message);
}


class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  bool isLoading = false; // 로딩 상태 추가
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    init();
    setupFlutterNotifications(); // 알림 초기화
    setupInteractedMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 포그라운드에서 메시지 수신!');
      showFlutterNotification(message);
    });
  }

  Future<void> setupFlutterNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 📌 여기에 채널 등록 추가!
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'waiting', // 채널 ID
      '기본 채널', // 채널 이름
      description: '기본 알림 채널',
      importance: Importance.max, // 중요도 HIGH 이상 설정해야 팝업됨
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'waiting', // 채널 ID
            '기본 채널',        // 채널 이름
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(context, '/chat',
        arguments: ChatArguments(message),
      );
    }
  }

  void init() async{
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print('📲 FCM 토큰: $fcmToken');

      // 현재 로그인한 유저 정보 가져오기
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && fcmToken != null) {
        final userEmail = currentUser.email;

        // Firestore의 users 컬렉션에서 해당 유저 문서에 FCM 필드 저장
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .set({'FCM': fcmToken}, SetOptions(merge: true)); // 병합해서 기존 데이터 보존
      }
    } else {
      print('❌ 알림 권한 거부됨');
    }
  }

  // 지역 변경 시 선택된 지역을 업데이트
  void updateRegion(String? newRegion) {
    setState(() {
      selectedRegion = newRegion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RegionDropdown(
                selectedRegion: selectedRegion,
                onRegionChanged: updateRegion,
              ),
              const SizedBox(height: 20),
              ConfirmButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  const ConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: selectedRegion != null
          ? () async {
        await fetchProductsByRegion(); // 서버에서 데이터 가져오기
        await fetchNoticeByRegion();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), // HomeScreen 이동
        );
      }
          : null, // 선택된 지역이 없으면 버튼 비활성화
      child: const Text('선택 완료'),
    );
  }
}

class RegionDropdown extends StatefulWidget {
  final String? selectedRegion;
  final Function(String?) onRegionChanged;

  const RegionDropdown({
    super.key,
    required this.selectedRegion,
    required this.onRegionChanged,
  });
  @override
  _RegionDropdownState createState() => _RegionDropdownState();
}

class _RegionDropdownState extends State<RegionDropdown> {
  List<String> regionList = []; // Firestore에서 가져온 지역 리스트
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    fetchRegions(); // Firestore에서 지역 정보 가져오기
  }

  // Firestore에서 market 컬렉션의 지역 정보 가져오기
  Future<void> fetchRegions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('market').get();
      // 중복 제거를 위해 Set 사용
      Set<String> regions = {};

      for (var doc in snapshot.docs) {
        String regionName = doc.id; // 🔥 문서 이름 가져오기!
        regions.add(regionName);
      }

      setState(() {
        regionList = regions.toList(); // Set을 List로 변환
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator() // 로딩 중이면 인디케이터 표시
        : DropdownButton<String>(
      value: widget.selectedRegion,
      hint: const Text('지역을 선택하세요'),
      onChanged: widget.onRegionChanged,
      items: regionList.map<DropdownMenuItem<String>>((String region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region),
        );
      }).toList(),
    );
  }
}
