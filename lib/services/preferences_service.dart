import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _keyUserName = 'user_name';
  static const String _keyPreferredMenus = 'preferred_menus';
  static const String _keyAllergies = 'allergies';
  static const String _keyFavoriteLocations = 'favorite_locations';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLocationPermissionEnabled = 'location_permission_enabled';
  static const String _keyCurrentLocation = 'current_location';
  static const String _keySelectedNumberOfPeople = 'selected_number_of_people';

  static SharedPreferences? _prefs;

  // SharedPreferences 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 사용자 이름 관련
  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_keyUserName, name);
  }

  static String getUserName() {
    return _prefs?.getString(_keyUserName) ?? '게스트';
  }

  // 선호 메뉴 관련
  static Future<void> setPreferredMenus(List<String> menus) async {
    await _prefs?.setStringList(_keyPreferredMenus, menus);
  }

  static List<String> getPreferredMenus() {
    return _prefs?.getStringList(_keyPreferredMenus) ?? [];
  }

  // 알레르기 정보 관련
  static Future<void> setAllergies(List<String> allergies) async {
    await _prefs?.setStringList(_keyAllergies, allergies);
  }

  static List<String> getAllergies() {
    return _prefs?.getStringList(_keyAllergies) ?? [];
  }

  // 즐겨찾기 위치 관련
  static Future<void> setFavoriteLocations(List<String> locations) async {
    await _prefs?.setStringList(_keyFavoriteLocations, locations);
  }

  static List<String> getFavoriteLocations() {
    return _prefs?.getStringList(_keyFavoriteLocations) ?? ['강남역', '홍대입구', '신촌'];
  }

  // 테마 설정 관련
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_keyThemeMode, themeMode);
  }

  static String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? 'system';
  }

  // 알림 설정 관련
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  }

  // 위치 권한 설정 관련
  static Future<void> setLocationPermissionEnabled(bool enabled) async {
    await _prefs?.setBool(_keyLocationPermissionEnabled, enabled);
  }

  static bool getLocationPermissionEnabled() {
    return _prefs?.getBool(_keyLocationPermissionEnabled) ?? true;
  }

  // 현재 위치 관련
  static Future<void> setCurrentLocation(String location) async {
    await _prefs?.setString(_keyCurrentLocation, location);
  }

  static String getCurrentLocation() {
    return _prefs?.getString(_keyCurrentLocation) ?? '강남역';
  }

  // 인원수 설정 관련
  static Future<void> setSelectedNumberOfPeople(int numberOfPeople) async {
    await _prefs?.setInt(_keySelectedNumberOfPeople, numberOfPeople);
  }

  static int getSelectedNumberOfPeople() {
    return _prefs?.getInt(_keySelectedNumberOfPeople) ?? 2;
  }

  // 모든 설정 삭제
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // 특정 키 존재 여부 확인
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // 복합 데이터 저장 (JSON 형태)
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _prefs?.setString(key, json.encode(value));
  }

  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString);
    }
    return null;
  }
} 