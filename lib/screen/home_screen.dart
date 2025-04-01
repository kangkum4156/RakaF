import 'package:flutter/material.dart';
import 'package:rokafirst/body/home/home_body.dart';
import 'package:rokafirst/login/signin.dart';
import 'package:rokafirst/body/notice/notice_body.dart'; // NoticeBody import
import 'package:rokafirst/body/product/product_body.dart'; // ProductBody import
import 'package:rokafirst/body/waiting/waiting_body.dart'; // WaitingBody import

final List<Widget> _screens = [
  const WaitingBody(),
  const ProductBody(),
  const NoticeBody(),
];

final List<IconData> _icons = [
  Icons.timeline_rounded,
  Icons.production_quantity_limits,
  Icons.notifications,
];

final List<String> _labels = [
  'Waiting',
  'Product',
  'Notice',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roka First'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ); // 로그아웃 후 로그인 화면으로 이동
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeBody()),
            ); // 뒤로가기 버튼을 눌렀을 때 HomeBody로 이동
          },
        ),
      ),
      body: _screens[_selectedIndex], // 현재 선택된 화면 표시
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        icons: _icons,
        labels: _labels,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final List<IconData> icons;
  final List<String> labels;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.icons,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: List.generate(icons.length, (index) => BottomNavigationBarItem(
        icon: Icon(icons[index]),
        label: labels[index],
      )),
      currentIndex: currentIndex,
      selectedItemColor: Colors.orange,
      onTap: onItemTapped, // 아이템 클릭 시 onItemTapped 실행
    );
  }
}