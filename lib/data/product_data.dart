// lib/data/product_data.dart

// 지역별 상품 목록
final Map<String, List<Map<String, String>>> productByRegion = {
  "서울": [
    {"name": "쿠팡", "price": "1234", "image": "asset/wine/wine1.png"},
    {"name": "보면서", "price": "1000000", "image": "asset/wine/wine2.png"},
    {"name": "찾은건데", "price": "2000000", "image": "asset/wine/wine3.png"},
  ],
  "부산": [
    {"name": "한병", "price": "3000000", "image": "asset/wine/wine4.png"},
    {"name": "사줄사람", "price": "20000", "image": "asset/wine/wine5.png"},
  ],
  "대구": [
    {"name": "어디없나", "price": "20", "image": "asset/wine/wine6.png"},
    {"name": "김성준?", "price": "9000000", "image": "asset/wine/wine7.png"},
  ],
};

// 현재 선택된 지역을 관리하는 변수
String? selectedRegion;
String? email;