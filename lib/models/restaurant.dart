import 'package:json_annotation/json_annotation.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int priceLevel; // 1: 저렴, 2: 보통, 3: 비쌈, 4: 매우 비쌈
  final String address;
  final double latitude;
  final double longitude;
  final bool isOpen;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.priceLevel,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
  });

  /// JSON에서 Restaurant 객체 생성
  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  /// Restaurant 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$RestaurantToJson(this);

  /// 가격 레벨을 문자열로 반환
  String get priceLevelText {
    switch (priceLevel) {
      case 1:
        return '저렴';
      case 2:
        return '보통';
      case 3:
        return '비쌈';
      case 4:
        return '매우 비쌈';
      default:
        return '알 수 없음';
    }
  }

  /// 별점을 문자열로 반환
  String get ratingText => rating.toStringAsFixed(1);

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, category: $category, rating: $rating, priceLevel: $priceLevel, address: $address, isOpen: $isOpen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Restaurant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 