import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserPreferences {
  final List<String> favoriteCategories; // 선호하는 음식 카테고리
  final List<String> dislikedCategories; // 싫어하는 음식 카테고리
  final int preferredPriceLevel; // 선호하는 가격 수준 (1-4)
  final double minRating; // 최소 선호 평점
  final bool vegetarian; // 채식주의자 여부
  final bool halal; // 할랄 음식 선호 여부
  final List<String> allergies; // 알레르기 정보

  const UserPreferences({
    this.favoriteCategories = const [],
    this.dislikedCategories = const [],
    this.preferredPriceLevel = 2,
    this.minRating = 3.0,
    this.vegetarian = false,
    this.halal = false,
    this.allergies = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  /// 기본 설정 생성
  factory UserPreferences.defaultPreferences() {
    return const UserPreferences();
  }

  /// 설정 복사 및 수정
  UserPreferences copyWith({
    List<String>? favoriteCategories,
    List<String>? dislikedCategories,
    int? preferredPriceLevel,
    double? minRating,
    bool? vegetarian,
    bool? halal,
    List<String>? allergies,
  }) {
    return UserPreferences(
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      dislikedCategories: dislikedCategories ?? this.dislikedCategories,
      preferredPriceLevel: preferredPriceLevel ?? this.preferredPriceLevel,
      minRating: minRating ?? this.minRating,
      vegetarian: vegetarian ?? this.vegetarian,
      halal: halal ?? this.halal,
      allergies: allergies ?? this.allergies,
    );
  }
}

@JsonSerializable()
class User {
  final String id;
  final String name;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.name,
    required this.preferences,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// JSON에서 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// 새 사용자 생성
  factory User.create({
    required String id,
    required String name,
    UserPreferences? preferences,
  }) {
    return User(
      id: id,
      name: name,
      preferences: preferences ?? UserPreferences.defaultPreferences(),
      createdAt: DateTime.now(),
    );
  }

  /// 사용자 정보 업데이트
  User copyWith({
    String? name,
    UserPreferences? preferences,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// 로그인 시간 업데이트
  User updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// 사용자가 특정 카테고리를 선호하는지 확인
  bool likesCuisine(String category) {
    return preferences.favoriteCategories.contains(category) &&
        !preferences.dislikedCategories.contains(category);
  }

  /// 사용자가 특정 카테고리를 싫어하는지 확인
  bool dislikesCuisine(String category) {
    return preferences.dislikedCategories.contains(category);
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 