import 'package:flutter/material.dart';
import '../services/services.dart';

/// 테마 상태 관리
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// 테마 초기화 (앱 시작 시 호출)
  Future<void> initializeTheme() async {
    _setLoading(true);
    try {
      String savedTheme = PreferencesService.getThemeMode();
      _themeMode = _getThemeModeFromString(savedTheme);
      notifyListeners();
    } catch (e) {
      debugPrint('테마 초기화 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode == newThemeMode) return;

    _setLoading(true);
    try {
      _themeMode = newThemeMode;
      
      // 설정 저장
      await PreferencesService.setThemeMode(_getStringFromThemeMode(newThemeMode));
      
      notifyListeners();
    } catch (e) {
      debugPrint('테마 변경 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 다크 모드 토글
  Future<void> toggleDarkMode() async {
    ThemeMode newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// 라이트 모드로 설정
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// 다크 모드로 설정
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// 시스템 모드로 설정 (자동)
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// ThemeMode를 문자열로 변환
  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// 문자열을 ThemeMode로 변환
  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 현재 테마 상태 텍스트 반환
  String get currentThemeText {
    switch (_themeMode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  /// 테마 아이콘 반환
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
} 