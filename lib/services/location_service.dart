import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';

/// 위치 관련 서비스
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 위치 권한 확인 및 요청
  Future<bool> checkAndRequestLocationPermission() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw '위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.';
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw '위치 권한이 거부되었습니다.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw '위치 권한이 영구적으로 거부되었습니다. 설정에서 직접 권한을 허용해주세요.';
      }

      return true;
    } catch (e) {
      throw '위치 권한 확인 실패: $e';
    }
  }

  /// 현재 위치 가져오기 (실제 GPS 사용)
  Future<UserLocation> getCurrentLocation() async {
    try {
      // 위치 권한 확인
      bool hasPermission = await checkAndRequestLocationPermission();
      if (!hasPermission) {
        throw '위치 권한이 없습니다.';
      }

      // GPS 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // 좌표를 주소로 변환 (현재는 시뮬레이션, 실제로는 Geocoding API 사용)
      String address = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude,
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      // GPS 실패 시 기본값 반환
      print('GPS 위치 가져오기 실패: $e');
      return const UserLocation(
        latitude: 37.4979517,
        longitude: 127.0276188,
        address: '강남역',
      );
    }
  }

  /// 좌표를 주소로 변환 (Reverse Geocoding)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // TODO: 실제 서비스에서는 Geocoding API 사용
      // 예시:
      // - Google Maps Geocoding API
      // - 카카오맵 좌표→주소 변환 API
      // - 네이버 지도 Reverse Geocoding API
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 임시: 간단한 지역 추정 (실제로는 API 결과 사용)
      String location = await _getSimpleLocationName(latitude, longitude);
      
      return location;
    } catch (e) {
      print('주소 변환 실패: $e');
      return '현재 위치';
    }
  }

  /// 간단한 위치명 추정 (API 대신 임시 사용)
  Future<String> _getSimpleLocationName(double latitude, double longitude) async {
    print('🌍 GPS 좌표: $latitude, $longitude');
    
    // 서울인지 확인
    if (latitude >= 37.4 && latitude <= 37.7 && longitude >= 126.8 && longitude <= 127.2) {
      // 강남구 대략적 범위
      if (latitude >= 37.47 && latitude <= 37.54 && longitude >= 127.01 && longitude <= 127.08) {
        return '강남구';
      }
      // 마포구 대략적 범위  
      if (latitude >= 37.54 && latitude <= 37.58 && longitude >= 126.90 && longitude <= 126.95) {
        return '마포구';
      }
      // 서초구 대략적 범위
      if (latitude >= 37.46 && latitude <= 37.50 && longitude >= 127.00 && longitude <= 127.05) {
        return '서초구';
      }
      return '서울특별시';
    }
    
    return '현재 위치';
  }

  /// 좌표로 세분화된 지역 추정
  String _estimateAddressFromCoordinates(double latitude, double longitude) {
    print('🌍 GPS 좌표: $latitude, $longitude'); // 디버그용 로그
    
    // 강남구 세분화
    if (latitude >= 37.47 && latitude <= 37.54 && longitude >= 127.01 && longitude <= 127.08) {
      // 개포동 지역
      if (latitude >= 37.478 && latitude <= 37.495 && longitude >= 127.055 && longitude <= 127.075) {
        return '개포동';
      }
      // 도곡동 지역
      if (latitude >= 37.485 && latitude <= 37.505 && longitude >= 127.045 && longitude <= 127.065) {
        return '도곡동';
      }
      // 대치동 지역
      if (latitude >= 37.495 && latitude <= 37.515 && longitude >= 127.045 && longitude <= 127.065) {
        return '대치동';
      }
      // 역삼동 지역
      if (latitude >= 37.498 && latitude <= 37.518 && longitude >= 127.025 && longitude <= 127.045) {
        return '역삼동';
      }
      // 강남역 근처
      if (latitude >= 37.495 && latitude <= 37.505 && longitude >= 127.025 && longitude <= 127.035) {
        return '강남역';
      }
      // 선릉역 근처
      if (latitude >= 37.500 && latitude <= 37.510 && longitude >= 127.045 && longitude <= 127.055) {
        return '선릉역';
      }
      // 삼성동 지역
      if (latitude >= 37.505 && latitude <= 37.525 && longitude >= 127.055 && longitude <= 127.075) {
        return '삼성동';
      }
      // 압구정동 지역
      if (latitude >= 37.515 && latitude <= 37.535 && longitude >= 127.025 && longitude <= 127.045) {
        return '압구정동';
      }
      // 청담동 지역
      if (latitude >= 37.520 && latitude <= 37.540 && longitude >= 127.045 && longitude <= 127.065) {
        return '청담동';
      }
      return '강남구';
    }
    
    // 서초구 세분화
    if (latitude >= 37.46 && latitude <= 37.50 && longitude >= 127.00 && longitude <= 127.05) {
      // 서초동 지역
      if (latitude >= 37.485 && latitude <= 37.505 && longitude >= 127.015 && longitude <= 127.035) {
        return '서초동';
      }
      // 반포동 지역
      if (latitude >= 37.500 && latitude <= 37.520 && longitude >= 127.005 && longitude <= 127.025) {
        return '반포동';
      }
      return '서초구';
    }
    
    // 마포구 세분화
    if (latitude >= 37.54 && latitude <= 37.58 && longitude >= 126.90 && longitude <= 126.95) {
      // 홍대 지역
      if (latitude >= 37.548 && latitude <= 37.558 && longitude >= 126.920 && longitude <= 126.930) {
        return '홍대입구';
      }
      // 합정 지역
      if (latitude >= 37.548 && latitude <= 37.558 && longitude >= 126.908 && longitude <= 126.918) {
        return '합정동';
      }
      // 상수동 지역
      if (latitude >= 37.545 && latitude <= 37.555 && longitude >= 126.920 && longitude <= 126.930) {
        return '상수동';
      }
      return '마포구';
    }
    
    // 중구 세분화
    if (latitude >= 37.55 && latitude <= 37.58 && longitude >= 126.97 && longitude <= 127.00) {
      // 명동 지역
      if (latitude >= 37.560 && latitude <= 37.570 && longitude >= 126.980 && longitude <= 126.990) {
        return '명동';
      }
      // 시청 지역
      if (latitude >= 37.565 && latitude <= 37.575 && longitude >= 126.975 && longitude <= 126.985) {
        return '시청';
      }
      return '중구';
    }
    
    // 용산구 세분화
    if (latitude >= 37.52 && latitude <= 37.56 && longitude >= 126.97 && longitude <= 127.02) {
      // 이태원 지역
      if (latitude >= 37.530 && latitude <= 37.540 && longitude >= 126.990 && longitude <= 127.000) {
        return '이태원';
      }
      // 한남동 지역
      if (latitude >= 37.530 && latitude <= 37.540 && longitude >= 127.000 && longitude <= 127.010) {
        return '한남동';
      }
      return '용산구';
    }
    
    // 송파구 세분화
    if (latitude >= 37.47 && latitude <= 37.52 && longitude >= 127.08 && longitude <= 127.14) {
      // 잠실 지역
      if (latitude >= 37.510 && latitude <= 37.520 && longitude >= 127.080 && longitude <= 127.090) {
        return '잠실동';
      }
      // 문정동 지역
      if (latitude >= 37.485 && latitude <= 37.495 && longitude >= 127.115 && longitude <= 127.125) {
        return '문정동';
      }
      return '송파구';
    }
    
    // 기본값 (서울 내 다른 지역)
    if (latitude >= 37.4 && latitude <= 37.7 && longitude >= 126.8 && longitude <= 127.2) {
      return '서울특별시';
    }
    
    return '현재 위치';
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
    
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);
    final double deltaLat = (lat2 - lat1) * (math.pi / 180);
    final double deltaLon = (lon2 - lon1) * (math.pi / 180);
    
    final double a = (math.sin(deltaLat / 2) * math.sin(deltaLat / 2)) +
        (math.cos(lat1Rad) * math.cos(lat2Rad) * math.sin(deltaLon / 2) * math.sin(deltaLon / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
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

  /// 위치 스트림 (실시간 위치 추적용)
  Stream<UserLocation> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터 이상 이동 시 업데이트
      ),
    ).asyncMap((position) async {
      String address = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    });
  }

  /// 위치 서비스 활성화 여부 확인
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 위치 권한 상태 확인
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// 앱 설정으로 이동
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// 위치 설정으로 이동
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
} 