# 메뉴 추천 앱 (Mechu) 개발 프로젝트 인계

**작성일**: 2025년 7월 13일  
**프로젝트 상태**: 기본 기능 구현 완료, API 연동 완료 (개발 모드)

---

## 📋 프로젝트 개요
- **앱명**: Mechu (메뉴 추천 Flutter 앱)
- **GitHub 저장소**: https://github.com/hjkim909/Mechu
- **로컬 경로**: `/Users/hyunjoon/StudioProjects/Mechu`
- **개발 환경**: macOS, Android Studio 사용 (Flutter 터미널 권한 문제로)
- **브랜치**: main

## 🎯 프로젝트 목표
사용자의 위치와 선호도를 기반으로 주변 음식점을 추천하는 Flutter 앱

## ✅ 완료된 주요 기능들

### 1. 기본 앱 구조 (100% 완료)
- **화면**: 홈, 메뉴선택, 추천결과, 위치설정, 설정 (5개 화면)
- **네비게이션**: 화면 간 완전한 플로우 구현
- **Material Design 3**: 일관된 디자인 시스템 적용

### 2. 상태 관리 (Provider 패턴 - 100% 완료)
- **UserProvider**: 사용자 정보 및 설정 관리
- **LocationProvider**: 위치 정보 실시간 상태 관리
- **RecommendationProvider**: 메뉴 추천 상태 관리  
- **ThemeProvider**: 테마 변경 상태 관리

### 3. 데이터 저장 (SharedPreferences - 100% 완료)
- **PreferencesService**: 사용자 설정 영구 저장
- **저장 항목**: 이름, 선호메뉴, 알레르기, 위치, 테마, 인원수
- **앱 재시작 후 설정 유지**: 완전 구현

### 4. 위치 서비스 (GPS 연동 - 100% 완료)
- **LocationService**: 실제 GPS 기능 구현
- **권한 관리**: Android/iOS 위치 권한 자동 처리
- **주소 변환**: 좌표 → 지역명 변환 시스템

### 5. 테마 시스템 (100% 완료)
- **3가지 모드**: 라이트, 다크, 시스템 자동
- **실시간 변경**: 설정 즉시 적용
- **Material Design 3**: 최신 디자인 가이드 적용

### 6. 외부 API 연동 (카카오 로컬 API - 100% 완료)
- **KakaoApiService**: 실제 음식점 데이터 검색
- **ConfigService**: API 키 안전한 관리
- **폴백 시스템**: API 실패 시 샘플 데이터 자동 사용
- **검색 기능**: 카테고리별/키워드 기반 음식점 검색

### 7. 메뉴 선택 시스템 (100% 완료)
- **12개 구체적 메뉴**: 김치찌개, 삼겹살, 짜장면, 치킨, 라멘, 떡볶이, 피자, 파스타, 햄버거, 초밥, 갈비탕, 카페
- **인기 순위 시스템**: 1-3위 특별 표시 (금은동 메달, 불꽃 아이콘)
- **위치 기반 타이틀**: "강남역 인기 메뉴" 형태

## 🛠 기술 스택

### Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.1              # 상태 관리
  shared_preferences: ^2.2.2    # 로컬 데이터 저장
  geolocator: ^10.1.0          # GPS 위치 서비스
  permission_handler: ^11.2.0   # 권한 관리
  http: ^1.1.0                 # API 통신
  json_annotation: ^4.8.1      # JSON 직렬화
  material_symbols_icons: ^4.2719.3  # 아이콘
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^5.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

### 주요 패키지별 용도
- **Provider**: 전역 상태 관리 (사용자, 위치, 추천, 테마)
- **SharedPreferences**: 사용자 설정 영구 저장
- **Geolocator**: GPS 위치 서비스
- **Permission Handler**: 위치 권한 관리
- **HTTP**: 카카오 API 통신
- **JSON Annotation**: 데이터 모델 직렬화

## 📁 프로젝트 구조
```
lib/
├── main.dart              # 앱 진입점
├── models/               # 데이터 모델
│   ├── models.dart           # 모델 export
│   ├── restaurant.dart       # 음식점 모델
│   ├── user.dart            # 사용자 모델
│   └── recommendation_request.dart  # 추천 요청 모델
├── providers/            # 상태 관리
│   ├── providers.dart        # Provider export
│   ├── user_provider.dart    # 사용자 상태 관리
│   ├── location_provider.dart # 위치 상태 관리
│   ├── recommendation_provider.dart # 추천 상태 관리
│   └── theme_provider.dart   # 테마 상태 관리
├── screens/              # 화면
│   ├── home_screen.dart      # 홈 화면
│   ├── menu_selection_screen.dart # 메뉴 선택 화면
│   ├── recommendation_result_screen.dart # 추천 결과 화면
│   ├── location_setting_screen.dart # 위치 설정 화면
│   └── settings_screen.dart  # 설정 화면
├── services/             # 비즈니스 로직
│   ├── services.dart         # 서비스 export
│   ├── user_service.dart     # 사용자 서비스
│   ├── location_service.dart # 위치 서비스
│   ├── recommendation_service.dart # 추천 서비스
│   ├── preferences_service.dart # 설정 저장 서비스
│   ├── kakao_api_service.dart # 카카오 API 서비스
│   └── config_service.dart   # 앱 설정 서비스
├── utils/
│   └── sample_data.dart      # 샘플 데이터
└── widgets/              # 재사용 위젯 (향후 확장)
```

## 🔧 현재 개발 상태 (2025년 7월 13일 기준)
- **기본 기능**: 100% 완료
- **API 연동**: 100% 완료 (개발 모드로 동작 중)
- **테스트**: Android Studio에서 정상 동작 확인
- **Git 상태**: 모든 변경사항 커밋 완료, GitHub 업로드 완료

## 🎯 다음 단계 작업 (우선순위 순)

### 1. 카카오 API 키 설정 및 실제 테스트 (높음)
**현재 상태**: 개발 모드 (샘플 데이터 사용)

**설정 방법**:
1. [카카오 개발자 콘솔](https://developers.kakao.com/)에서 애플리케이션 생성
2. 플랫폼 설정에서 Android/iOS 패키지명 추가 
3. REST API 키 발급
4. 코드 수정:
```dart
// lib/services/config_service.dart 수정
void setDevelopmentApiKey() {
  setKakaoApiKey('실제_카카오_API_키_입력');
  enableRealApiMode();
}
```

### 2. UI/UX 개선 (중간)
- **로딩 애니메이션**: 더 세련된 로딩 화면
- **에러 핸들링**: 사용자 친화적 에러 메시지
- **접근성**: 스크린 리더 지원 개선
- **애니메이션**: 화면 전환 효과 추가
- **반응형 디자인**: 다양한 화면 크기 대응

### 3. 기능 고도화 (중간)
- **리뷰 시스템**: 사용자 리뷰 및 평점 기능
- **즐겨찾기**: 음식점 북마크 기능
- **추천 이력**: 과거 추천 기록 저장
- **푸시 알림**: 새로운 맛집 알림 기능
- **소셜 기능**: 친구와 맛집 공유

### 4. 성능 최적화 (낮음)
- **캐싱**: API 응답 캐싱 시스템
- **이미지 최적화**: 음식점 이미지 로딩 개선
- **메모리 관리**: 메모리 누수 방지
- **네트워크 최적화**: 오프라인 모드 지원

## ⚠️ 중요 주의사항

### 1. 개발 환경
- **Flutter 터미널 권한 문제**: macOS에서 직접 `flutter` 명령어 실행 불가
- **해결 방법**: Android Studio 사용 또는 권한 설정 변경
- **pubspec.yaml 수정 시**: Android Studio에서 저장하면 자동 pub get
- **테스트 환경**: iOS Simulator, Android Emulator 모두 지원

### 2. API 키 관리
- **현재 상태**: 개발 모드 (샘플 데이터 사용)
- **실제 API 키**: `lib/services/config_service.dart`에서 설정
- **보안**: 실제 배포 시 환경변수 또는 보안 저장소 사용 필요
- **폴백 시스템**: API 실패 시 샘플 데이터 자동 사용

### 3. 테스트 방법
**Android Studio에서 테스트**:
1. 프로젝트 열기
2. 디바이스 선택 (iOS Simulator/Android Emulator)
3. 실행 버튼 클릭

**기능 테스트 체크리스트**:
- [ ] 홈 화면 → 메뉴 선택 → 추천 결과 플로우
- [ ] 위치 설정 → GPS 위치 가져오기
- [ ] 설정 화면 → 테마 변경
- [ ] 사용자 설정 → 저장 및 복원
- [ ] 인원수 슬라이더 → 설정 저장

### 4. Git 작업 방법
```bash
# 변경사항 확인
git status

# 변경사항 커밋
git add .
git commit -m "작업 내용 설명"
git push

# 브랜치 확인
git branch
```

### 5. 개발 규칙
- **파일 네이밍**: snake_case (예: `home_screen.dart`)
- **클래스 네이밍**: PascalCase (예: `HomeScreen`)
- **변수 네이밍**: camelCase (예: `userName`)
- **상태 관리**: Provider 패턴 사용
- **에러 처리**: try-catch 블록 필수

## 📱 앱 플로우
1. **홈 화면**: 현재 위치 표시, 인원수 선택, "지금 추천받기!" 버튼
2. **메뉴 선택**: 12개 메뉴 카테고리 중 선택
3. **추천 결과**: 선택한 메뉴의 주변 음식점 리스트 표시
4. **위치 설정**: GPS 위치 가져오기, 즐겨찾기 위치 관리
5. **설정**: 사용자 프로필, 선호도, 테마 설정

## 🔄 개발 히스토리 (주요 커밋)
- **초기 설정**: 프로젝트 생성 및 기본 구조
- **Provider 구현**: 상태 관리 시스템 구축
- **메뉴 선택 추가**: 12개 메뉴 카테고리 시스템
- **GPS 연동**: 실제 위치 서비스 구현
- **설정 저장**: SharedPreferences 연동
- **테마 시스템**: 라이트/다크 모드 구현
- **API 연동**: 카카오 로컬 API 연동 (2025-07-13 최종)

## 🎨 개발 철학
- **사용자 중심**: 직관적이고 사용하기 쉬운 UI
- **안정성**: 에러 상황에서도 앱이 중단되지 않음
- **확장성**: 새로운 기능 추가가 용이한 구조
- **성능**: 빠른 응답 속도와 부드러운 사용자 경험
- **접근성**: 모든 사용자가 사용할 수 있는 앱

## 🔮 향후 로드맵
1. **단기 (1-2주)**: 카카오 API 키 설정, 실제 데이터 테스트
2. **중기 (1-2개월)**: UI/UX 개선, 추가 기능 구현
3. **장기 (3-6개월)**: 앱스토어 배포, 사용자 피드백 반영

## 🔄 현재 상태 요약 (2025년 7월 13일)
완성도 높은 메뉴 추천 앱으로 모든 기본 기능이 구현되어 있습니다. 카카오 API 키만 설정하면 실제 음식점 데이터를 사용할 수 있으며, 이후 UI/UX 개선과 추가 기능 구현을 통해 완전한 상용 앱으로 발전시킬 수 있습니다.

**GitHub 저장소**: https://github.com/hjkim909/Mechu  
**프로젝트 완성도**: 약 80% (기본 기능 완료, 고도화 단계)

---

**이 문서는 다른 개발자나 AI 어시스턴트에게 프로젝트를 인계할 때 사용할 수 있습니다.** 