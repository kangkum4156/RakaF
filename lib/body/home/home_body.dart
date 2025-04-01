import 'package:flutter/material.dart';
import 'package:rokafirst/data/product_data.dart'; // productByRegion 가져오기
import 'package:rokafirst/screen/home_screen.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String? currentRegion = selectedRegion;

  void updateRegion(String? newRegion) {
    setState(() {
      currentRegion = newRegion;
      selectedRegion = newRegion; // 선택된 지역을 전역적으로 저장
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
                selectedRegion: currentRegion,
                onRegionChanged: updateRegion,
              ),
              const SizedBox(height: 20),
              ConfirmButton(currentRegion: currentRegion),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ 지역 선택 Dropdown을 별도 위젯으로 분리
class RegionDropdown extends StatelessWidget {
  final String? selectedRegion;
  final Function(String?) onRegionChanged;

  const RegionDropdown({
    super.key,
    required this.selectedRegion,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedRegion,
      hint: const Text('지역을 선택하세요'),
      onChanged: onRegionChanged,
      items: productByRegion.keys.map<DropdownMenuItem<String>>((String region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region),
        );
      }).toList(),
    );
  }
}

// ✅ 선택 완료 버튼을 별도 위젯으로 분리
class ConfirmButton extends StatelessWidget {
  final String? currentRegion;

  const ConfirmButton({super.key, required this.currentRegion});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: currentRegion != null
          ? () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );      }
          : null, // 지역이 선택되지 않으면 버튼 비활성화
      child: const Text('선택 완료'),
    );
  }
}
