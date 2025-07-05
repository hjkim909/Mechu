import '../models/models.dart';

/// 샘플 데이터 및 모델 사용 예제
class SampleData {
  /// 샘플 음식점 데이터
  static List<Restaurant> getSampleRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: '맛있는 한식당',
        category: '한식',
        rating: 4.5,
        priceLevel: 2,
        address: '서울시 강남구 강남대로 123',
        latitude: 37.4979517,
        longitude: 127.0276188,
        isOpen: true,
      ),
      Restaurant(
        id: '2',
        name: '이탈리아 파스타',
        category: '양식',
        rating: 4.2,
        priceLevel: 3,
        address: '서울시 강남구 테헤란로 456',
        latitude: 37.4998886,
        longitude: 127.0374590,
        isOpen: true,
      ),
      Restaurant(
        id: '3',
        name: '일본 라멘집',
        category: '일식',
        rating: 4.7,
        priceLevel: 2,
        address: '서울시 강남구 논현로 789',
        latitude: 37.5048445,
        longitude: 127.0438117,
        isOpen: false,
      ),
    ];
  }

  /// 샘플 사용자 데이터
  static User getSampleUser() {
    final preferences = UserPreferences(
      favoriteCategories: ['한식', '일식'],
      dislikedCategories: ['매운맛'],
      preferredPriceLevel: 2,
      minRating: 4.0,
      vegetarian: false,
      halal: false,
      allergies: ['견과류'],
    );

    return User.create(
      id: 'user_001',
      name: '김메뉴',
      preferences: preferences,
    );
  }

  /// 샘플 추천 요청 데이터
  static RecommendationRequest getSampleRequest() {
    final userLocation = UserLocation(
      latitude: 37.4979517,
      longitude: 127.0276188,
      address: '강남역',
    );

    final preferences = RecommendationPreferences(
      preferredCategories: ['한식', '일식'],
      excludedCategories: ['매운맛'],
      maxPriceLevel: 3,
      minRating: 4.0,
    );

    return RecommendationRequest.now(
      userLocation: userLocation,
      numberOfPeople: 2,
      mealTime: 'lunch',
      preferences: preferences,
    );
  }

  /// JSON 변환 사용 예제
  static void demonstrateJsonSerialization() {
    // Restaurant 예제
    final restaurant = getSampleRestaurants().first;
    final restaurantJson = restaurant.toJson();
    final restoredRestaurant = Restaurant.fromJson(restaurantJson);
    
    print('Restaurant JSON: $restaurantJson');
    print('Restored: $restoredRestaurant');

    // User 예제
    final user = getSampleUser();
    final userJson = user.toJson();
    final restoredUser = User.fromJson(userJson);
    
    print('User JSON: $userJson');
    print('Restored: $restoredUser');

    // RecommendationRequest 예제
    final request = getSampleRequest();
    final requestJson = request.toJson();
    final restoredRequest = RecommendationRequest.fromJson(requestJson);
    
    print('Request JSON: $requestJson');
    print('Restored: $restoredRequest');
  }
} 