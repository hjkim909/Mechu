import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// 즐겨찾기 관리 서비스
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  static const String _favoritesKey = 'user_favorites';
  static const String _favoriteStatsKey = 'favorite_stats';

  /// 모든 즐겨찾기 가져오기
  Future<List<Favorite>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList
          .map((json) => Favorite.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('즐겨찾기 불러오기 실패: $e');
      return [];
    }
  }

  /// 즐겨찾기 저장
  Future<bool> saveFavorites(List<Favorite> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        favorites.map((favorite) => favorite.toJson()).toList(),
      );
      
      return await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('즐겨찾기 저장 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 추가
  Future<bool> addFavorite(Restaurant restaurant, {String? note, List<String>? tags}) async {
    try {
      final favorites = await getFavorites();
      
      // 이미 즐겨찾기에 있는지 확인
      if (favorites.any((f) => f.restaurant.id == restaurant.id)) {
        return false; // 이미 존재함
      }

      final newFavorite = Favorite(
        id: '${restaurant.id}_${DateTime.now().millisecondsSinceEpoch}',
        restaurant: restaurant,
        createdAt: DateTime.now(),
        note: note,
        tags: tags ?? [],
      );

      favorites.add(newFavorite);
      return await saveFavorites(favorites);
    } catch (e) {
      print('즐겨찾기 추가 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 제거
  Future<bool> removeFavorite(String restaurantId) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((f) => f.restaurant.id == restaurantId);
      return await saveFavorites(favorites);
    } catch (e) {
      print('즐겨찾기 제거 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 토글 (있으면 제거, 없으면 추가)
  Future<bool> toggleFavorite(Restaurant restaurant, {String? note, List<String>? tags}) async {
    try {
      final favorites = await getFavorites();
      final existingIndex = favorites.indexWhere((f) => f.restaurant.id == restaurant.id);
      
      if (existingIndex != -1) {
        // 제거
        favorites.removeAt(existingIndex);
      } else {
        // 추가
        final newFavorite = Favorite(
          id: '${restaurant.id}_${DateTime.now().millisecondsSinceEpoch}',
          restaurant: restaurant,
          createdAt: DateTime.now(),
          note: note,
          tags: tags ?? [],
        );
        favorites.add(newFavorite);
      }

      return await saveFavorites(favorites);
    } catch (e) {
      print('즐겨찾기 토글 실패: $e');
      return false;
    }
  }

  /// 음식점이 즐겨찾기에 있는지 확인
  Future<bool> isFavorite(String restaurantId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((f) => f.restaurant.id == restaurantId);
    } catch (e) {
      print('즐겨찾기 확인 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 업데이트 (노트, 태그 등)
  Future<bool> updateFavorite(String restaurantId, {String? note, List<String>? tags}) async {
    try {
      final favorites = await getFavorites();
      final index = favorites.indexWhere((f) => f.restaurant.id == restaurantId);
      
      if (index == -1) return false;

      favorites[index] = favorites[index].copyWith(
        note: note,
        tags: tags,
      );

      return await saveFavorites(favorites);
    } catch (e) {
      print('즐겨찾기 업데이트 실패: $e');
      return false;
    }
  }

  /// 방문 횟수 증가
  Future<bool> incrementVisitCount(String restaurantId) async {
    try {
      final favorites = await getFavorites();
      final index = favorites.indexWhere((f) => f.restaurant.id == restaurantId);
      
      if (index == -1) return false;

      favorites[index] = favorites[index].incrementVisitCount();
      return await saveFavorites(favorites);
    } catch (e) {
      print('방문 횟수 증가 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 필터링
  List<Favorite> filterFavorites(
    List<Favorite> favorites,
    FavoriteFilter filter, {
    String? category,
    double? minRating,
  }) {
    switch (filter) {
      case FavoriteFilter.all:
        return favorites;
      
      case FavoriteFilter.recent:
        final recentFavorites = [...favorites];
        recentFavorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return recentFavorites.take(10).toList(); // 최근 10개
      
      case FavoriteFilter.mostVisited:
        final visitedFavorites = favorites.where((f) => f.visitCount > 0).toList();
        visitedFavorites.sort((a, b) => b.visitCount.compareTo(a.visitCount));
        return visitedFavorites;
      
      case FavoriteFilter.byCategory:
        if (category == null) return favorites;
        return favorites.where((f) => f.restaurant.category == category).toList();
      
      case FavoriteFilter.byRating:
        if (minRating == null) return favorites;
        return favorites.where((f) => f.restaurant.rating >= minRating).toList();
    }
  }

  /// 즐겨찾기 정렬
  List<Favorite> sortFavorites(List<Favorite> favorites, FavoriteSort sort) {
    final sortedFavorites = [...favorites];
    
    switch (sort) {
      case FavoriteSort.dateAdded:
        sortedFavorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      
      case FavoriteSort.lastVisited:
        sortedFavorites.sort((a, b) {
          if (a.lastVisitedAt == null && b.lastVisitedAt == null) return 0;
          if (a.lastVisitedAt == null) return 1;
          if (b.lastVisitedAt == null) return -1;
          return b.lastVisitedAt!.compareTo(a.lastVisitedAt!);
        });
        break;
      
      case FavoriteSort.visitCount:
        sortedFavorites.sort((a, b) => b.visitCount.compareTo(a.visitCount));
        break;
      
      case FavoriteSort.rating:
        sortedFavorites.sort((a, b) => b.restaurant.rating.compareTo(a.restaurant.rating));
        break;
      
      case FavoriteSort.name:
        sortedFavorites.sort((a, b) => a.restaurant.name.compareTo(b.restaurant.name));
        break;
      
      case FavoriteSort.distance:
        // 거리순 정렬은 현재 위치가 필요하므로 추후 구현
        break;
    }
    
    return sortedFavorites;
  }

  /// 즐겨찾기 검색
  List<Favorite> searchFavorites(List<Favorite> favorites, String query) {
    if (query.isEmpty) return favorites;
    
    final lowercaseQuery = query.toLowerCase();
    return favorites.where((favorite) {
      final restaurant = favorite.restaurant;
      return restaurant.name.toLowerCase().contains(lowercaseQuery) ||
             restaurant.category.toLowerCase().contains(lowercaseQuery) ||
             restaurant.address.toLowerCase().contains(lowercaseQuery) ||
             (favorite.note?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             favorite.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// 즐겨찾기 통계 생성
  Future<FavoriteStats> getFavoriteStats() async {
    try {
      final favorites = await getFavorites();
      return FavoriteStats.fromFavorites(favorites);
    } catch (e) {
      print('즐겨찾기 통계 생성 실패: $e');
      return const FavoriteStats(
        totalCount: 0,
        visitedCount: 0,
        categoryCounts: {},
      );
    }
  }

  /// 즐겨찾기 백업 (JSON 문자열 반환)
  Future<String?> exportFavorites() async {
    try {
      final favorites = await getFavorites();
      return json.encode(favorites.map((f) => f.toJson()).toList());
    } catch (e) {
      print('즐겨찾기 백업 실패: $e');
      return null;
    }
  }

  /// 즐겨찾기 복원 (JSON 문자열에서)
  Future<bool> importFavorites(String jsonString) async {
    try {
      final List<dynamic> favoritesList = json.decode(jsonString);
      final favorites = favoritesList
          .map((json) => Favorite.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return await saveFavorites(favorites);
    } catch (e) {
      print('즐겨찾기 복원 실패: $e');
      return false;
    }
  }

  /// 즐겨찾기 초기화
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_favoritesKey);
    } catch (e) {
      print('즐겨찾기 초기화 실패: $e');
      return false;
    }
  }

  /// 추천 태그 목록 (자주 사용되는 태그들)
  List<String> getRecommendedTags() {
    return [
      '맛있어요',
      '친절해요',
      '깔끔해요',
      '가성비',
      '데이트',
      '가족식사',
      '회식',
      '혼밥',
      '배달',
      '포장',
      '주차가능',
      '24시간',
      '분위기좋음',
      '양많음',
    ];
  }
} 