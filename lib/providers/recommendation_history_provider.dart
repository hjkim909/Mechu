import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 추천 이력 상태 관리
class RecommendationHistoryProvider with ChangeNotifier {
  final RecommendationHistoryService _historyService = RecommendationHistoryService();
  
  List<RecommendationHistory> _histories = [];
  List<RecommendationHistory> _filteredHistories = [];
  bool _isLoading = false;
  String? _error;
  
  // 필터 및 정렬 상태
  HistoryFilter _currentFilter = HistoryFilter.all;
  HistorySort _currentSort = HistorySort.dateDesc;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLocation;

  // Getters
  List<RecommendationHistory> get histories => List.unmodifiable(_histories);
  List<RecommendationHistory> get filteredHistories => List.unmodifiable(_filteredHistories);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasHistories => _histories.isNotEmpty;
  int get historyCount => _histories.length;
  
  HistoryFilter get currentFilter => _currentFilter;
  HistorySort get currentSort => _currentSort;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;

  /// 추천 이력 초기화
  Future<void> initializeHistory() async {
    _setLoading(true);
    try {
      _histories = await _historyService.getHistory();
      _applyFiltersAndSort();
      _clearError();
    } catch (e) {
      _setError('추천 이력을 불러올 수 없습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 추천 이력 새로고침
  Future<void> refreshHistory() async {
    await initializeHistory();
  }

  /// 새로운 추천 이력 추가
  Future<bool> addHistory(RecommendationHistory history) async {
    try {
      final success = await _historyService.addHistory(history);
      
      if (success) {
        await refreshHistory();
        return true;
      } else {
        _setError('중복된 추천 이력입니다');
        return false;
      }
    } catch (e) {
      _setError('추천 이력 추가에 실패했습니다: $e');
      return false;
    }
  }

  /// 추천 이력 삭제
  Future<bool> removeHistory(String historyId) async {
    try {
      final success = await _historyService.removeHistory(historyId);
      
      if (success) {
        await refreshHistory();
        return true;
      } else {
        _setError('추천 이력 삭제에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('추천 이력 삭제에 실패했습니다: $e');
      return false;
    }
  }

  /// 방문 표시
  Future<bool> markAsVisited(String historyId, String restaurantId, {String? note}) async {
    try {
      final success = await _historyService.markAsVisited(historyId, restaurantId, note: note);
      
      if (success) {
        // UI에서 즉시 반영하기 위해 로컬에서도 업데이트
        final index = _histories.indexWhere((h) => h.id == historyId);
        if (index != -1) {
          _histories[index] = _histories[index].markAsVisited(restaurantId, note: note);
          _applyFiltersAndSort();
          notifyListeners();
        }
        return true;
      } else {
        _setError('방문 표시에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('방문 표시에 실패했습니다: $e');
      return false;
    }
  }

  /// 노트 업데이트
  Future<bool> updateNote(String historyId, String note) async {
    try {
      final success = await _historyService.updateNote(historyId, note);
      
      if (success) {
        await refreshHistory();
        return true;
      } else {
        _setError('노트 업데이트에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('노트 업데이트에 실패했습니다: $e');
      return false;
    }
  }

  /// 태그 추가
  Future<bool> addTag(String historyId, String tag) async {
    try {
      final success = await _historyService.addTag(historyId, tag);
      
      if (success) {
        await refreshHistory();
        return true;
      } else {
        _setError('태그 추가에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('태그 추가에 실패했습니다: $e');
      return false;
    }
  }

  /// 태그 제거
  Future<bool> removeTag(String historyId, String tag) async {
    try {
      final success = await _historyService.removeTag(historyId, tag);
      
      if (success) {
        await refreshHistory();
        return true;
      } else {
        _setError('태그 제거에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('태그 제거에 실패했습니다: $e');
      return false;
    }
  }

  /// 필터 변경
  void setFilter(HistoryFilter filter, {String? category, String? location}) {
    _currentFilter = filter;
    _selectedCategory = category;
    _selectedLocation = location;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 정렬 변경
  void setSort(HistorySort sort) {
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
    var filtered = _historyService.filterHistory(
      _histories,
      _currentFilter,
      category: _selectedCategory,
      location: _selectedLocation,
    );

    if (_searchQuery.isNotEmpty) {
      filtered = _historyService.searchHistory(filtered, _searchQuery);
    }

    _filteredHistories = _historyService.sortHistory(filtered, _currentSort);
  }

  /// 추천 이력 통계 가져오기
  Future<RecommendationHistoryStats> getHistoryStats() async {
    try {
      return await _historyService.getHistoryStats();
    } catch (e) {
      _setError('통계를 불러올 수 없습니다: $e');
      return const RecommendationHistoryStats(
        totalCount: 0,
        visitedCount: 0,
        categoryCounts: {},
        locationCounts: {},
        sourceCounts: {},
        visitRatio: 0.0,
      );
    }
  }

  /// 카테고리별 추천 이력 개수
  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (final history in _histories) {
      final category = history.selectedCategory;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// 위치별 추천 이력 개수
  Map<String, int> getLocationCounts() {
    final counts = <String, int>{};
    for (final history in _histories) {
      final location = history.location;
      counts[location] = (counts[location] ?? 0) + 1;
    }
    return counts;
  }

  /// 최근 추천 이력 (최대 5개)
  List<RecommendationHistory> getRecentHistories() {
    final recent = [..._histories];
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(5).toList();
  }

  /// 방문한 추천 이력 (최대 5개)
  List<RecommendationHistory> getVisitedHistories() {
    final visited = _histories.where((h) => h.wasVisited).toList();
    visited.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return visited.take(5).toList();
  }

  /// 특정 카테고리의 추천 이력
  List<RecommendationHistory> getHistoriesByCategory(String category) {
    return _histories.where((h) => h.selectedCategory == category).toList();
  }

  /// 특정 위치의 추천 이력
  List<RecommendationHistory> getHistoriesByLocation(String location) {
    return _histories.where((h) => h.location == location).toList();
  }

  /// 추천 태그 목록
  List<String> getRecommendedTags() {
    return _historyService.getRecommendedTags();
  }

  /// 추천 이력 백업
  Future<String?> exportHistory() async {
    try {
      return await _historyService.exportHistory();
    } catch (e) {
      _setError('백업에 실패했습니다: $e');
      return null;
    }
  }

  /// 추천 이력 복원
  Future<bool> importHistory(String jsonString, {bool replace = false}) async {
    try {
      final success = await _historyService.importHistory(jsonString, replace: replace);
      if (success) {
        await refreshHistory();
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

  /// 추천 이력 전체 삭제
  Future<bool> clearAllHistory() async {
    try {
      final success = await _historyService.clearAllHistory();
      if (success) {
        _histories.clear();
        _filteredHistories.clear();
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

  /// 오래된 이력 정리
  Future<bool> cleanupOldHistory([int daysToKeep = 365]) async {
    try {
      final success = await _historyService.cleanupOldHistory(daysToKeep);
      if (success) {
        await refreshHistory();
        return true;
      } else {
        _setError('정리에 실패했습니다');
        return false;
      }
    } catch (e) {
      _setError('정리에 실패했습니다: $e');
      return false;
    }
  }

  /// 특정 ID로 추천 이력 찾기
  RecommendationHistory? getHistoryById(String historyId) {
    try {
      return _histories.firstWhere((h) => h.id == historyId);
    } catch (e) {
      return null;
    }
  }

  /// 중복 추천 이력 확인
  bool isDuplicateRecommendation({
    required String location,
    required String category,
    required DateTime createdAt,
  }) {
    return _histories.any((existing) =>
        existing.location == location &&
        existing.selectedCategory == category &&
        existing.createdAt.difference(createdAt).abs().inMinutes < 5
    );
  }

  /// 추천 이력 ID 생성
  String generateHistoryId() {
    return _historyService.generateHistoryId();
  }

  /// 추천에서 이력 자동 생성
  RecommendationHistory createHistoryFromRecommendation({
    required String location,
    required String selectedCategory,
    required int numberOfPeople,
    required List<Restaurant> restaurants,
    RecommendationSource source = RecommendationSource.swipe,
  }) {
    return RecommendationHistory(
      id: generateHistoryId(),
      createdAt: DateTime.now(),
      location: location,
      selectedCategory: selectedCategory,
      numberOfPeople: numberOfPeople,
      recommendedRestaurants: restaurants,
      source: source,
    );
  }

  /// 방문율 계산
  double get visitRatio {
    if (_histories.isEmpty) return 0.0;
    final visitedCount = _histories.where((h) => h.wasVisited).length;
    return visitedCount / _histories.length;
  }

  /// 방문율 퍼센트 텍스트
  String get visitRatioPercentText {
    return '${(visitRatio * 100).round()}%';
  }

  /// 가장 자주 방문한 카테고리
  String? get mostFrequentCategory {
    if (_histories.isEmpty) return null;
    final categoryCounts = getCategoryCounts();
    if (categoryCounts.isEmpty) return null;
    
    return categoryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 자주 방문한 위치
  String? get mostFrequentLocation {
    if (_histories.isEmpty) return null;
    final locationCounts = getLocationCounts();
    if (locationCounts.isEmpty) return null;
    
    return locationCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
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