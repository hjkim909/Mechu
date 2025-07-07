import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 메뉴 추천 상태 관리
class RecommendationProvider with ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();
  
  List<Restaurant> _recommendations = [];
  List<Restaurant> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  RecommendationRequest? _lastRequest;

  // Getters
  List<Restaurant> get recommendations => List.unmodifiable(_recommendations);
  List<Restaurant> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get error => _error;
  RecommendationRequest? get lastRequest => _lastRequest;
  bool get hasRecommendations => _recommendations.isNotEmpty;

  /// 메뉴 추천 요청
  Future<void> getRecommendations({
    required String location,
    required int peopleCount,
    User? user,
  }) async {
    _setLoading(true);
    
    try {
      // 위치를 UserLocation으로 변환
      final locationService = LocationService();
      final userLocation = await locationService.getLocationFromAddress(location) 
          ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
      
      // 추천 요청 생성
      _lastRequest = RecommendationRequest.now(
        userLocation: userLocation,
        numberOfPeople: peopleCount,
        mealTime: _getCurrentMealTime(),
      );

      // 추천 받기
      _recommendations = await _recommendationService.getRecommendations(_lastRequest!);

      _clearError();
    } catch (e) {
      _setError('추천을 불러올 수 없습니다: $e');
      _recommendations = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 카테고리별 추천
  Future<void> getRecommendationsByCategory({
    required String location,
    required String category,
    User? user,
  }) async {
    _setLoading(true);
    
    try {
      // 위치를 UserLocation으로 변환
      final locationService = LocationService();
      final userLocation = await locationService.getLocationFromAddress(location) 
          ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
      
      _recommendations = await _recommendationService.getRecommendationsByCategory(
        userLocation: userLocation,
        category: category,
      );
      _clearError();
    } catch (e) {
      _setError('카테고리별 추천을 불러올 수 없습니다: $e');
      _recommendations = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 시간대별 추천 (빠른 추천 사용)
  Future<void> getRecommendationsByTime({
    required String location,
    required DateTime dateTime,
    User? user,
  }) async {
    _setLoading(true);
    
    try {
      // 위치를 UserLocation으로 변환
      final locationService = LocationService();
      final userLocation = await locationService.getLocationFromAddress(location) 
          ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
      
      _recommendations = await _recommendationService.getQuickRecommendations(
        userLocation: userLocation,
        numberOfPeople: 2, // 기본값
      );
      _clearError();
    } catch (e) {
      _setError('시간대별 추천을 불러올 수 없습니다: $e');
      _recommendations = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 인기 추천
  Future<void> getPopularRecommendations({
    required String location,
    User? user,
  }) async {
    _setLoading(true);
    
    try {
      // 위치를 UserLocation으로 변환
      final locationService = LocationService();
      final userLocation = await locationService.getLocationFromAddress(location) 
          ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
      
      _recommendations = await _recommendationService.getPopularRestaurants(
        userLocation: userLocation,
      );
      _clearError();
    } catch (e) {
      _setError('인기 추천을 불러올 수 없습니다: $e');
      _recommendations = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 음식점 검색
  Future<void> searchRestaurants({
    required String query,
    String? location,
    User? user,
  }) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    
    try {
      // 위치를 UserLocation으로 변환
      final locationService = LocationService();
      final userLocation = await locationService.getLocationFromAddress(location ?? '강남역') 
          ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
      
      // 모든 음식점을 가져와서 검색어로 필터링
      final allRecommendations = await _recommendationService.getQuickRecommendations(
        userLocation: userLocation,
        numberOfPeople: 2,
      );
      
      _searchResults = allRecommendations
          .where((restaurant) => 
              restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
              restaurant.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      _clearError();
    } catch (e) {
      _setError('검색에 실패했습니다: $e');
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  /// 추천 결과 필터링
  void filterRecommendations({
    List<String>? categories,
    int? maxPriceLevel,
    double? minRating,
    bool? openNow,
  }) {
    try {
      var filtered = List<Restaurant>.from(_recommendations);

      if (categories != null && categories.isNotEmpty) {
        filtered = filtered.where((restaurant) => 
          categories.contains(restaurant.category)).toList();
      }

      if (maxPriceLevel != null) {
        filtered = filtered.where((restaurant) => 
          restaurant.priceLevel <= maxPriceLevel).toList();
      }

      if (minRating != null) {
        filtered = filtered.where((restaurant) => 
          restaurant.rating >= minRating).toList();
      }

      if (openNow == true) {
        filtered = filtered.where((restaurant) => 
          restaurant.isOpen).toList();
      }

      _recommendations = filtered;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('필터링에 실패했습니다: $e');
    }
  }

  /// 추천 결과 정렬
  void sortRecommendations(String sortBy) {
    try {
      switch (sortBy) {
        case 'rating':
          _recommendations.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'priceLevel':
          _recommendations.sort((a, b) => a.priceLevel.compareTo(b.priceLevel));
          break;
        case 'distance':
          // TODO: 거리 기준 정렬 구현
          break;
        case 'name':
          _recommendations.sort((a, b) => a.name.compareTo(b.name));
          break;
        default:
          // 기본 정렬 (추천 순위 유지)
          break;
      }
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('정렬에 실패했습니다: $e');
    }
  }

  /// 추천 결과 초기화
  void clearRecommendations() {
    _recommendations = [];
    _searchResults = [];
    _lastRequest = null;
    _clearError();
    notifyListeners();
  }

  /// 검색 결과 초기화
  void clearSearchResults() {
    _searchResults = [];
    _clearError();
    notifyListeners();
  }

  /// 즐겨찾기 레스토랑 토글 (나중에 구현할 기능)
  Future<void> toggleFavoriteRestaurant(Restaurant restaurant) async {
    // TODO: 즐겨찾기 기능 구현
    debugPrint('즐겨찾기 토글: ${restaurant.name}');
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

  /// 현재 시간에 따라 식사 시간 결정
  String _getCurrentMealTime() {
    final currentHour = DateTime.now().hour;
    
    if (currentHour >= 6 && currentHour < 10) {
      return 'breakfast';
    } else if (currentHour >= 10 && currentHour < 15) {
      return 'lunch';
    } else if (currentHour >= 15 && currentHour < 18) {
      return 'snack';
    } else {
      return 'dinner';
    }
  }
} 