import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rokafirst/data/product_data.dart'; // productByRegion 가져오기
import 'package:rokafirst/screen/home_screen.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  bool isLoading = false; // 로딩 상태 추가

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
