import 'package:flutter/foundation.dart';
import '../services/services.dart';

/// 위치 정보 상태 관리
class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  String _currentLocation = '강남역'; // 기본 위치
  List<String> _favoriteLocations = [];
  List<String> _nearbyLocations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  String get currentLocation => _currentLocation;
  List<String> get favoriteLocations => List.unmodifiable(_favoriteLocations);
  List<String> get nearbyLocations => List.unmodifiable(_nearbyLocations);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 현재 위치 초기화
  Future<void> initializeLocation() async {
    _setLoading(true);
    try {
      // 실제 GPS 위치 서비스 연동
      final userLocation = await _locationService.getCurrentLocation();
      _currentLocation = userLocation.address ?? '강남역';
      await _loadNearbyLocations();
      _clearError();
    } catch (e) {
      _setError('위치 정보를 불러올 수 없습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 현재 위치 업데이트
  Future<void> updateCurrentLocation(String newLocation) async {
    _setLoading(true);
    try {
      _currentLocation = newLocation;
      await _loadNearbyLocations();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('위치 업데이트에 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// GPS를 통한 현재 위치 가져오기
  Future<void> getCurrentLocationFromGPS() async {
    _setLoading(true);
    try {
      final userLocation = await _locationService.getCurrentLocation();
      _currentLocation = userLocation.address ?? '강남역';
      await _loadNearbyLocations();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('GPS 위치를 가져올 수 없습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 즐겨찾기 위치 추가
  Future<void> addFavoriteLocation(String location) async {
    if (_favoriteLocations.contains(location)) return;
    
    try {
      _favoriteLocations.add(location);
      // TODO: SharedPreferences에 저장
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('즐겨찾기 추가에 실패했습니다: $e');
    }
  }

  /// 즐겨찾기 위치 제거
  Future<void> removeFavoriteLocation(String location) async {
    try {
      _favoriteLocations.remove(location);
      // TODO: SharedPreferences에서 제거
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('즐겨찾기 제거에 실패했습니다: $e');
    }
  }

  /// 근처 위치 목록 로드
  Future<void> _loadNearbyLocations() async {
    try {
      // 현재 위치를 UserLocation으로 변환하여 근처 지역 가져오기
      final userLocation = await _locationService.getLocationFromAddress(_currentLocation);
      if (userLocation != null) {
        _nearbyLocations = _locationService.getNearbyAreas(userLocation);
      } else {
        _nearbyLocations = ['강남역', '역삼역', '선릉역', '압구정역']; // 기본값
      }
    } catch (e) {
      // 근처 위치 로드 실패는 심각한 에러가 아니므로 조용히 처리
      debugPrint('근처 위치 로드 실패: $e');
      _nearbyLocations = ['강남역', '역삼역', '선릉역', '압구정역'];
    }
  }

  /// 위치 검색
  Future<List<String>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    
    try {
      // 간단한 위치 검색 시뮬레이션
      const allLocations = [
        '강남역', '역삼역', '선릉역', '압구정역',
        '홍대입구역', '합정역', '상수역', '마포구청역',
        '명동역', '을지로입구역', '종로3가역', '동대문역',
        '이태원역', '한강진역', '서울역', '시청역',
      ];
      
      return allLocations
          .where((location) => location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      _setError('위치 검색에 실패했습니다: $e');
      return [];
    }
  }

  /// 두 위치 간의 거리 계산
  Future<double> calculateDistance(String fromLocation, String toLocation) async {
    try {
      final fromUserLocation = await _locationService.getLocationFromAddress(fromLocation);
      final toUserLocation = await _locationService.getLocationFromAddress(toLocation);
      
      if (fromUserLocation != null && toUserLocation != null) {
        return _locationService.calculateDistance(
          fromUserLocation.latitude, 
          fromUserLocation.longitude,
          toUserLocation.latitude,
          toUserLocation.longitude,
        );
      }
      return 0.0;
    } catch (e) {
      debugPrint('거리 계산 실패: $e');
      return 0.0;
    }
  }

  /// 즐겨찾기 위치 로드 (앱 시작 시)
  Future<void> loadFavoriteLocations() async {
    try {
      // TODO: SharedPreferences에서 로드
      _favoriteLocations = [
        '강남역',
        '홍대입구',
        '명동',
      ]; // 임시 데이터
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('즐겨찾기 로드에 실패했습니다: $e');
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
} 