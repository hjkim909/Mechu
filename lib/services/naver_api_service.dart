import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'config_service.dart';

/// 네이버 로컬 API 서비스
class NaverApiService {
  static const String _baseUrl = 'https://openapi.naver.com/v1/search/local.json';

  final ConfigService _configService = ConfigService();

  static final NaverApiService _instance = NaverApiService._internal();
  factory NaverApiService() => _instance;
  NaverApiService._internal();

  String get _clientId => _configService.naverClientId;
  String get _clientSecret => _configService.naverClientSecret;

  /// 키워드로 음식점 검색
  Future<List<Restaurant>> searchRestaurantsByKeyword({
    required String keyword,
    int display = 15,
    int start = 1,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'query': '$keyword 맛집',
          'display': display.toString(),
          'start': start.toString(),
          'sort': 'random',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'X-Naver-Client-Id': _clientId,
          'X-Naver-Client-Secret': _clientSecret,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => _parseRestaurantFromNaver(item, keyword)).toList();
      } else {
        throw Exception('네이버 API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('음식점 검색 중 오류 발생: $e');
    }
  }

  Restaurant _parseRestaurantFromNaver(Map<String, dynamic> item, String category) {
    return Restaurant(
      id: item['link'] ?? '',
      name: item['title'].replaceAll(RegExp(r'<[^>]*>'), '') ?? '이름 없음',
      category: category,
      rating: 4.0, // 네이버는 평점 정보를 제공하지 않음
      priceLevel: 2, // 가격 수준 정보 없음
      address: item['roadAddress'] ?? item['address'] ?? '',
      latitude: 0.0, // 네이버는 좌표 정보를 제공하지 않음
      longitude: 0.0,
      isOpen: true, // 영업시간 정보 없음
    );
  }
}
