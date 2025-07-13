/// 앱 설정 관리 서비스
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // API 키들 (실제 배포 시에는 환경변수나 보안 저장소에서 가져와야 함)
  static const String _defaultKakaoApiKey = 'SAMPLE_KAKAO_API_KEY';
  static const String _defaultNaverClientId = 'YOUR_NAVER_CLIENT_ID_HERE';
  static const String _defaultNaverClientSecret = 'YOUR_NAVER_CLIENT_SECRET_HERE';
  static const String _defaultKakaoJsApiKey = 'YOUR_KAKAO_JAVASCRIPT_KEY_HERE';

  String? _kakaoApiKey;
  String? _naverClientId;
  String? _naverClientSecret;
  String? _kakaoJsApiKey;
  bool _useRealApi = false; // 개발 단계에서는 false로 시작

  /// 카카오 API 키 설정
  void setKakaoApiKey(String apiKey) {
    _kakaoApiKey = apiKey;
    _updateApiMode();
  }

  /// 네이버 API 키 설정
  void setNaverApiKey({required String clientId, required String clientSecret}) {
    _naverClientId = clientId;
    _naverClientSecret = clientSecret;
    _updateApiMode();
  }

  /// 카카오 JavaScript API 키 설정
  void setKakaoJsApiKey(String apiKey) {
    _kakaoJsApiKey = apiKey;
  }

  /// 카카오 API 키 가져오기
  String get kakaoApiKey => _kakaoApiKey ?? _defaultKakaoApiKey;

  /// 네이버 Client ID 가져오기
  String get naverClientId => _naverClientId ?? _defaultNaverClientId;

  /// 네이버 Client Secret 가져오기
  String get naverClientSecret => _naverClientSecret ?? _defaultNaverClientSecret;

  /// 카카오 JavaScript API 키 가져오기
  String get kakaoJsApiKey => _kakaoJsApiKey ?? _defaultKakaoJsApiKey;

  /// 실제 API 사용 여부
  bool get useRealApi => _useRealApi;

  /// API 키가 설정되었는지 확인
  bool get hasValidKakaoApiKey => _kakaoApiKey != null &&
                                _kakaoApiKey!.isNotEmpty &&
                                _kakaoApiKey != _defaultKakaoApiKey;

  bool get hasValidNaverApiKey => _naverClientId != null &&
                                _naverClientId!.isNotEmpty &&
                                _naverClientId != _defaultNaverClientId &&
                                _naverClientSecret != null &&
                                _naverClientSecret!.isNotEmpty &&
                                _naverClientSecret != _defaultNaverClientSecret;

  /// 개발 모드에서 샘플 데이터 사용 강제
  void enableSampleDataMode() {
    _useRealApi = false;
  }

  /// 실제 API 모드 활성화 (API 키가 유효한 경우에만)
  void enableRealApiMode() {
    _updateApiMode();
  }

  void _updateApiMode() {
    _useRealApi = hasValidKakaoApiKey || hasValidNaverApiKey;
  }

  /// 설정 상태 정보
  Map<String, dynamic> getConfigStatus() {
    return {
      'hasValidKakaoApiKey': hasValidKakaoApiKey,
      'hasValidNaverApiKey': hasValidNaverApiKey,
      'useRealApi': useRealApi,
      'kakaoApiKeyLength': kakaoApiKey.length,
      'isDefaultKey': kakaoApiKey == _defaultKakaoApiKey,
    };
  }

  /// 개발용 API 키 설정 (실제 키로 교체 필요)
  void setDevelopmentApiKey() {
    // 개발 단계에서는 실제 API 키를 여기에 설정
    // 실제 배포 시에는 이 메서드를 제거하거나 환경변수에서 가져오도록 변경
    
    // 여기에 실제 발급받은 키를 입력하세요.
    setKakaoApiKey('8188beb46343da3d67ecd74de684fa94'); // REST API 키
    setKakaoJsApiKey('2171c43affc50e2a2d004d91c9cba2fd'); // JavaScript 키
    // setNaverApiKey(clientId: 'YOUR_NAVER_CLIENT_ID', clientSecret: 'YOUR_NAVER_CLIENT_SECRET');
    
    // 실제 API 모드를 활성화합니다.
    enableRealApiMode();
  }
} 