import '../models/models.dart';

/// 위치 관련 서비스
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 현재 위치 가져오기 (시뮬레이션)
  Future<UserLocation> getCurrentLocation() async {
    // 실제 앱에서는 geolocator 패키지를 사용하여 GPS 위치를 가져옵니다
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // 강남역 좌표로 하드코딩 (테스트용)
    return const UserLocation(
      latitude: 37.4979517,
      longitude: 127.0276188,
      address: '강남역',
    );
  }

  /// 좌표를 주소로 변환 (Reverse Geocoding)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    // 실제 앱에서는 Google Maps API나 카카오 API를 사용합니다
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 시뮬레이션된 주소 반환
    final mockAddresses = {
      '37.4979517,127.0276188': '서울특별시 강남구 강남대로 396 (강남역)',
      '37.5665,126.9780': '서울특별시 중구 세종대로 110 (시청)',
      '37.5172,127.0473': '서울특별시 강남구 테헤란로 152 (역삼역)',
    };
    
    final key = '${latitude.toStringAsFixed(7)},${longitude.toStringAsFixed(7)}';
    return mockAddresses[key] ?? '서울특별시 강남구';
  }

  /// 주소를 좌표로 변환 (Geocoding)
  Future<UserLocation?> getLocationFromAddress(String address) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 시뮬레이션된 좌표 반환
    final mockLocations = {
      '강남역': const UserLocation(
        latitude: 37.4979517,
        longitude: 127.0276188,
        address: '강남역',
      ),
      '역삼역': const UserLocation(
        latitude: 37.5172,
        longitude: 127.0473,
        address: '역삼역',
      ),
      '시청': const UserLocation(
        latitude: 37.5665,
        longitude: 126.9780,
        address: '시청',
      ),
    };
    
    return mockLocations[address];
  }

  /// 두 위치 간 거리 계산 (km)
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    // Haversine 공식을 사용한 거리 계산
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    final double lat1Rad = lat1 * (3.14159 / 180);
    final double lat2Rad = lat2 * (3.14159 / 180);
    final double deltaLat = (lat2 - lat1) * (3.14159 / 180);
    final double deltaLon = (lon2 - lon1) * (3.14159 / 180);
    
    final double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        (cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// 근처 지역 추천
  List<String> getNearbyAreas(UserLocation location) {
    // 현재 위치 기반으로 근처 지역 반환
    if (location.address?.contains('강남') == true) {
      return ['강남역', '역삼역', '선릉역', '압구정역'];
    } else if (location.address?.contains('홍대') == true) {
      return ['홍대입구역', '합정역', '상수역', '마포구청역'];
    } else {
      return ['강남역', '홍대입구역', '명동역', '이태원역'];
    }
  }

  // 수학 함수들 (dart:math를 import하지 않고 직접 구현)
  double sin(double x) => _sin(x);
  double cos(double x) => _cos(x);
  double sqrt(double x) => _sqrt(x);
  double atan2(double y, double x) => _atan2(y, x);

  // 간단한 수학 함수 구현 (정확도는 제한적)
  double _sin(double x) {
    // Taylor series approximation
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _cos(double x) {
    // Taylor series approximation
    double result = 1;
    double term = 1;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159;
    if (x == 0 && y > 0) return 3.14159 / 2;
    if (x == 0 && y < 0) return -3.14159 / 2;
    return 0; // x == 0 && y == 0
  }

  double _atan(double x) {
    // Taylor series approximation for small values
    if (x.abs() > 1) {
      return (3.14159 / 2) - _atan(1 / x);
    }
    
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }
} 