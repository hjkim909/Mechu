import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 즐겨찾기 상태 관리
class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  
  List<Favorite> _favorites = [];
  List<Favorite> _filteredFavorites = [];
  bool _isLoading = false;
  String? _error;
  
  // 필터 및 정렬 상태
  FavoriteFilter _currentFilter = FavoriteFilter.all;
  FavoriteSort _currentSort = FavoriteSort.dateAdded;
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minRating;

  // Getters - 메모리 최적화
  List<Favorite> get favorites => _favorites; // 읽기 전용으로 사용하므로 복사 불필요
  List<Favorite> get filteredFavorites => _filteredFavorites; // 읽기 전용으로 사용하므로 복사 불필요
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFavorites => _favorites.isNotEmpty;
  int get favoriteCount => _favorites.length;
  
  FavoriteFilter get currentFilter => _currentFilter;
  FavoriteSort get currentSort => _currentSort;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double? get minRating => _minRating;

  /// 즐겨찾기 초기화
  Future<void> initializeFavorites() async {
    _setLoading(true);
    try {
      _favorites = await _favoriteService.getFavorites();
      _applyFiltersAndSort();
      _clearError();
    } catch (e) {
      _setError('즐겨찾기를 불러올 수 없습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 즐겨찾기 새로고침
  Future<void> refreshFavorites() async {
    await initializeFavorites();
  }

  /// 즐겨찾기 추가
  Future<bool> addFavorite(
    Restaurant restaurant, {
    String? note,
    List<String>? tags,
  }) async {
    try {
      final success = await _favoriteService.addFavorite(
        restaurant,
        note: note,
        tags: tags,
      );
      
      if (success) {
        await refreshFavorites();
        return true;
      } else {
        _setError('이미 즐겨찾기에 추가된 음식점입니다');
        return false;
      }
    } catch (e) {
      _setError('즐겨찾기 추가에 실패했습니다: $e');
      return false;
    }
  }

  /// 즐겨찾기 제거
  Future<bool> removeFavorite(String restaurantId) async {
    try {
      final success = await _favoriteService.removeFavorite(restaurantId);
      
      if (success) {
        await refreshFavorites();
        return true;
      } else {
        _setError('즐겨찾기 제거에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('즐겨찾기 제거에 실패했습니다: $e');
      return false;
    }
  }

  /// 즐겨찾기 토글
  Future<bool> toggleFavorite(
    Restaurant restaurant, {
    String? note,
    List<String>? tags,
  }) async {
    try {
      final success = await _favoriteService.toggleFavorite(
        restaurant,
        note: note,
        tags: tags,
      );
      
      if (success) {
        await refreshFavorites();
        return true;
      } else {
        _setError('즐겨찾기 변경에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('즐겨찾기 변경에 실패했습니다: $e');
      return false;
    }
  }

  /// 음식점이 즐겨찾기에 있는지 확인
  bool isFavorite(String restaurantId) {
    return _favorites.any((f) => f.restaurant.id == restaurantId);
  }

  /// 즐겨찾기 업데이트
  Future<bool> updateFavorite(
    String restaurantId, {
    String? note,
    List<String>? tags,
  }) async {
    try {
      final success = await _favoriteService.updateFavorite(
        restaurantId,
        note: note,
        tags: tags,
      );
      
      if (success) {
        await refreshFavorites();
        return true;
      } else {
        _setError('즐겨찾기 업데이트에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('즐겨찾기 업데이트에 실패했습니다: $e');
      return false;
    }
  }

  /// 방문 횟수 증가
  Future<bool> incrementVisitCount(String restaurantId) async {
    try {
      final success = await _favoriteService.incrementVisitCount(restaurantId);
      
      if (success) {
        // UI에서 즉시 반영하기 위해 로컬에서도 업데이트
        final index = _favorites.indexWhere((f) => f.restaurant.id == restaurantId);
        if (index != -1) {
          _favorites[index] = _favorites[index].incrementVisitCount();
          _applyFiltersAndSort();
          notifyListeners();
        }
        return true;
      } else {
        _setError('방문 횟수 업데이트에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('방문 횟수 업데이트에 실패했습니다: $e');
      return false;
    }
  }

  /// 필터 변경
  void setFilter(FavoriteFilter filter, {String? category, double? minRating}) {
    _currentFilter = filter;
    _selectedCategory = category;
    _minRating = minRating;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 정렬 변경
  void setSort(FavoriteSort sort) {
    _currentSort = sort;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 검색어 변경
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 필터 및 정렬 적용
  void _applyFiltersAndSort() {
    var filtered = _favoriteService.filterFavorites(
      _favorites,
      _currentFilter,
      category: _selectedCategory,
      minRating: _minRating,
    );

    if (_searchQuery.isNotEmpty) {
      filtered = _favoriteService.searchFavorites(filtered, _searchQuery);
    }

    _filteredFavorites = _favoriteService.sortFavorites(filtered, _currentSort);
  }

  /// 즐겨찾기 통계 가져오기
  Future<FavoriteStats> getFavoriteStats() async {
    try {
      return await _favoriteService.getFavoriteStats();
    } catch (e) {
      _setError('통계를 불러올 수 없습니다: $e');
      return const FavoriteStats(
        totalCount: 0,
        visitedCount: 0,
        categoryCounts: {},
      );
    }
  }

  /// 카테고리별 즐겨찾기 개수
  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (final favorite in _favorites) {
      final category = favorite.restaurant.category;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// 최근 추가된 즐겨찾기 (최대 5개)
  List<Favorite> getRecentFavorites() {
    final recent = [..._favorites];
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(5).toList();
  }

  /// 자주 방문한 즐겨찾기 (최대 5개)
  List<Favorite> getMostVisited() {
    final visited = _favorites.where((f) => f.visitCount > 0).toList();
    visited.sort((a, b) => b.visitCount.compareTo(a.visitCount));
    return visited.take(5).toList();
  }

  /// 추천 태그 목록
  List<String> getRecommendedTags() {
    return _favoriteService.getRecommendedTags();
  }

  /// 즐겨찾기 백업
  Future<String?> exportFavorites() async {
    try {
      return await _favoriteService.exportFavorites();
    } catch (e) {
      _setError('백업에 실패했습니다: $e');
      return null;
    }
  }

  /// 즐겨찾기 복원
  Future<bool> importFavorites(String jsonString) async {
    try {
      final success = await _favoriteService.importFavorites(jsonString);
      if (success) {
        await refreshFavorites();
        return true;
      } else {
        _setError('복원에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('복원에 실패했습니다: $e');
      return false;
    }
  }

  /// 즐겨찾기 전체 삭제
  Future<bool> clearAllFavorites() async {
    try {
      final success = await _favoriteService.clearAllFavorites();
      if (success) {
        _favorites.clear();
        _filteredFavorites.clear();
        notifyListeners();
        return true;
      } else {
        _setError('삭제에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('삭제에 실패했습니다: $e');
      return false;
    }
  }

  /// 특정 ID로 즐겨찾기 찾기
  Favorite? getFavoriteById(String favoriteId) {
    try {
      return _favorites.firstWhere((f) => f.id == favoriteId);
    } catch (e) {
      return null;
    }
  }

  /// 특정 음식점의 즐겨찾기 찾기
  Favorite? getFavoriteByRestaurantId(String restaurantId) {
    try {
      return _favorites.firstWhere((f) => f.restaurant.id == restaurantId);
    } catch (e) {
      return null;
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