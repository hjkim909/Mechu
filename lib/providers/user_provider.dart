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
      _clearError();
    } catch (e) {
      _setError('사용자 정보를 불러올 수 없습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 이름 업데이트
  Future<void> updateUserName(String newName) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      _currentUser = await _userService.updateUserName(newName);
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