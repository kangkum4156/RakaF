import 'dart:convert';
import 'package:http/http.dart' as http;

String? selectedRegion; // 선택된 지역 저장
List<dynamic> selectedProducts = []; // 선택된 지역의 상품 리스트 저장
List<dynamic> selectedNotices = []; // 선택된 지역의 notice 리스트 저장

String? email;

// 서버에서 특정 지역의 상품 가져오기
Future<void> fetchProductsByRegion() async {
  try {
    final response = await http.get(Uri.parse('https://2e02-155-230-25-18.ngrok-free.app/products'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      selectedProducts = jsonResponse.map((item) {
          return {
            'name': item['productName'].toString(),
            'text': item['productText'].toString(),
            'price': item['productPrice'].toString(),
            'image': item['productImageUrl'].toString(),
          };
        }
      ).toList();
    } else {
      throw Exception('상품 데이터를 불러오는 데 실패했습니다.');
    }
  } catch (e) {
    selectedProducts = [];
  }
}

Future<void> fetchNoticeByRegion() async {
  try {
    final response = await http.get(Uri.parse('https://2e02-155-230-25-18.ngrok-free.app/notices'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      selectedNotices = jsonResponse.map((item) {
        if(item['market']['location'].toString() == selectedRegion){
        return {
          'id': item['noticeId'].toString(),
          'name': item['noticeTitle'].toString(),
          'text': item['noticeText'].toString(),
          'image': item['noticeImageUrl'].toString(),
          'time': item['noticeTime'].toString(),
        };
        }
      }).toList();
    } else {
      throw Exception('상품 데이터를 불러오는 데 실패했습니다.');
    }
  } catch (e) {
    selectedNotices = [];
  }
}