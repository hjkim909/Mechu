import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// 카카오 로컬 API 서비스
class KakaoApiService {
  static const String _baseUrl = 'https://dapi.kakao.com/v2/local';
  
  // TODO: 실제 앱 배포 시에는 환경변수로 관리해야 함
  static const String _apiKey = 'YOUR_KAKAO_API_KEY_HERE';
  
  static final KakaoApiService _instance = KakaoApiService._internal();
  factory KakaoApiService() => _instance;
  KakaoApiService._internal();

  /// 카테고리별 음식점 검색
  /// 
  /// [category] 검색할 음식점 카테고리
  /// [latitude] 중심 좌표 위도
  /// [longitude] 중심 좌표 경도
  /// [radius] 검색 반경 (미터, 최대 20000)
  /// [page] 페이지 번호 (1-45)
  /// [size] 한 페이지에 보여질 문서의 개수 (1-15)
  Future<List<Restaurant>> searchRestaurantsByCategory({
    required String category,
    required double latitude,
    required double longitude,
    int radius = 5000,
    int page = 1,
    int size = 15,
  }) async {
    try {
      // 카테고리를 카카오 API 카테고리 코드로 변환
      String categoryCode = _getCategoryCode(category);
      
      final uri = Uri.parse('$_baseUrl/search/category.json').replace(
        queryParameters: {
          'category_group_code': categoryCode,
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': radius.toString(),
          'page': page.toString(),
          'size': size.toString(),
          'sort': 'distance', // 거리순 정렬
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        return documents.map((doc) => _parseRestaurantFromKakao(doc, category)).toList();
      } else {
        throw Exception('카카오 API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('음식점 검색 중 오류 발생: $e');
    }
  }

  /// 키워드로 음식점 검색
  /// 
  /// [keyword] 검색 키워드
  /// [latitude] 중심 좌표 위도
  /// [longitude] 중심 좌표 경도
  /// [radius] 검색 반경 (미터, 최대 20000)
  /// [page] 페이지 번호 (1-45)
  /// [size] 한 페이지에 보여질 문서의 개수 (1-15)
  Future<List<Restaurant>> searchRestaurantsByKeyword({
    required String keyword,
    required double latitude,
    required double longitude,
    int radius = 5000,
    int page = 1,
    int size = 15,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/search/keyword.json').replace(
        queryParameters: {
          'query': '$keyword 맛집',
          'category_group_code': 'FD6', // 음식점 카테고리
          'x': longitude.toString(),
          'y': latitude.toString(),
          'radius': radius.toString(),
          'page': page.toString(),
          'size': size.toString(),
          'sort': 'distance',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        return documents.map((doc) => _parseRestaurantFromKakao(doc, keyword)).toList();
      } else {
        throw Exception('카카오 API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('음식점 검색 중 오류 발생: $e');
    }
  }

  /// 카카오 API 응답을 Restaurant 객체로 변환
  Restaurant _parseRestaurantFromKakao(Map<String, dynamic> doc, String category) {
    // 카카오 API는 평점을 제공하지 않으므로 임의의 값 생성
    final rating = 3.5 + (doc['id'].hashCode % 20) / 10.0; // 3.5 ~ 5.5 범위
    final priceLevel = 1 + (doc['id'].hashCode % 4); // 1 ~ 4 범위
    
    return Restaurant(
      id: doc['id'] ?? '',
      name: doc['place_name'] ?? '이름 없음',
      category: category,
      rating: double.parse(rating.toStringAsFixed(1)),
      priceLevel: priceLevel,
      address: doc['road_address_name'] ?? doc['address_name'] ?? '',
      latitude: double.tryParse(doc['y'] ?? '0') ?? 0.0,
      longitude: double.tryParse(doc['x'] ?? '0') ?? 0.0,
      isOpen: true, // 카카오 API에서 영업시간 정보가 제한적이므로 기본값
    );
  }

  /// 앱의 카테고리를 카카오 API 카테고리 코드로 변환
  String _getCategoryCode(String category) {
    switch (category) {
      case '김치찌개':
      case '삼겹살':
      case '갈비탕':
        return 'FD6'; // 음식점
      case '짜장면':
        return 'FD6'; // 음식점
      case '치킨':
        return 'FD6'; // 음식점
      case '라멘':
        return 'FD6'; // 음식점
      case '떡볶이':
        return 'FD6'; // 음식점
      case '피자':
      case '파스타':
        return 'FD6'; // 음식점
      case '햄버거':
        return 'FD6'; // 음식점
      case '초밥':
        return 'FD6'; // 음식점
      case '카페':
        return 'CE7'; // 카페
      default:
        return 'FD6'; // 기본값: 음식점
    }
  }

  /// 좌표로 주소 변환 (역지오코딩)
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/geo/coord2address.json').replace(
        queryParameters: {
          'x': longitude.toString(),
          'y': latitude.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];
        
        if (documents.isNotEmpty) {
          final address = documents[0];
          return address['road_address']?['address_name'] ?? 
                 address['address']?['address_name'] ?? 
                 '주소를 찾을 수 없음';
        }
      }
      
      return '주소를 찾을 수 없음';
    } catch (e) {
      return '주소 변환 실패';
    }
  }

  /// API 키 설정 (실제 사용 시 호출)
  static void setApiKey(String apiKey) {
    // 이 메서드를 통해 런타임에 API 키를 설정할 수 있음
    // 실제 구현에서는 _apiKey를 변경할 수 있도록 해야 함
  }

  /// API 키 유효성 검사
  Future<bool> isApiKeyValid() async {
    try {
      // 간단한 API 호출로 키 유효성 검사
      final uri = Uri.parse('$_baseUrl/search/keyword.json').replace(
        queryParameters: {
          'query': '테스트',
          'size': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 