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
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 좌표 기반 지역 추정 (실제로는 Geocoding API 사용)
      String estimatedAddress = _estimateAddressFromCoordinates(latitude, longitude);
      
      return estimatedAddress;
    } catch (e) {
      print('주소 변환 실패: $e');
      return '서울특별시';
    }
  }

  /// 좌표로 대략적인 지역 추정
  String _estimateAddressFromCoordinates(double latitude, double longitude) {
    // 서울 주요 지역 좌표 범위 (실제로는 더 정확한 Geocoding API 사용)
    
    // 강남구 지역 (강남역, 역삼역, 선릉역 등)
    if (latitude >= 37.49 && latitude <= 37.53 && longitude >= 127.02 && longitude <= 127.07) {
      if (latitude <= 37.50 && longitude <= 127.04) return '강남역';
      if (latitude <= 37.52 && longitude <= 127.05) return '역삼역';
      if (latitude <= 37.53 && longitude <= 127.06) return '선릉역';
      return '강남구';
    }
    
    // 마포구 지역 (홍대, 합정, 상수 등)
    if (latitude >= 37.54 && latitude <= 37.57 && longitude >= 126.91 && longitude <= 126.94) {
      if (longitude <= 126.925) return '홍대입구역';
      if (longitude <= 126.935) return '합정역';
      return '마포구';
    }
    
    // 중구 지역 (명동, 시청 등)
    if (latitude >= 37.56 && latitude <= 37.58 && longitude >= 126.97 && longitude <= 126.99) {
      if (longitude >= 126.985) return '명동역';
      return '시청역';
    }
    
    // 용산구 지역 (이태원, 한강진 등)
    if (latitude >= 37.53 && latitude <= 37.55 && longitude >= 126.98 && longitude <= 127.01) {
      return '이태원역';
    }
    
    // 기본값
    return '서울특별시';
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