# 메뉴 추천 앱 (Mechu) 기술 문서

**최종 업데이트**: 2025년 8월 23일  
**GitHub 저장소**: https://github.com/hjkim909/Mechu  
**로컬 경로**: `/Users/hyunjoon/StudioProjects/Mechu`

---

## 📱 앱 플로우

### 핵심 사용자 경험
1. **홈 화면**: 현재 위치 표시, 인원수 선택, "지금 추천받기!" 버튼
2. **스와이프 추천**: 확률 기반 메뉴 추천 (김치찌개 20%, 삼겹살 15% 등)
3. **추천 결과**: 주변 음식점 리스트 + 지도 표시
4. **추천 이력**: 과거 추천 기록 및 방문 여부 관리
5. **설정**: 사용자 프로필, 선호도, 테마 설정

## 🛠 기술 스택

### 핵심 아키텍처
- **상태 관리**: Provider 패턴
- **데이터 저장**: SharedPreferences (로컬)
- **위치 서비스**: Geolocator + Permission Handler
- **API 통신**: HTTP + 카카오/네이버 API
- **UI 프레임워크**: Material Design 3

### 주요 의존성
```yaml
provider: ^6.1.1              # 상태 관리
shared_preferences: ^2.2.2    # 설정 저장
geolocator: ^10.1.0          # GPS
permission_handler: ^11.2.0   # 권한 관리
http: ^1.1.0                 # API 통신
kakao_map_plugin            # 지도 표시
```

## 📁 핵심 파일 구조

### 🔑 주요 디렉토리
- **`lib/screens/`**: 화면 UI (홈, 추천, 결과, 설정 등)
- **`lib/providers/`**: Provider 상태 관리 클래스들
- **`lib/services/`**: API 호출, GPS, 데이터 저장 로직
- **`lib/models/`**: 데이터 모델 (Restaurant, User, History 등)

### 🔧 핵심 설정 파일
- **`pubspec.yaml`**: Flutter 의존성 설정
- **`lib/services/config_service.dart`**: API 키 관리
- **`android/app/src/main/AndroidManifest.xml`**: Android 권한 설정
- **`ios/Runner/Info.plist`**: iOS 권한 설정

## 🔧 개발 환경 설정

### API 키 설정 (운영 환경용)
```dart
// lib/services/config_service.dart
void setDevelopmentApiKey() {
  setKakaoApiKey('실제_카카오_API_키');  // REST API 키 입력
  enableRealApiMode();
}
```

### 위치 권한 설정

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 음식점 추천을 위해 위치 정보가 필요합니다.</string>
```

## 🚀 실행 및 테스트

### 개발 환경 실행
```bash
# Android Studio에서 실행 (권장)
1. Open Project → Mechu 폴더 선택
2. 디바이스 선택 (iOS/Android Simulator)
3. Run 버튼 클릭

# 터미널 실행 (권한 문제 시 Android Studio 사용)
flutter run
```

### 주요 테스트 포인트
- **GPS 위치**: 실제 기기에서 위치 권한 및 GPS 동작 확인
- **스와이프 추천**: 확률 기반 메뉴 추천 동작
- **API 연동**: 실제 음식점 데이터 검색 (API 키 설정 시)
- **이력 관리**: 추천 기록 저장 및 방문 여부 업데이트

## 💡 코딩 규칙

### 네이밍 컨벤션
- **파일**: `snake_case.dart`
- **클래스**: `PascalCase`
- **변수/함수**: `camelCase`

### 아키텍처 패턴
- **상태 관리**: Provider 패턴 (Consumer/context.read)
- **비즈니스 로직**: Services 레이어
- **에러 처리**: try-catch + 사용자 친화적 메시지

---

## 📞 문의 및 이슈

**GitHub Issues**: https://github.com/hjkim909/Mechu/issues  
**프로젝트 완성도**: 80% (실기기 테스트 및 최적화 단계)