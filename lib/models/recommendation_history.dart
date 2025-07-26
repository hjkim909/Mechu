import 'restaurant.dart';

/// 추천 이력 모델
class RecommendationHistory {
  final String id;
  final DateTime createdAt;
  final String location;
  final String selectedCategory;
  final int numberOfPeople;
  final List<Restaurant> recommendedRestaurants;
  final String? visitedRestaurantId; // 실제 방문한 음식점 ID
  final String? note;
  final List<String> tags;
  final RecommendationSource source; // 추천 방식 (스와이프/그리드)

  const RecommendationHistory({
    required this.id,
    required this.createdAt,
    required this.location,
    required this.selectedCategory,
    required this.numberOfPeople,
    required this.recommendedRestaurants,
    this.visitedRestaurantId,
    this.note,
    this.tags = const [],
    this.source = RecommendationSource.swipe,
  });

  /// JSON에서 RecommendationHistory 객체 생성
  factory RecommendationHistory.fromJson(Map<String, dynamic> json) {
    return RecommendationHistory(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      location: json['location'] as String,
      selectedCategory: json['selectedCategory'] as String,
      numberOfPeople: json['numberOfPeople'] as int,
      recommendedRestaurants: (json['recommendedRestaurants'] as List<dynamic>)
          .map((restaurantJson) => Restaurant.fromJson(restaurantJson as Map<String, dynamic>))
          .toList(),
      visitedRestaurantId: json['visitedRestaurantId'] as String?,
      note: json['note'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      source: RecommendationSource.values.firstWhere(
        (source) => source.name == (json['source'] as String? ?? 'swipe'),
        orElse: () => RecommendationSource.swipe,
      ),
    );
  }

  /// RecommendationHistory 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'selectedCategory': selectedCategory,
      'numberOfPeople': numberOfPeople,
      'recommendedRestaurants': recommendedRestaurants.map((r) => r.toJson()).toList(),
      'visitedRestaurantId': visitedRestaurantId,
      'note': note,
      'tags': tags,
      'source': source.name,
    };
  }

  /// 추천 이력 복사 (일부 필드 수정)
  RecommendationHistory copyWith({
    String? id,
    DateTime? createdAt,
    String? location,
    String? selectedCategory,
    int? numberOfPeople,
    List<Restaurant>? recommendedRestaurants,
    String? visitedRestaurantId,
    String? note,
    List<String>? tags,
    RecommendationSource? source,
  }) {
    return RecommendationHistory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      recommendedRestaurants: recommendedRestaurants ?? this.recommendedRestaurants,
      visitedRestaurantId: visitedRestaurantId ?? this.visitedRestaurantId,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      source: source ?? this.source,
    );
  }

  /// 방문한 음식점 설정
  RecommendationHistory markAsVisited(String restaurantId, {String? note}) {
    return copyWith(
      visitedRestaurantId: restaurantId,
      note: note ?? this.note,
    );
  }

  /// 노트 추가/수정
  RecommendationHistory updateNote(String newNote) {
    return copyWith(note: newNote);
  }

  /// 태그 추가
  RecommendationHistory addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// 태그 제거
  RecommendationHistory removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// 실제 방문했는지 여부
  bool get wasVisited => visitedRestaurantId != null;

  /// 방문한 음식점 정보
  Restaurant? get visitedRestaurant {
    if (visitedRestaurantId == null) return null;
    try {
      return recommendedRestaurants.firstWhere(
        (restaurant) => restaurant.id == visitedRestaurantId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 추천된 음식점 개수
  int get restaurantCount => recommendedRestaurants.length;

  /// 상위 음식점 (평점 기준)
  Restaurant? get topRatedRestaurant {
    if (recommendedRestaurants.isEmpty) return null;
    return recommendedRestaurants.reduce(
      (current, next) => current.rating > next.rating ? current : next,
    );
  }

  /// 추천 요약 텍스트
  String get summaryText {
    final visitedText = wasVisited ? '(방문함)' : '';
    return '$location에서 $selectedCategory ${restaurantCount}곳 추천 $visitedText';
  }

  /// 날짜 표시 텍스트
  String get dateText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
  }

  /// 시간 표시 텍스트 (시:분 형식)
  String get timeText {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationHistory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RecommendationHistory(id: $id, location: $location, category: $selectedCategory, restaurants: ${restaurantCount}, visited: $wasVisited)';
  }
}

/// 추천 방식
enum RecommendationSource {
  swipe('스와이프'),
  grid('그리드');

  const RecommendationSource(this.displayName);
  final String displayName;
}

/// 추천 이력 필터링 옵션
enum HistoryFilter {
  all,          // 전체
  recent,       // 최근 (7일 이내)
  visited,      // 방문함
  notVisited,   // 방문 안함
  byCategory,   // 카테고리별
  byLocation,   // 위치별
}

/// 추천 이력 정렬 옵션
enum HistorySort {
  dateDesc,     // 최신순
  dateAsc,      // 오래된순
  restaurantCount, // 추천 개수순
  location,     // 위치순
  category,     // 카테고리순
}

/// 추천 이력 통계
class RecommendationHistoryStats {
  final int totalCount;
  final int visitedCount;
  final Map<String, int> categoryCounts;
  final Map<String, int> locationCounts;
  final Map<RecommendationSource, int> sourceCounts;
  final String? mostFrequentCategory;
  final String? mostFrequentLocation;
  final DateTime? firstRecommendation;
  final DateTime? lastRecommendation;
  final double visitRatio; // 방문율 (0.0 ~ 1.0)

  const RecommendationHistoryStats({
    required this.totalCount,
    required this.visitedCount,
    required this.categoryCounts,
    required this.locationCounts,
    required this.sourceCounts,
    this.mostFrequentCategory,
    this.mostFrequentLocation,
    this.firstRecommendation,
    this.lastRecommendation,
    required this.visitRatio,
  });

  factory RecommendationHistoryStats.fromHistories(List<RecommendationHistory> histories) {
    if (histories.isEmpty) {
      return const RecommendationHistoryStats(
        totalCount: 0,
        visitedCount: 0,
        categoryCounts: {},
        locationCounts: {},
        sourceCounts: {},
        visitRatio: 0.0,
      );
    }

    // 방문한 추천 개수
    final visitedCount = histories.where((h) => h.wasVisited).length;

    // 카테고리별 개수
    final categoryCounts = <String, int>{};
    for (final history in histories) {
      categoryCounts[history.selectedCategory] = 
          (categoryCounts[history.selectedCategory] ?? 0) + 1;
    }

    // 위치별 개수
    final locationCounts = <String, int>{};
    for (final history in histories) {
      locationCounts[history.location] = 
          (locationCounts[history.location] ?? 0) + 1;
    }

    // 추천 방식별 개수
    final sourceCounts = <RecommendationSource, int>{};
    for (final history in histories) {
      sourceCounts[history.source] = 
          (sourceCounts[history.source] ?? 0) + 1;
    }

    // 가장 빈번한 카테고리
    String? mostFrequentCategory;
    if (categoryCounts.isNotEmpty) {
      mostFrequentCategory = categoryCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    // 가장 빈번한 위치
    String? mostFrequentLocation;
    if (locationCounts.isNotEmpty) {
      mostFrequentLocation = locationCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    // 날짜 통계
    final sortedByDate = [...histories];
    sortedByDate.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final firstRecommendation = sortedByDate.first.createdAt;
    final lastRecommendation = sortedByDate.last.createdAt;

    // 방문율
    final visitRatio = histories.isEmpty ? 0.0 : visitedCount / histories.length;

    return RecommendationHistoryStats(
      totalCount: histories.length,
      visitedCount: visitedCount,
      categoryCounts: categoryCounts,
      locationCounts: locationCounts,
      sourceCounts: sourceCounts,
      mostFrequentCategory: mostFrequentCategory,
      mostFrequentLocation: mostFrequentLocation,
      firstRecommendation: firstRecommendation,
      lastRecommendation: lastRecommendation,
      visitRatio: visitRatio,
    );
  }

  /// 방문율 퍼센트 텍스트
  String get visitRatioPercentText {
    return '${(visitRatio * 100).round()}%';
  }
} 