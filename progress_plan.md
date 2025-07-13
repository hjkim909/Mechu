# 메뉴 추천 앱 개발 진행 계획

## 프로젝트 개요
Flutter를 사용한 메뉴 추천 앱 개발

## 기능 요구사항
- [x] 홈 화면 (원버튼 추천)
- [x] 위치 설정 화면
- [x] 추천 결과 리스트 화면  
- [x] 기본 설정 화면

## 개발 진행 상황

### 현재 상태: 메뉴 선택 단계 추가 완료 ✅

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

### 다음 단계
- [x] Flutter 실행 권한 문제 해결 (Android Studio 사용)
- [x] 앱 실행 테스트 및 기능 검증
- [x] 위치 설정 화면 개발
- [x] 기본 설정 화면 개발
- [x] Provider 상태 관리 구현
- [x] 사용자 설정 저장 기능 (SharedPreferences)
- [x] 실제 위치 서비스 연동 (GPS)
- [ ] 외부 API 연동 (음식점 데이터)
- [ ] 테마 변경 기능 구현
- [ ] 코드 생성 실행 (build_runner) - 필요시

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