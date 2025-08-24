import '../models/models.dart';
import '../utils/sample_data.dart';
import 'location_service.dart';
import 'kakao_api_service.dart';
import 'naver_api_service.dart'; // 네이버 서비스 추가
import 'config_service.dart';
import 'network_service.dart';
import 'offline_cache_service.dart';

/// 메뉴 추천 서비스
class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final LocationService _locationService = LocationService();
  final KakaoApiService _kakaoApiService = KakaoApiService();
  final NaverApiService _naverApiService = NaverApiService(); // 네이버 서비스 추가
  final ConfigService _configService = ConfigService();
  final NetworkService _networkService = NetworkService();
  final OfflineCacheService _cacheService = OfflineCacheService();

  /// 메뉴 추천 요청을 처리하여 음식점 목록 반환 (오프라인 모드 대응)
  Future<List<Restaurant>> getRecommendations(RecommendationRequest request) async {
    // 네트워크 상태 확인
    if (!_networkService.isOnline) {
      print('📱 오프라인 모드: 캐시된 데이터 또는 샘플 데이터 사용');
      return await _getOfflineRecommendations(request);
    }

    if (_configService.useRealApi) {
      try {
        List<Restaurant> apiRestaurants = [];
        List<Future<List<Restaurant>>> futures = [];

        // 선호 카테고리가 있다면 해당 카테고리로 검색
        if (request.preferences?.preferredCategories.isNotEmpty == true) {
          for (String category in request.preferences!.preferredCategories) {
            if (_configService.hasValidKakaoApiKey) {
              futures.add(_kakaoApiService.searchRestaurantsByKeyword(
                keyword: category,
                latitude: request.userLocation.latitude,
                longitude: request.userLocation.longitude,
                radius: 5000,
                size: 5,
              ));
            }
            if (_configService.hasValidNaverApiKey) {
              futures.add(_naverApiService.searchRestaurantsByKeyword(
                keyword: category,
                display: 5,
              ));
            }
          }
        } else {
          // 선호 카테고리가 없다면 일반적인 맛집 검색
          if (_configService.hasValidKakaoApiKey) {
            futures.add(_kakaoApiService.searchRestaurantsByKeyword(
              keyword: '맛집',
              latitude: request.userLocation.latitude,
              longitude: request.userLocation.longitude,
              radius: 5000,
              size: 10,
            ));
          }
          if (_configService.hasValidNaverApiKey) {
            futures.add(_naverApiService.searchRestaurantsByKeyword(
              keyword: '맛집',
              display: 10,
            ));
          }
        }

        final results = await Future.wait(futures);
        for (var result in results) {
          apiRestaurants.addAll(result);
        }

        if (apiRestaurants.isNotEmpty) {
          return _processApiResults(apiRestaurants, request);
        }
      } catch (e) {
        print('API 추천 검색 실패, 샘플 데이터 사용: $e');
      }
    } else {
      print('개발 모드: 샘플 데이터 사용');
    }

    return _getSampleData(request);
  }

  /// 현재 시간 기반 빠른 추천
  Future<List<Restaurant>> getQuickRecommendations({
    required UserLocation userLocation,
    required int numberOfPeople,
  }) async {
    final currentHour = DateTime.now().hour;
    String mealTime;

    // 시간대별 식사 종류 결정
    if (currentHour >= 6 && currentHour < 10) {
      mealTime = 'breakfast';
    } else if (currentHour >= 10 && currentHour < 15) {
      mealTime = 'lunch';
    } else if (currentHour >= 15 && currentHour < 18) {
      mealTime = 'snack';
    } else {
      mealTime = 'dinner';
    }

    final request = RecommendationRequest.now(
      userLocation: userLocation,
      numberOfPeople: numberOfPeople,
      mealTime: mealTime,
    );

    return getRecommendations(request);
  }

  /// 카테고리별 추천 (실제 API 사용)
  Future<List<Restaurant>> getRecommendationsByCategory({
    required UserLocation userLocation,
    required String category,
    int limit = 5,
  }) async {
    if (_configService.useRealApi) {
      print('--- API 모드: 카테고리별 추천 ($category) ---');
      try {
        List<Restaurant> apiRestaurants = [];
        List<Future<List<Restaurant>>> futures = [];

        if (_configService.hasValidKakaoApiKey) {
          print('  [Kakao] API 호출 시도');
          futures.add(_kakaoApiService.searchRestaurantsByKeyword(
            keyword: category,
            latitude: userLocation.latitude,
            longitude: userLocation.longitude,
            radius: 3000,
            size: limit,
          ).catchError((e) {
            print('  [Kakao] API 오류: $e');
            return <Restaurant>[];
          }));
        }
        if (_configService.hasValidNaverApiKey) {
          print('  [Naver] API 호출 시도');
          futures.add(_naverApiService.searchRestaurantsByKeyword(
            keyword: category,
            display: limit,
          ).catchError((e) {
            print('  [Naver] API 오류: $e');
            return <Restaurant>[];
          }));
        }

        final results = await Future.wait(futures);
        for (var result in results) {
          apiRestaurants.addAll(result);
        }

        print('--- 총 ${apiRestaurants.length}개의 결과를 찾았습니다 ---');

        if (apiRestaurants.isNotEmpty) {
          return _processApiResults(apiRestaurants, RecommendationRequest.now(userLocation: userLocation, numberOfPeople: 1, mealTime: 'any'));
        }
      } catch (e) {
        print('API 호출 실패, 샘플 데이터 사용: $e');
      }
    } else {
      print('개발 모드: 샘플 데이터 사용 (카테고리: $category)');
    }

    // API 호출 실패 시 또는 개발 모드일 때: 샘플 데이터 사용
    List<Restaurant> allRestaurants = _getAllRestaurants();
    List<Restaurant> categoryRestaurants = allRestaurants
        .where((restaurant) => restaurant.category == category)
        .toList();
    categoryRestaurants = _sortByDistance(categoryRestaurants, userLocation);
    return categoryRestaurants.take(limit).toList();
  }

  List<Restaurant> _processApiResults(List<Restaurant> restaurants, RecommendationRequest request) {
    List<Restaurant> filteredRestaurants = _filterRestaurants(restaurants, request);
    Map<String, Restaurant> uniqueRestaurants = {};
    for (Restaurant restaurant in filteredRestaurants) {
      uniqueRestaurants[restaurant.name] = restaurant; // 이름으로 중복 제거
    }
    List<Restaurant> finalResults = uniqueRestaurants.values.toList();
    finalResults = _sortByDistance(finalResults, request.userLocation);
    return finalResults.take(10).toList();
  }

  List<Restaurant> _getSampleData(RecommendationRequest request) {
    List<Restaurant> allRestaurants = _getAllRestaurants();
    List<Restaurant> filteredRestaurants = _filterRestaurants(allRestaurants, request);
    filteredRestaurants = _sortByDistance(filteredRestaurants, request.userLocation);
    return filteredRestaurants.take(10).toList();
  }


  /// 인기 음식점 추천
  Future<List<Restaurant>> getPopularRestaurants({
    required UserLocation userLocation,
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    List<Restaurant> allRestaurants = _getAllRestaurants();
    
    // 평점 기준으로 정렬 (4.0 이상)
    allRestaurants = allRestaurants
        .where((restaurant) => restaurant.rating >= 4.0)
        .toList();
    
    allRestaurants.sort((a, b) => b.rating.compareTo(a.rating));

    return allRestaurants.take(limit).toList();
  }

  /// 모든 음식점 데이터 가져오기 (실제로는 API나 로컬 DB에서)
  List<Restaurant> _getAllRestaurants() {
    // 샘플 데이터에 더 많은 음식점 추가
    final sampleRestaurants = SampleData.getSampleRestaurants();
    
    // 추가 샘플 데이터
    final additionalRestaurants = [
      Restaurant(
        id: '4',
        name: '중국집 맛집',
        category: '중식',
        rating: 4.3,
        priceLevel: 2,
        address: '서울시 강남구 역삼로 100',
        latitude: 37.5010,
        longitude: 127.0280,
        isOpen: true,
      ),
      Restaurant(
        id: '5',
        name: '프리미엄 스테이크',
        category: '양식',
        rating: 4.8,
        priceLevel: 4,
        address: '서울시 강남구 압구정로 200',
        latitude: 37.5200,
        longitude: 127.0300,
        isOpen: true,
      ),
      Restaurant(
        id: '6',
        name: '분식집 추억',
        category: '분식',
        rating: 4.0,
        priceLevel: 1,
        address: '서울시 강남구 봉은사로 300',
        latitude: 37.4950,
        longitude: 127.0250,
        isOpen: true,
      ),
      Restaurant(
        id: '7',
        name: '치킨 맛있는집',
        category: '치킨',
        rating: 4.4,
        priceLevel: 2,
        address: '서울시 강남구 강남대로 400',
        latitude: 37.4980,
        longitude: 127.0270,
        isOpen: true,
      ),
      Restaurant(
        id: '8',
        name: '카페 브런치',
        category: '카페',
        rating: 4.1,
        priceLevel: 2,
        address: '서울시 강남구 신사동 500',
        latitude: 37.5150,
        longitude: 127.0200,
        isOpen: false,
      ),
    ];

    return [...sampleRestaurants, ...additionalRestaurants];
  }

  /// 추천 요청에 따라 음식점 필터링
  List<Restaurant> _filterRestaurants(
    List<Restaurant> restaurants,
    RecommendationRequest request,
  ) {
    return restaurants.where((restaurant) {
      // 영업 중인 음식점만
      if (!restaurant.isOpen) return false;

      // 선호도가 있다면 적용
      if (request.preferences != null) {
        final prefs = request.preferences!;
        
        // 최대 가격 수준 확인
        if (prefs.maxPriceLevel != null && 
            restaurant.priceLevel > prefs.maxPriceLevel!) {
          return false;
        }

        // 최소 평점 확인
        if (prefs.minRating != null && 
            restaurant.rating < prefs.minRating!) {
          return false;
        }

        // 제외할 카테고리 확인
        if (prefs.excludedCategories.contains(restaurant.category)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// 거리 기준으로 음식점 정렬
  List<Restaurant> _sortByDistance(
    List<Restaurant> restaurants,
    UserLocation userLocation,
  ) {
    // 각 음식점까지의 거리 계산하여 정렬
    restaurants.sort((a, b) {
      final distanceA = _locationService.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        a.latitude,
        a.longitude,
      );
      
      final distanceB = _locationService.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        b.latitude,
        b.longitude,
      );
      
      return distanceA.compareTo(distanceB);
    });

    return restaurants;
  }

  /// 사용자 선호도 기반 점수 계산
  double _calculatePreferenceScore(Restaurant restaurant, User user) {
    double score = restaurant.rating; // 기본 점수는 평점

    // 선호 카테고리라면 가산점
    if (user.preferences.favoriteCategories.contains(restaurant.category)) {
      score += 1.0;
    }

    // 싫어하는 카테고리라면 감점
    if (user.preferences.dislikedCategories.contains(restaurant.category)) {
      score -= 2.0;
    }

    // 선호 가격대와 일치하면 가산점
    if (restaurant.priceLevel == user.preferences.preferredPriceLevel) {
      score += 0.5;
    }

    return score;
  }

  /// 추천 이유 생성
  String getRecommendationReason(Restaurant restaurant, RecommendationRequest request) {
    final reasons = <String>[];

    // 거리
    final distance = _locationService.calculateDistance(
      request.userLocation.latitude,
      request.userLocation.longitude,
      restaurant.latitude,
      restaurant.longitude,
    );
    
    if (distance < 0.5) {
      reasons.add('가까운 거리');
    }

    // 평점
    if (restaurant.rating >= 4.5) {
      reasons.add('높은 평점 (${restaurant.ratingText}점)');
    }

    // 가격대
    if (restaurant.priceLevel <= 2) {
      reasons.add('합리적인 가격');
    }

    // 식사 시간
    if (request.mealTime == 'lunch' && restaurant.category == '한식') {
      reasons.add('점심 추천 메뉴');
    } else if (request.mealTime == 'dinner' && restaurant.priceLevel >= 3) {
      reasons.add('저녁 식사 추천');
    }

    return reasons.isEmpty ? '추천 맛집' : reasons.join(', ');
  }
} 