import '../models/models.dart';
import '../utils/sample_data.dart';

/// 사용자 관리 서비스
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  User? _currentUser;

  /// 현재 로그인된 사용자
  User? get currentUser => _currentUser;

  /// 현재 사용자 가져오기 (없으면 게스트 사용자 생성)
  Future<User> getCurrentUser() async {
    if (_currentUser == null) {
      _currentUser = createGuestUser();
    }
    return _currentUser!;
  }

  /// 사용자 로그인 (시뮬레이션)
  Future<User> loginUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1)); // 로그인 시뮬레이션

    // 시뮬레이션된 사용자 데이터
    if (userId == 'demo') {
      _currentUser = SampleData.getSampleUser();
    } else {
      // 새로운 사용자 생성
      _currentUser = User.create(
        id: userId,
        name: '사용자$userId',
      );
    }

    // 로그인 시간 업데이트
    _currentUser = _currentUser!.updateLastLogin();
    
    return _currentUser!;
  }

  /// 게스트로 사용 (로그인 없이)
  User createGuestUser() {
    _currentUser = User.create(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: '게스트',
    );
    return _currentUser!;
  }

  /// 사용자 로그아웃
  void logoutUser() {
    _currentUser = null;
  }

  /// 사용자 선호도 업데이트
  Future<User> updateUserPreferences(UserPreferences newPreferences) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await Future.delayed(const Duration(milliseconds: 500)); // 저장 시뮬레이션

    _currentUser = _currentUser!.copyWith(preferences: newPreferences);
    return _currentUser!;
  }

  /// 사용자 이름 업데이트
  Future<User> updateUserName(String newName) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = _currentUser!.copyWith(name: newName);
    return _currentUser!;
  }

  /// 선호 카테고리 추가
  Future<User> addFavoriteCategory(String category) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final currentFavorites = List<String>.from(_currentUser!.preferences.favoriteCategories);
    if (!currentFavorites.contains(category)) {
      currentFavorites.add(category);
      
      final newPreferences = _currentUser!.preferences.copyWith(
        favoriteCategories: currentFavorites,
      );
      
      return updateUserPreferences(newPreferences);
    }
    
    return _currentUser!;
  }

  /// 선호 카테고리 제거
  Future<User> removeFavoriteCategory(String category) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final currentFavorites = List<String>.from(_currentUser!.preferences.favoriteCategories);
    currentFavorites.remove(category);
    
    final newPreferences = _currentUser!.preferences.copyWith(
      favoriteCategories: currentFavorites,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 싫어하는 카테고리 추가
  Future<User> addDislikedCategory(String category) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final currentDislikes = List<String>.from(_currentUser!.preferences.dislikedCategories);
    if (!currentDislikes.contains(category)) {
      currentDislikes.add(category);
      
      final newPreferences = _currentUser!.preferences.copyWith(
        dislikedCategories: currentDislikes,
      );
      
      return updateUserPreferences(newPreferences);
    }
    
    return _currentUser!;
  }

  /// 싫어하는 카테고리 제거
  Future<User> removeDislikedCategory(String category) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final currentDislikes = List<String>.from(_currentUser!.preferences.dislikedCategories);
    currentDislikes.remove(category);
    
    final newPreferences = _currentUser!.preferences.copyWith(
      dislikedCategories: currentDislikes,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 선호 가격대 업데이트
  Future<User> updatePreferredPriceLevel(int priceLevel) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    if (priceLevel < 1 || priceLevel > 4) {
      throw ArgumentError('가격 수준은 1-4 사이여야 합니다.');
    }

    final newPreferences = _currentUser!.preferences.copyWith(
      preferredPriceLevel: priceLevel,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 최소 평점 업데이트
  Future<User> updateMinRating(double minRating) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    if (minRating < 0 || minRating > 5) {
      throw ArgumentError('평점은 0-5 사이여야 합니다.');
    }

    final newPreferences = _currentUser!.preferences.copyWith(
      minRating: minRating,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 알레르기 정보 업데이트
  Future<User> updateAllergies(List<String> allergies) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final newPreferences = _currentUser!.preferences.copyWith(
      allergies: allergies,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 채식주의자 설정 업데이트
  Future<User> updateVegetarian(bool isVegetarian) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final newPreferences = _currentUser!.preferences.copyWith(
      vegetarian: isVegetarian,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 할랄 설정 업데이트
  Future<User> updateHalal(bool isHalal) async {
    if (_currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final newPreferences = _currentUser!.preferences.copyWith(
      halal: isHalal,
    );
    
    return updateUserPreferences(newPreferences);
  }

  /// 사용자 통계 정보
  Map<String, dynamic> getUserStats() {
    if (_currentUser == null) {
      return {};
    }

    return {
      'favoriteCount': _currentUser!.preferences.favoriteCategories.length,
      'dislikedCount': _currentUser!.preferences.dislikedCategories.length,
      'preferredPriceLevel': _currentUser!.preferences.preferredPriceLevel,
      'minRating': _currentUser!.preferences.minRating,
      'hasAllergies': _currentUser!.preferences.allergies.isNotEmpty,
      'isVegetarian': _currentUser!.preferences.vegetarian,
      'isHalal': _currentUser!.preferences.halal,
      'memberSince': _currentUser!.createdAt,
      'lastLogin': _currentUser!.lastLoginAt,
    };
  }

  /// 기본 초기화 (앱 시작시 호출)
  Future<void> initialize() async {
    // 실제 앱에서는 저장된 사용자 정보를 불러옵니다
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 게스트 사용자로 초기화
    createGuestUser();
  }
} 