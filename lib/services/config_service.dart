/// 앱 설정 관리 서비스
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // API 키들 (실제 배포 시에는 환경변수나 보안 저장소에서 가져와야 함)
  static const String _defaultKakaoApiKey = 'YOUR_KAKAO_API_KEY_HERE';
  
  String? _kakaoApiKey;
  bool _useRealApi = false; // 개발 단계에서는 false로 시작

  /// 카카오 API 키 설정
  void setKakaoApiKey(String apiKey) {
    _kakaoApiKey = apiKey;
    _useRealApi = apiKey.isNotEmpty && apiKey != _defaultKakaoApiKey;
  }

  /// 카카오 API 키 가져오기
  String get kakaoApiKey => _kakaoApiKey ?? _defaultKakaoApiKey;

  /// 실제 API 사용 여부
  bool get useRealApi => _useRealApi;

  /// API 키가 설정되었는지 확인
  bool get hasValidApiKey => _kakaoApiKey != null && 
                            _kakaoApiKey!.isNotEmpty && 
                            _kakaoApiKey != _defaultKakaoApiKey;

  /// 개발 모드에서 샘플 데이터 사용 강제
  void enableSampleDataMode() {
    _useRealApi = false;
  }

  /// 실제 API 모드 활성화 (API 키가 유효한 경우에만)
  void enableRealApiMode() {
    if (hasValidApiKey) {
      _useRealApi = true;
    }
  }

  /// 설정 상태 정보
  Map<String, dynamic> getConfigStatus() {
    return {
      'hasValidApiKey': hasValidApiKey,
      'useRealApi': useRealApi,
      'kakaoApiKeyLength': kakaoApiKey.length,
      'isDefaultKey': kakaoApiKey == _defaultKakaoApiKey,
    };
  }

  /// 개발용 API 키 설정 (실제 키로 교체 필요)
  void setDevelopmentApiKey() {
    // 개발 단계에서는 실제 API 키를 여기에 설정
    // 실제 배포 시에는 이 메서드를 제거하거나 환경변수에서 가져오도록 변경
    
    // 예시: setKakaoApiKey('실제_카카오_API_키');
    
    // 현재는 샘플 데이터 모드로 유지
    enableSampleDataMode();
  }
} 