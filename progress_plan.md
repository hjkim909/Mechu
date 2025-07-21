# 메뉴 추천 앱 개발 진행 계획

## 프로젝트 개요
Flutter를 사용한 메뉴 추천 앱 개발

## 기능 요구사항
- [x] 홈 화면 (원버튼 추천)
- [x] 위치 설정 화면
- [x] 추천 결과 리스트 화면  
- [x] 기본 설정 화면

## 개발 진행 상황

### 현재 상태: UI 최적화 및 애니메이션 추가 완료 - 기본 앱 개발 완료 ✅

### 완료된 작업
- [x] 프로젝트 폴더 구조 생성
- [x] pubspec.yaml 설정 (Provider, Material Design 3)
- [x] main.dart 기본 앱 구조 생성
- [x] 홈 화면 (HomeScreen) 구현
  - [x] 현재 위치 표시 (강남역 하드코딩)
  - [x] 중앙 "지금 추천받기!" 버튼
  - [x] 인원수 선택 슬라이더 (1-10명)
  - [x] Material Design 3 스타일 적용
- [x] 데이터 모델 정의
  - [x] Restaurant 모델 (음식점 정보)
  - [x] RecommendationRequest 모델 (추천 요청)
  - [x] User 모델 (사용자 정보)
  - [x] JSON serialization 설정
- [x] 서비스 레이어 구현
  - [x] LocationService (위치 관련)
  - [x] RecommendationService (메뉴 추천 로직)
  - [x] UserService (사용자 관리)
- [x] 추천 결과 리스트 화면 개발
- [x] 홈 화면과 서비스 연동
- [x] MultiProvider 오류 해결
- [x] Android Studio를 통한 앱 실행 성공
- [x] 기본 기능 테스트 완료
- [x] 위치 설정 화면 개발 완료
  - [x] 현재 위치 표시 및 로딩
  - [x] 즐겨찾기 위치 관리
  - [x] 근처 지역 추천
  - [x] 지역명 검색 기능
  - [x] 홈 화면 연동
- [x] 기본 설정 화면 개발 완료
  - [x] 사용자 프로필 설정
  - [x] 음식 선호도 및 알레르기 정보 설정
  - [x] 앱 설정 (알림, 위치 권한, 테마)
  - [x] 정보 섹션 (앱 정보, 이용약관 등)
  - [x] 홈 화면 설정 버튼 연동
- [x] UserService getCurrentUser 메서드 누락 에러 수정
  - [x] settings_screen.dart 실행 오류 해결
  - [x] 자동 게스트 사용자 생성 로직 추가
- [x] Provider 상태 관리 구현
  - [x] UserProvider: 사용자 정보 및 설정 상태 관리
  - [x] LocationProvider: 위치 정보 상태 관리
  - [x] RecommendationProvider: 메뉴 추천 상태 관리
  - [x] main.dart MultiProvider 설정
  - [x] HomeScreen Provider 패턴 적용
- [x] 메뉴 선택 단계 추가
  - [x] MenuSelectionScreen 새 화면 개발
  - [x] 8가지 메뉴 카테고리 (한식, 중식, 일식, 양식, 치킨, 분식, 카페, 패스트푸드)
  - [x] 그리드 레이아웃으로 시각적 메뉴 선택
  - [x] 홈화면 → 메뉴 선택 → 음식점 추천 플로우 완성
- [x] 메뉴 카테고리 세분화
  - [x] 구체적인 메뉴 12개로 변경 (김치찌개, 삼겹살, 짜장면, 치킨, 라멘, 떡볶이, 피자, 파스타, 햄버거, 초밥, 갈비탕, 카페)
  - [x] 인기 순위 시스템 추가 (1-3위 특별 표시, 불꽃 아이콘)
  - [x] 위치 기반 타이틀 ("강남역 인기 메뉴")
  - [x] 3열 그리드 레이아웃으로 더 많은 메뉴 표시
- [x] 사용자 설정 저장 기능 (SharedPreferences)
  - [x] shared_preferences 패키지 추가
  - [x] PreferencesService 클래스 생성
  - [x] 사용자 이름, 선호 메뉴, 알레르기 정보 저장
  - [x] 현재 위치, 즐겨찾기 위치 저장
  - [x] 인원수 선택, 테마 설정 저장
  - [x] Provider들에 설정 저장/불러오기 로직 추가
  - [x] 앱 재시작 후 설정 유지 기능 완료

- [x] 실제 위치 서비스 연동 (GPS)
  - [x] geolocator, permission_handler 패키지 추가
  - [x] Android/iOS 위치 권한 설정 추가
  - [x] LocationService에 실제 GPS 기능 구현
  - [x] 위치 권한 확인 및 요청 시스템
  - [x] 좌표 기반 지역 추정 시스템
  - [x] HomeScreen에 "현재 위치로 설정" 버튼 추가
  - [x] GPS 실시간 위치 추적 기능 구현

- [x] 테마 변경 기능 구현
  - [x] ThemeProvider 클래스 생성 (라이트/다크/시스템 모드)
  - [x] main.dart에 테마 시스템 적용
  - [x] Material Design 3 기반 라이트/다크 테마 정의
  - [x] SettingsScreen에 테마 선택 다이얼로그 추가
  - [x] 실시간 테마 변경 및 설정 저장 기능 완료

- [x] 외부 API 연동 (음식점 데이터)
  - [x] http 패키지 추가 (^1.1.0)
  - [x] KakaoApiService 클래스 구현
  - [x] ConfigService로 API 키 관리 시스템 구축
  - [x] RecommendationService API 연동 완료
  - [x] 폴백 시스템 구현 (API 실패 시 샘플 데이터 자동 사용)
  - [x] 카테고리별 실제 음식점 검색 기능
  - [x] 키워드 기반 음식점 검색 기능
  - [x] NaverApiService 클래스 구현 및 RecommendationService에 연동
  - [x] kakao_map_plugin 패키지 추가 및 연동
  - [x] 추천 결과 화면에 지도 표시 및 마커 추가
  - [x] 지도 UI 개선 (둥근 모서리, 그림자 효과, 조건부 표시)
  - [x] GPS 위치 자동 설정 기능 구현
  - [x] 강남역 하드코딩 문제 해결 (실제 위치 기반 추천)
  - [x] 개포동, 개포역, 선릉역, 압구정역 위치 정보 추가
  - [x] GPS 버튼 UI 개선

- [x] UI 최적화 및 애니메이션 기능 구현
  - [x] AnimatedButton 위젯 구현 (터치 시 부드러운 스케일 애니메이션)
  - [x] PulseAnimation 위젯 구현 (맥박 효과)
  - [x] 홈 화면 오버플로우 문제 해결 (작은 화면 대응)
  - [x] 레이아웃 최적화 (여백, 패딩, 버튼 크기 조정)
  - [x] 반응형 디자인 구현 (다양한 화면 크기 지원)
  - [x] 스크롤 성능 개선 (ClampingScrollPhysics)
  - [x] 추천 버튼 인터랙션 개선 (터치 피드백)

### 다음 단계
- [x] Flutter 실행 권한 문제 해결 (Android Studio 사용)
- [x] 앱 실행 테스트 및 기능 검증
- [x] 위치 설정 화면 개발
- [x] 기본 설정 화면 개발
- [x] Provider 상태 관리 구현
- [x] 사용자 설정 저장 기능 (SharedPreferences)
- [x] 실제 위치 서비스 연동 (GPS)
- [x] 테마 변경 기능 구현
- [x] 외부 API 연동 (음식점 데이터)
- [x] 카카오 API 키 설정 및 실제 테스트 완료 ✅
  - [x] 지도 표시 기능 및 GPS 위치 자동 설정 완료 ✅
  - [x] UI 최적화 및 애니메이션 추가 완료 ✅
- [ ] 코드 생성 실행 (build_runner) - 필요시
- [ ] UI/UX 고도화 (리뷰 시스템, 즐겨찾기, 추천 이력)
- [ ] 성능 최적화 (캐싱, 이미지 최적화, 오프라인 모드)
- [ ] 앱스토어 배포 준비

## 로그
- 2024년 - 프로젝트 초기 설정 및 홈 화면 완료
- 2024년 - 데이터 모델 정의 완료 (Restaurant, User, RecommendationRequest)
- 2024년 12월 - 현재 상태 분석 완료
  - 기본 기능 구현 완료 확인
  - Flutter 실행 권한 문제 발견 (macOS Gatekeeper 이슈)
  - 코드 검토 완료: 모든 필수 파일 존재 확인
- 2024년 12월 - 기본 기능 테스트 완료 🎉
  - MultiProvider 오류 해결 (빈 providers 배열 문제)
  - Android Studio를 통한 앱 실행 성공
  - 홈 화면, 추천 버튼, 결과 화면 모든 기능 정상 동작 확인
  - 샘플 데이터 기반 추천 시스템 정상 작동
  - Git 저장소 초기화 및 첫 커밋 완료 (bb9e79f)
  - 프로젝트 문서화 완료: 각 디렉토리별 .AI.md 파일 생성 (88ce176)
- 2024년 12월 - 모든 기본 화면 개발 완료 🎉
  - 위치 설정 화면 완료: 현재 위치, 즐겨찾기, 검색 기능 (483303f)
  - 기본 설정 화면 완료: 프로필, 선호도, 앱 설정 (74f1314)
  - 모든 화면 간 네비게이션 연동 완료
  - Material Design 3 일관된 디자인 시스템 적용
- 2024년 12월 - UserService getCurrentUser 에러 수정 완료 🎉
  - settings_screen.dart에서 발생한 메서드 누락 에러 해결
  - UserService에 getCurrentUser() 메서드 추가
  - 현재 사용자가 없으면 자동으로 게스트 사용자 생성하도록 구현
- 2024년 12월 - Provider 상태 관리 구현 완료 🎉
  - UserProvider, LocationProvider, RecommendationProvider 생성
  - main.dart에 MultiProvider 설정 완료
  - HomeScreen을 Provider 패턴으로 전환
  - Consumer 위젯으로 실시간 상태 업데이트
  - 로딩 및 에러 상태 관리 추가
- 2024년 12월 - 메뉴 선택 단계 추가 완료 🎉
  - MenuSelectionScreen 새 화면 개발
  - 8가지 메뉴 카테고리 그리드 UI (한식, 중식, 일식, 양식, 치킨, 분식, 카페, 패스트푸드)
  - 홈화면 → 메뉴 선택 → 음식점 추천의 3단계 플로우 완성
  - 사용자 경험 개선: 메뉴를 먼저 선택하고 맞춤 음식점 추천
- 2024년 12월 - 개발 에러 방지 체크리스트 작성 🛠️
  - import 누락으로 인한 반복 에러 분석 및 해결
  - flutter_development_checklist.md 생성
  - 새로운 화면 개발 시 필수 체크리스트 및 템플릿 제공
  - 일반적인 에러 패턴 및 해결책 문서화
- 2024년 12월 - 사용자 설정 저장 기능 구현 완료 🎉
  - SharedPreferences 패키지 추가 및 PreferencesService 클래스 생성
  - 사용자 이름, 선호 메뉴, 알레르기 정보 저장 기능
  - 현재 위치, 즐겨찾기 위치 저장 기능
  - 인원수 선택, 테마 설정 저장 기능
  - Provider 패턴과 연동하여 앱 재시작 후 설정 유지
  - Android NDK 버전 충돌 해결 (27.0.12077973)
- 2024년 12월 - 실제 위치 서비스 연동 (GPS) 구현 완료 🎉
  - geolocator, permission_handler 패키지 추가
  - Android/iOS 위치 권한 설정 완료
  - LocationService에 실제 GPS 기능 구현
  - 위치 권한 확인 및 요청 시스템 구축
  - 좌표 기반 지역 추정 시스템 (서울 주요 지역)
  - HomeScreen에 "현재 위치로 설정" 버튼 추가
  - GPS 실시간 위치 추적 및 자동 주소 변환 기능
- 2024년 12월 - 테마 변경 기능 구현 완료 🎉
  - ThemeProvider 클래스 생성 (라이트/다크/시스템 모드)
  - main.dart에 Material Design 3 테마 시스템 적용
  - 실시간 테마 변경 및 SharedPreferences 저장
  - SettingsScreen에 테마 선택 다이얼로그 추가
  - 모든 화면에서 테마 적용 확인 완료
- 2024년 12월 - 외부 API 연동 (음식점 데이터) 구현 완료 🎉
  - http 패키지 추가 및 KakaoApiService 클래스 구현
  - ConfigService로 API 키 관리 시스템 구축
  - RecommendationService를 실제 API 호출로 업데이트
  - 폴백 시스템 구현 (API 실패 시 샘플 데이터 자동 사용)
  - 카테고리별/키워드 기반 실제 음식점 검색 기능 완성
  - 개발 모드와 실제 API 모드 분리로 안전한 개발 환경 구축
- 2025년 1월 16일 - 지도 API 연동 및 오류 수정 진행
  - 네이버 API 서비스 (`naver_api_service.dart`) 추가 및 `RecommendationService`에 연동
  - `kakao_map_plugin` 패키지 추가 및 `main.dart`에 초기화 로직 추가
  - Android `AndroidManifest.xml` 및 iOS `Info.plist` 설정 업데이트
  - `recommendation_result_screen.dart`에 지도 표시 및 마커 기능 추가
  - `recommendation_service.dart`의 `getQuickRecommendations` 메서드 복원
  - `settings_screen.dart`의 UI 문법 오류 수정
  - `AndroidManifest.xml`의 중복 `<manifest>` 태그로 인한 XML 파싱 오류 수정
  - `config_service.dart`의 API 키 설정 문제 해결 완료 🎉
    - 컴파일 오류 원인 파악 및 수정 (`_defaultKakaoApiKey` 주석 해제)
    - REST API 키 설정 활성화 (`setKakaoApiKey()` 호출)
    - 실제 API 모드 자동 활성화 완료
    - 401 인증 오류 해결 (올바른 API 키 입력)
    - 실제 카카오 API 데이터 연동 성공 및 테스트 완료 ✅
- 2025년 1월 16일 - 지도 표시 기능 및 GPS 위치 자동 설정 완료 🎉
  - 추천 결과 화면 상단에 지도 표시 기능 추가
  - 지도 UI 개선 (둥근 모서리, 그림자 효과, 조건부 표시)
  - GPS 위치 자동 설정 기능 구현 (앱 시작 시 자동 감지)
  - 강남역 하드코딩 문제 해결 (사용자 실제 위치 기반 추천)
  - 개포동, 개포역, 선릉역, 압구정역 위치 정보 추가
  - GPS 버튼 UI 개선 (더 눈에 띄는 디자인)
- 2025년 7월 13일 - UI 최적화 및 애니메이션 추가 완료 🎉
  - AnimatedButton과 PulseAnimation 위젯 추가 (page_transitions.dart)
  - 홈 화면 오버플로우 문제 해결 (작은 화면 대응)
  - 레이아웃 최적화 (여백, 패딩, 버튼 크기 조정)
  - 부드러운 터치 애니메이션 및 맥박 효과 구현
  - 반응형 디자인 적용 (다양한 화면 크기 지원)
  - 스크롤 성능 개선 (ClampingScrollPhysics)

## 참고 사항
### Flutter 실행 권한 문제 해결 방법 (macOS)
```bash
# 현재 Flutter 경로 확인
which flutter

# 시스템 설정 > 개인정보 보호 및 보안 > 개발자 도구에서 터미널 허용
# 또는 터미널에서 Flutter 실행 허용

# 대안: FVM 사용
brew install fvm
fvm install stable
fvm use stable
```

### JSON 코드 생성 실행 방법
```bash
flutter pub get
flutter packages pub run build_runner build
```

### 카카오 API 연동 방법
#### 1. API 키 발급
1. [카카오 개발자 콘솔](https://developers.kakao.com/)에서 애플리케이션 생성
2. 플랫폼 설정에서 Android/iOS 패키지명 추가
3. 로컬 API 키 복사

#### 2. API 키 설정
```dart
// lib/services/config_service.dart의 setDevelopmentApiKey() 메서드에서
setKakaoApiKey('여기에_실제_API_키_입력');
```

#### 3. 실제 API 모드 활성화
```dart
// ConfigService에서 실제 API 사용 활성화
ConfigService().enableRealApiMode();
```

#### 4. 현재 상태
- 개발 모드: 샘플 데이터 사용 (API 키 없이 테스트 가능)
- 실제 API 키 설정 시: 카카오 로컬 API를 통한 실제 음식점 데이터 사용

### 안드로이드 스튜디오 테스트 체크리스트
#### 실행 전 확인사항
- [x] Flutter 플러그인 설치 확인
- [x] Flutter SDK 경로 설정 (/Users/hyunjoon/Documents/flutter)
- [x] 실행 디바이스 선택 (iOS Simulator/Android Emulator/Chrome)

#### 기본 기능 테스트 - 2024년 12월 완료 ✅
- [x] 홈 화면 정상 로딩
- [x] "강남역" 위치 표시 확인
- [x] 인원수 슬라이더 동작 (1~10명)
- [x] "지금 추천받기!" 버튼 클릭
- [x] 로딩 애니메이션 표시
- [x] 추천 결과 화면 이동
- [x] 음식점 목록 표시 확인
- [x] 음식점 카드 터치 반응

#### 실행 방법
1. Android Studio에서 프로젝트 열기
2. 상단 툴바에서 디바이스 선택
3. 초록색 플레이 버튼 클릭 또는 Shift+F10