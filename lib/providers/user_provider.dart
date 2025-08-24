import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// 사용자 정보 및 설정 상태 관리
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _currentUser!.id != 'guest';

  /// 사용자 초기화 (앱 시작 시 호출)
  Future<void> initializeUser() async {
    _setLoading(true);
    try {
      _currentUser = await _userService.getCurrentUser();
      
      // 저장된 설정 불러오기
      await _loadSavedPreferences();
      
      _clearError();
    } catch (e) {
      _setError('사용자 정보를 불러올 수 없습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 저장된 설정 불러오기
  Future<void> _loadSavedPreferences() async {
    if (_currentUser == null) return;

    try {
      // 저장된 사용자 이름 불러오기
      final savedName = PreferencesService.getUserName();
      if (savedName != '게스트') {
        _currentUser = _currentUser!.copyWith(name: savedName);
      }

      // 저장된 선호 메뉴 불러오기
      final savedPreferredMenus = PreferencesService.getPreferredMenus();
      // 저장된 알레르기 정보 불러오기
      final savedAllergies = PreferencesService.getAllergies();
      
      if (savedPreferredMenus.isNotEmpty || savedAllergies.isNotEmpty) {
        final updatedPreferences = _currentUser!.preferences.copyWith(
          favoriteCategories: savedPreferredMenus,
          allergies: savedAllergies,
        );
        _currentUser = _currentUser!.copyWith(preferences: updatedPreferences);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('저장된 설정을 불러오는 중 오류 발생: $e');
    }
  }

  /// 사용자 이름 업데이트
  Future<void> updateUserName(String newName) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      _currentUser = await _userService.updateUserName(newName);
      
      // 설정 저장
      await PreferencesService.setUserName(newName);
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('이름 업데이트에 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 선호도 업데이트
  Future<void> updateUserPreferences(UserPreferences newPreferences) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      _currentUser = await _userService.updateUserPreferences(newPreferences);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('설정 업데이트에 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 선호 카테고리 토글
  Future<void> toggleFavoriteCategory(String category) async {
    if (_currentUser == null) return;

    final favorites = _currentUser!.preferences.favoriteCategories;
    
    try {
      if (favorites.contains(category)) {
        await _userService.removeFavoriteCategory(category);
      } else {
        await _userService.addFavoriteCategory(category);
      }
      _currentUser = _userService.currentUser;
      
      // 설정 저장
      await PreferencesService.setPreferredMenus(_currentUser!.preferences.favoriteCategories);
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('카테고리 설정에 실패했습니다: $e');
    }
  }

  /// 싫어하는 카테고리 토글
  Future<void> toggleDislikedCategory(String category) async {
    if (_currentUser == null) return;

    final dislikes = _currentUser!.preferences.dislikedCategories;
    
    try {
      if (dislikes.contains(category)) {
        await _userService.removeDislikedCategory(category);
      } else {
        await _userService.addDislikedCategory(category);
      }
      _currentUser = _userService.currentUser;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('카테고리 설정에 실패했습니다: $e');
    }
  }

  /// 선호 가격대 업데이트
  Future<void> updatePreferredPriceLevel(int priceLevel) async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _userService.updatePreferredPriceLevel(priceLevel);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('가격대 설정에 실패했습니다: $e');
    }
  }

  /// 최소 평점 업데이트
  Future<void> updateMinRating(double minRating) async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _userService.updateMinRating(minRating);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('평점 설정에 실패했습니다: $e');
    }
  }

  /// 알레르기 정보 업데이트
  Future<void> updateAllergies(List<String> allergies) async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _userService.updateAllergies(allergies);
      
      // 설정 저장
      await PreferencesService.setAllergies(allergies);
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('알레르기 정보 설정에 실패했습니다: $e');
    }
  }

  /// 채식주의자 설정 업데이트
  Future<void> updateVegetarian(bool isVegetarian) async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _userService.updateVegetarian(isVegetarian);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('채식 설정에 실패했습니다: $e');
    }
  }

  /// 사용자 로그아웃
  void logout() {
    _userService.logoutUser();
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading == loading) return; // 불필요한 업데이트 방지
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    if (_error == error) return; // 동일한 에러 중복 방지
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error == null) return; // 이미 null인 경우 스킵
    _error = null;
  }
} 