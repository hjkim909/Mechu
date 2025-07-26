import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// 추천 이력 관리 서비스
class RecommendationHistoryService {
  static final RecommendationHistoryService _instance = RecommendationHistoryService._internal();
  factory RecommendationHistoryService() => _instance;
  RecommendationHistoryService._internal();

  static const String _historyKey = 'recommendation_history';
  static const String _historyStatsKey = 'recommendation_history_stats';
  static const int _maxHistoryCount = 100; // 최대 저장 개수

  /// 모든 추천 이력 가져오기
  Future<List<RecommendationHistory>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null) return [];

      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map((json) => RecommendationHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('추천 이력 불러오기 실패: $e');
      return [];
    }
  }

  /// 추천 이력 저장
  Future<bool> saveHistory(List<RecommendationHistory> histories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 최대 개수 제한
      final limitedHistories = histories.length > _maxHistoryCount
          ? histories.take(_maxHistoryCount).toList()
          : histories;
      
      final historyJson = json.encode(
        limitedHistories.map((history) => history.toJson()).toList(),
      );
      
      return await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('추천 이력 저장 실패: $e');
      return false;
    }
  }

  /// 새로운 추천 이력 추가
  Future<bool> addHistory(RecommendationHistory history) async {
    try {
      final histories = await getHistory();
      
      // 중복 확인 (같은 시간대, 같은 위치, 같은 카테고리)
      final exists = histories.any((existing) =>
          existing.location == history.location &&
          existing.selectedCategory == history.selectedCategory &&
          existing.createdAt.difference(history.createdAt).abs().inMinutes < 5
      );
      
      if (exists) {
        print('중복된 추천 이력: ${history.summaryText}');
        return false;
      }

      // 최신 순으로 추가
      histories.insert(0, history);
      
      // 최대 개수 초과 시 오래된 것 제거
      if (histories.length > _maxHistoryCount) {
        histories.removeRange(_maxHistoryCount, histories.length);
      }
      
      return await saveHistory(histories);
    } catch (e) {
      print('추천 이력 추가 실패: $e');
      return false;
    }
  }

  /// 추천 이력 업데이트
  Future<bool> updateHistory(String historyId, RecommendationHistory updatedHistory) async {
    try {
      final histories = await getHistory();
      final index = histories.indexWhere((h) => h.id == historyId);
      
      if (index == -1) return false;

      histories[index] = updatedHistory;
      return await saveHistory(histories);
    } catch (e) {
      print('추천 이력 업데이트 실패: $e');
      return false;
    }
  }

  /// 추천 이력 삭제
  Future<bool> removeHistory(String historyId) async {
    try {
      final histories = await getHistory();
      histories.removeWhere((h) => h.id == historyId);
      return await saveHistory(histories);
    } catch (e) {
      print('추천 이력 삭제 실패: $e');
      return false;
    }
  }

  /// 방문 표시
  Future<bool> markAsVisited(String historyId, String restaurantId, {String? note}) async {
    try {
      final histories = await getHistory();
      final index = histories.indexWhere((h) => h.id == historyId);
      
      if (index == -1) return false;

      histories[index] = histories[index].markAsVisited(restaurantId, note: note);
      return await saveHistory(histories);
    } catch (e) {
      print('방문 표시 실패: $e');
      return false;
    }
  }

  /// 노트 추가/수정
  Future<bool> updateNote(String historyId, String note) async {
    try {
      final histories = await getHistory();
      final index = histories.indexWhere((h) => h.id == historyId);
      
      if (index == -1) return false;

      histories[index] = histories[index].updateNote(note);
      return await saveHistory(histories);
    } catch (e) {
      print('노트 업데이트 실패: $e');
      return false;
    }
  }

  /// 태그 추가
  Future<bool> addTag(String historyId, String tag) async {
    try {
      final histories = await getHistory();
      final index = histories.indexWhere((h) => h.id == historyId);
      
      if (index == -1) return false;

      histories[index] = histories[index].addTag(tag);
      return await saveHistory(histories);
    } catch (e) {
      print('태그 추가 실패: $e');
      return false;
    }
  }

  /// 태그 제거
  Future<bool> removeTag(String historyId, String tag) async {
    try {
      final histories = await getHistory();
      final index = histories.indexWhere((h) => h.id == historyId);
      
      if (index == -1) return false;

      histories[index] = histories[index].removeTag(tag);
      return await saveHistory(histories);
    } catch (e) {
      print('태그 제거 실패: $e');
      return false;
    }
  }

  /// 추천 이력 필터링
  List<RecommendationHistory> filterHistory(
    List<RecommendationHistory> histories,
    HistoryFilter filter, {
    String? category,
    String? location,
  }) {
    switch (filter) {
      case HistoryFilter.all:
        return histories;
      
      case HistoryFilter.recent:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        return histories.where((h) => h.createdAt.isAfter(sevenDaysAgo)).toList();
      
      case HistoryFilter.visited:
        return histories.where((h) => h.wasVisited).toList();
      
      case HistoryFilter.notVisited:
        return histories.where((h) => !h.wasVisited).toList();
      
      case HistoryFilter.byCategory:
        if (category == null) return histories;
        return histories.where((h) => h.selectedCategory == category).toList();
      
      case HistoryFilter.byLocation:
        if (location == null) return histories;
        return histories.where((h) => h.location == location).toList();
    }
  }

  /// 추천 이력 정렬
  List<RecommendationHistory> sortHistory(List<RecommendationHistory> histories, HistorySort sort) {
    final sortedHistories = [...histories];
    
    switch (sort) {
      case HistorySort.dateDesc:
        sortedHistories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      
      case HistorySort.dateAsc:
        sortedHistories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      
      case HistorySort.restaurantCount:
        sortedHistories.sort((a, b) => b.restaurantCount.compareTo(a.restaurantCount));
        break;
      
      case HistorySort.location:
        sortedHistories.sort((a, b) => a.location.compareTo(b.location));
        break;
      
      case HistorySort.category:
        sortedHistories.sort((a, b) => a.selectedCategory.compareTo(b.selectedCategory));
        break;
    }
    
    return sortedHistories;
  }

  /// 추천 이력 검색
  List<RecommendationHistory> searchHistory(List<RecommendationHistory> histories, String query) {
    if (query.isEmpty) return histories;
    
    final lowercaseQuery = query.toLowerCase();
    return histories.where((history) {
      return history.location.toLowerCase().contains(lowercaseQuery) ||
             history.selectedCategory.toLowerCase().contains(lowercaseQuery) ||
             (history.note?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             history.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
             history.recommendedRestaurants.any((restaurant) =>
                 restaurant.name.toLowerCase().contains(lowercaseQuery)
             );
    }).toList();
  }

  /// 추천 이력 통계 생성
  Future<RecommendationHistoryStats> getHistoryStats() async {
    try {
      final histories = await getHistory();
      return RecommendationHistoryStats.fromHistories(histories);
    } catch (e) {
      print('추천 이력 통계 생성 실패: $e');
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

  /// 특정 기간의 추천 이력
  Future<List<RecommendationHistory>> getHistoryByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final histories = await getHistory();
      return histories.where((history) =>
          history.createdAt.isAfter(startDate) &&
          history.createdAt.isBefore(endDate)
      ).toList();
    } catch (e) {
      print('기간별 추천 이력 조회 실패: $e');
      return [];
    }
  }

  /// 최근 추천 이력 (최대 N개)
  Future<List<RecommendationHistory>> getRecentHistory([int limit = 10]) async {
    try {
      final histories = await getHistory();
      final sorted = histories..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted.take(limit).toList();
    } catch (e) {
      print('최근 추천 이력 조회 실패: $e');
      return [];
    }
  }

  /// 특정 카테고리의 추천 이력
  Future<List<RecommendationHistory>> getHistoryByCategory(String category) async {
    try {
      final histories = await getHistory();
      return histories.where((h) => h.selectedCategory == category).toList();
    } catch (e) {
      print('카테고리별 추천 이력 조회 실패: $e');
      return [];
    }
  }

  /// 특정 위치의 추천 이력
  Future<List<RecommendationHistory>> getHistoryByLocation(String location) async {
    try {
      final histories = await getHistory();
      return histories.where((h) => h.location == location).toList();
    } catch (e) {
      print('위치별 추천 이력 조회 실패: $e');
      return [];
    }
  }

  /// 방문한 추천 이력만
  Future<List<RecommendationHistory>> getVisitedHistory() async {
    try {
      final histories = await getHistory();
      return histories.where((h) => h.wasVisited).toList();
    } catch (e) {
      print('방문한 추천 이력 조회 실패: $e');
      return [];
    }
  }

  /// 추천 이력 백업 (JSON 문자열 반환)
  Future<String?> exportHistory() async {
    try {
      final histories = await getHistory();
      return json.encode(histories.map((h) => h.toJson()).toList());
    } catch (e) {
      print('추천 이력 백업 실패: $e');
      return null;
    }
  }

  /// 추천 이력 복원 (JSON 문자열에서)
  Future<bool> importHistory(String jsonString, {bool replace = false}) async {
    try {
      final List<dynamic> historyList = json.decode(jsonString);
      final importedHistories = historyList
          .map((json) => RecommendationHistory.fromJson(json as Map<String, dynamic>))
          .toList();
      
      if (replace) {
        return await saveHistory(importedHistories);
      } else {
        final existingHistories = await getHistory();
        final allHistories = [...existingHistories, ...importedHistories];
        
        // 중복 제거 (ID 기준)
        final uniqueHistories = <String, RecommendationHistory>{};
        for (final history in allHistories) {
          uniqueHistories[history.id] = history;
        }
        
        final finalHistories = uniqueHistories.values.toList();
        finalHistories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return await saveHistory(finalHistories);
      }
    } catch (e) {
      print('추천 이력 복원 실패: $e');
      return false;
    }
  }

  /// 추천 이력 전체 삭제
  Future<bool> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      print('추천 이력 전체 삭제 실패: $e');
      return false;
    }
  }

  /// 오래된 이력 자동 정리 (N일 이전 삭제)
  Future<bool> cleanupOldHistory([int daysToKeep = 365]) async {
    try {
      final histories = await getHistory();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final filteredHistories = histories
          .where((h) => h.createdAt.isAfter(cutoffDate))
          .toList();
      
      if (filteredHistories.length != histories.length) {
        return await saveHistory(filteredHistories);
      }
      
      return true; // 삭제할 항목이 없음
    } catch (e) {
      print('오래된 이력 정리 실패: $e');
      return false;
    }
  }

  /// 추천 ID 생성 (현재 시간 기반)
  String generateHistoryId() {
    return 'history_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 추천 태그 목록 (자주 사용되는 태그들)
  List<String> getRecommendedTags() {
    return [
      '만족',
      '괜찮음',
      '별로',
      '재방문 예정',
      '혼자',
      '친구',
      '가족',
      '연인',
      '회식',
      '점심',
      '저녁',
      '주말',
      '특별한 날',
      '급하게',
    ];
  }
} 