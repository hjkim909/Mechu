import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../utils/sample_data.dart';

/// 오프라인 모드용 로컬 캐시 서비스
class OfflineCacheService {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  static const String _lastRecommendationsKey = 'offline_last_recommendations';
  static const String _cachedRestaurantsKey = 'offline_cached_restaurants';
  static const String _lastUpdateTimeKey = 'offline_last_update';
  static const String _userLocationKey = 'offline_user_location';
  
  // 캐시 유효 시간 (6시간)
  static const Duration _cacheValidDuration = Duration(hours: 6);

  /// 마지막 추천 결과 캐시 저장
  Future<void> cacheRecommendations({
    required List<Restaurant> restaurants,
    required String location,
    required String category,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final Map<String, dynamic> cacheData = {
        'restaurants': restaurants.map((r) => r.toJson()).toList(),
        'location': location,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_lastRecommendationsKey, jsonEncode(cacheData));
      await prefs.setInt(_lastUpdateTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      print('📦 추천 결과 캐시 저장: ${restaurants.length}개 음식점');
    } catch (e) {
      print('추천 결과 캐시 저장 실패: $e');
    }
  }

  /// 캐시된 추천 결과 불러오기
  Future<OfflineCacheData?> getCachedRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cacheDataString = prefs.getString(_lastRecommendationsKey);
      
      if (cacheDataString == null) {
        return null;
      }
      
      final Map<String, dynamic> cacheData = jsonDecode(cacheDataString);
      final int timestamp = cacheData['timestamp'] ?? 0;
      
      // 캐시 유효성 검사
      if (!_isCacheValid(timestamp)) {
        await clearCache();
        return null;
      }
      
      final List<dynamic> restaurantsJson = cacheData['restaurants'] ?? [];
      final List<Restaurant> restaurants = restaurantsJson
          .map((json) => Restaurant.fromJson(json))
          .toList();
      
      return OfflineCacheData(
        restaurants: restaurants,
        location: cacheData['location'] ?? '',
        category: cacheData['category'] ?? '',
        cacheTime: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
    } catch (e) {
      print('캐시된 추천 결과 불러오기 실패: $e');
      return null;
    }
  }

  /// 사용자 위치 캐시 저장
  Future<void> cacheUserLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final Map<String, dynamic> locationData = {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_userLocationKey, jsonEncode(locationData));
      print('📍 사용자 위치 캐시 저장: $address');
    } catch (e) {
      print('사용자 위치 캐시 저장 실패: $e');
    }
  }

  /// 캐시된 사용자 위치 불러오기
  Future<UserLocation?> getCachedUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? locationDataString = prefs.getString(_userLocationKey);
      
      if (locationDataString == null) {
        return null;
      }
      
      final Map<String, dynamic> locationData = jsonDecode(locationDataString);
      final int timestamp = locationData['timestamp'] ?? 0;
      
      // 위치 캐시는 더 짧은 시간(1시간)만 유효
      if (!_isCacheValid(timestamp, const Duration(hours: 1))) {
        return null;
      }
      
      return UserLocation(
        latitude: locationData['latitude']?.toDouble() ?? 0.0,
        longitude: locationData['longitude']?.toDouble() ?? 0.0,
        address: locationData['address'] ?? '',
      );
    } catch (e) {
      print('캐시된 사용자 위치 불러오기 실패: $e');
      return null;
    }
  }

  /// 오프라인 모드용 기본 추천 데이터 생성
  Future<List<Restaurant>> getOfflineRecommendations({
    required String category,
    required String location,
    int count = 10,
  }) async {
    try {
      // 먼저 캐시된 데이터 확인
      final cachedData = await getCachedRecommendations();
      if (cachedData != null && cachedData.category == category) {
        print('📦 캐시된 추천 데이터 사용: ${cachedData.restaurants.length}개');
        return cachedData.restaurants;
      }
      
      // 캐시가 없거나 카테고리가 다르면 샘플 데이터 사용
      print('📱 오프라인 모드: 샘플 데이터 사용');
      return _generateOfflineSampleData(category, location, count);
    } catch (e) {
      print('오프라인 추천 데이터 생성 실패: $e');
      return _generateOfflineSampleData(category, location, count);
    }
  }

  /// 오프라인용 샘플 데이터 생성
  List<Restaurant> _generateOfflineSampleData(
    String category, 
    String location, 
    int count,
  ) {
    final sampleRestaurants = SampleData.getSampleRestaurants();
    
    // 카테고리별 필터링
    List<Restaurant> filteredRestaurants = sampleRestaurants
        .where((restaurant) => 
            restaurant.category.contains(category) ||
            restaurant.name.contains(category))
        .toList();
    
    // 필터링된 결과가 없으면 전체 샘플 데이터 사용
    if (filteredRestaurants.isEmpty) {
      filteredRestaurants = sampleRestaurants;
    }
    
    // 요청된 개수만큼 반환 (셔플해서 다양성 확보)
    filteredRestaurants.shuffle();
    return filteredRestaurants.take(count).toList();
  }

  /// 캐시 유효성 검사
  bool _isCacheValid(int timestamp, [Duration? customDuration]) {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final validDuration = customDuration ?? _cacheValidDuration;
    return DateTime.now().difference(cacheTime) < validDuration;
  }

  /// 캐시 상태 정보 조회
  Future<CacheStatus> getCacheStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? lastUpdate = prefs.getInt(_lastUpdateTimeKey);
      
      if (lastUpdate == null) {
        return CacheStatus(
          hasCache: false,
          lastUpdateTime: null,
          isValid: false,
        );
      }
      
      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final isValid = _isCacheValid(lastUpdate);
      
      return CacheStatus(
        hasCache: true,
        lastUpdateTime: lastUpdateTime,
        isValid: isValid,
      );
    } catch (e) {
      print('캐시 상태 조회 실패: $e');
      return CacheStatus(hasCache: false, lastUpdateTime: null, isValid: false);
    }
  }

  /// 캐시 삭제
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastRecommendationsKey);
      await prefs.remove(_cachedRestaurantsKey);
      await prefs.remove(_lastUpdateTimeKey);
      await prefs.remove(_userLocationKey);
      print('🗑️ 오프라인 캐시 삭제 완료');
    } catch (e) {
      print('캐시 삭제 실패: $e');
    }
  }
}

/// 오프라인 캐시 데이터 클래스
class OfflineCacheData {
  final List<Restaurant> restaurants;
  final String location;
  final String category;
  final DateTime cacheTime;

  OfflineCacheData({
    required this.restaurants,
    required this.location,
    required this.category,
    required this.cacheTime,
  });
}

/// 캐시 상태 정보 클래스
class CacheStatus {
  final bool hasCache;
  final DateTime? lastUpdateTime;
  final bool isValid;

  CacheStatus({
    required this.hasCache,
    required this.lastUpdateTime,
    required this.isValid,
  });

  /// 마지막 업데이트로부터 경과 시간
  Duration? get timeSinceUpdate {
    if (lastUpdateTime == null) return null;
    return DateTime.now().difference(lastUpdateTime!);
  }

  /// 사용자 친화적 캐시 상태 메시지
  String get statusMessage {
    if (!hasCache) {
      return '캐시된 데이터 없음';
    }
    
    if (!isValid) {
      return '캐시 만료됨';
    }
    
    final elapsed = timeSinceUpdate;
    if (elapsed == null) {
      return '캐시 상태 불명';
    }
    
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes}분 전 캐시됨';
    } else {
      return '${elapsed.inHours}시간 전 캐시됨';
    }
  }
}
