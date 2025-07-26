import 'restaurant.dart';

/// 즐겨찾기 음식점 모델
class Favorite {
  final String id;
  final Restaurant restaurant;
  final DateTime createdAt;
  final String? note;
  final List<String> tags;
  final int visitCount;
  final DateTime? lastVisitedAt;

  const Favorite({
    required this.id,
    required this.restaurant,
    required this.createdAt,
    this.note,
    this.tags = const [],
    this.visitCount = 0,
    this.lastVisitedAt,
  });

  /// JSON에서 Favorite 객체 생성
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      restaurant: Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      visitCount: json['visitCount'] as int? ?? 0,
      lastVisitedAt: json['lastVisitedAt'] != null 
          ? DateTime.parse(json['lastVisitedAt'] as String)
          : null,
    );
  }

  /// Favorite 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant': restaurant.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'tags': tags,
      'visitCount': visitCount,
      'lastVisitedAt': lastVisitedAt?.toIso8601String(),
    };
  }

  /// 즐겨찾기 복사 (일부 필드 수정)
  Favorite copyWith({
    String? id,
    Restaurant? restaurant,
    DateTime? createdAt,
    String? note,
    List<String>? tags,
    int? visitCount,
    DateTime? lastVisitedAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      restaurant: restaurant ?? this.restaurant,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      visitCount: visitCount ?? this.visitCount,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
    );
  }

  /// 방문 횟수 증가
  Favorite incrementVisitCount() {
    return copyWith(
      visitCount: visitCount + 1,
      lastVisitedAt: DateTime.now(),
    );
  }

  /// 태그 추가
  Favorite addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// 태그 제거
  Favorite removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// 노트 업데이트
  Favorite updateNote(String? newNote) {
    return copyWith(note: newNote);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Favorite &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Favorite(id: $id, restaurant: ${restaurant.name}, createdAt: $createdAt, visitCount: $visitCount)';
  }
}

/// 즐겨찾기 필터링 옵션
enum FavoriteFilter {
  all,          // 전체
  recent,       // 최근 추가
  mostVisited,  // 자주 방문
  byCategory,   // 카테고리별
  byRating,     // 평점별
}

/// 즐겨찾기 정렬 옵션
enum FavoriteSort {
  dateAdded,    // 추가 날짜순
  lastVisited,  // 마지막 방문순
  visitCount,   // 방문 횟수순
  rating,       // 평점순
  name,         // 이름순
  distance,     // 거리순 (위치 기반)
}

/// 즐겨찾기 통계
class FavoriteStats {
  final int totalCount;
  final int visitedCount;
  final Map<String, int> categoryCounts;
  final Restaurant? mostVisited;
  final Restaurant? highestRated;
  final DateTime? firstAdded;
  final DateTime? lastAdded;

  const FavoriteStats({
    required this.totalCount,
    required this.visitedCount,
    required this.categoryCounts,
    this.mostVisited,
    this.highestRated,
    this.firstAdded,
    this.lastAdded,
  });

  factory FavoriteStats.fromFavorites(List<Favorite> favorites) {
    if (favorites.isEmpty) {
      return const FavoriteStats(
        totalCount: 0,
        visitedCount: 0,
        categoryCounts: {},
      );
    }

    // 방문한 즐겨찾기 (visitCount > 0)
    final visited = favorites.where((f) => f.visitCount > 0).toList();

    // 카테고리별 개수
    final categoryCounts = <String, int>{};
    for (final favorite in favorites) {
      final category = favorite.restaurant.category;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // 가장 많이 방문한 음식점
    Restaurant? mostVisited;
    if (visited.isNotEmpty) {
      visited.sort((a, b) => b.visitCount.compareTo(a.visitCount));
      mostVisited = visited.first.restaurant;
    }

    // 가장 높은 평점 음식점
    final sortedByRating = [...favorites];
    sortedByRating.sort((a, b) => b.restaurant.rating.compareTo(a.restaurant.rating));
    final highestRated = sortedByRating.first.restaurant;

    // 날짜 통계
    final sortedByDate = [...favorites];
    sortedByDate.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final firstAdded = sortedByDate.first.createdAt;
    final lastAdded = sortedByDate.last.createdAt;

    return FavoriteStats(
      totalCount: favorites.length,
      visitedCount: visited.length,
      categoryCounts: categoryCounts,
      mostVisited: mostVisited,
      highestRated: highestRated,
      firstAdded: firstAdded,
      lastAdded: lastAdded,
    );
  }
} 