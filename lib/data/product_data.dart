import 'dart:convert';
import 'package:http/http.dart' as http;

String? selectedRegion; // 선택된 지역 저장
List<dynamic> selectedProducts = []; // 선택된 지역의 상품 리스트 저장
List<dynamic> selectedNotices = []; // 선택된 지역의 notice 리스트 저장
String? selectedMarketId;
String? email;

String servertoken = "http://68.233.120.163:8082/";

// 서버에서 특정 지역의 상품 가져오기
Future<void> fetchProductsByRegion() async {
  try {
    final response = await http.get(Uri.parse(servertoken + 'products'));

    if (response.statusCode == 200) {
      // 🔥 UTF-8로 디코딩하여 JSON 파싱
      List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      selectedProducts = jsonResponse
          .where((item) => item['market']['location'].toString() == selectedRegion) // 필터링 적용
          .map((item) {
        return {
          'name': item['productName'].toString(),
          'text': item['productText'].toString(),
          'price': item['productPrice'].toString(),
          'image': item['productImageUrl'].toString(),
        };
      }).toList();
    } else {
      throw Exception('상품 데이터를 불러오는 데 실패했습니다.');
    }
  } catch (e) {
    selectedProducts = [];
  }
}

// 서버에서 특정 지역의 공지사항 가져오기
Future<void> fetchNoticeByRegion() async {
  try {
    final response = await http.get(Uri.parse(servertoken + 'notices'));

    if (response.statusCode == 200) {
      // 🔥 UTF-8로 디코딩하여 JSON 파싱
      List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      selectedNotices = jsonResponse
          .where((item) => item['market']['location'].toString() == selectedRegion) // 필터링 적용
          .map((item) {
        return {
          'name': item['noticeTitle'].toString(),
          'text': item['noticeText'].toString(),
          'image': item['noticeImageUrl'].toString(),
          'time': item['noticeTime'].toString(),
        };
      }).toList();
    } else {
      throw Exception('공지 데이터를 불러오는 데 실패했습니다.');
    }
  } catch (e) {
    selectedNotices = [];
  }
}
