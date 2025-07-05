import 'package:json_annotation/json_annotation.dart';

part 'recommendation_request.g.dart';

@JsonSerializable()
class UserLocation {
  final double latitude;
  final double longitude;
  final String? address; // 주소 (선택적)

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);

  @override
  String toString() {
    return 'UserLocation(latitude: $latitude, longitude: $longitude, address: $address)';
  }
}

@JsonSerializable()
class RecommendationPreferences {
  final List<String> preferredCategories; // 선호 음식 카테고리
  final List<String> excludedCategories; // 제외할 음식 카테고리
  final int? maxPriceLevel; // 최대 가격 수준
  final double? minRating; // 최소 평점

  const RecommendationPreferences({
    this.preferredCategories = const [],
    this.excludedCategories = const [],
    this.maxPriceLevel,
    this.minRating,
  });

  factory RecommendationPreferences.fromJson(Map<String, dynamic> json) =>
      _$RecommendationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationPreferencesToJson(this);
}

@JsonSerializable()
class RecommendationRequest {
  final UserLocation userLocation;
  final int numberOfPeople;
  final String mealTime; // breakfast, lunch, dinner, snack
  final RecommendationPreferences? preferences;
  final DateTime requestTime;

  const RecommendationRequest({
    required this.userLocation,
    required this.numberOfPeople,
    required this.mealTime,
    this.preferences,
    required this.requestTime,
  });

  /// JSON에서 RecommendationRequest 객체 생성
  factory RecommendationRequest.fromJson(Map<String, dynamic> json) =>
      _$RecommendationRequestFromJson(json);

  /// RecommendationRequest 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$RecommendationRequestToJson(this);

  /// 현재 시간으로 추천 요청 생성
  factory RecommendationRequest.now({
    required UserLocation userLocation,
    required int numberOfPeople,
    required String mealTime,
    RecommendationPreferences? preferences,
  }) {
    return RecommendationRequest(
      userLocation: userLocation,
      numberOfPeople: numberOfPeople,
      mealTime: mealTime,
      preferences: preferences,
      requestTime: DateTime.now(),
    );
  }

  /// 식사 시간을 한국어로 반환
  String get mealTimeKorean {
    switch (mealTime.toLowerCase()) {
      case 'breakfast':
        return '아침';
      case 'lunch':
        return '점심';
      case 'dinner':
        return '저녁';
      case 'snack':
        return '간식';
      default:
        return '식사';
    }
  }

  @override
  String toString() {
    return 'RecommendationRequest(userLocation: $userLocation, numberOfPeople: $numberOfPeople, mealTime: $mealTime, requestTime: $requestTime)';
  }
} 