# 메뉴 추천 앱 (Mechu) 개발 현황

## 🎯 프로젝트 개요
- **이름**: Mechu (메뉴 추천 Flutter 앱)
- **목표**: 위치 기반 메뉴 추천 시스템
- **완성도**: 80% (기본 기능 완료, 고도화 단계)
- **현재 상태**: 실기기 테스트 준비 단계

## ✅ 완료된 핵심 기능
### 1. 기본 앱 구조 (100% 완료)
- [x] 5개 핵심 화면: 홈, 스와이프 추천, 추천 결과, 위치 설정, 설정
- [x] Material Design 3 기반 UI/UX
- [x] 부드러운 애니메이션 및 인터랙션

### 2. 상태 관리 (100% 완료)  
- [x] Provider 패턴 기반 상태 관리
- [x] UserProvider, LocationProvider, RecommendationProvider, ThemeProvider
- [x] 설정 영구 저장 (SharedPreferences)

### 3. 위치 기반 서비스 (100% 완료)
- [x] GPS 실시간 위치 추적
- [x] 위치 권한 자동 관리
- [x] 좌표 → 지역명 변환

### 4. 메뉴 추천 시스템 (100% 완료)
- [x] 스와이프 방식 메뉴 추천 (확률 가중치 기반)
- [x] 추천 이력 관리 시스템 (최대 100개 저장)
- [x] 즐겨찾기 시스템

### 5. 외부 API 연동 (100% 완료)
- [x] 카카오/네이버 API 연동
- [x] 실제 음식점 데이터 검색
- [x] 지도 표시 및 마커 기능
- [x] API 실패 시 샘플 데이터 폴백

## 🎯 다음 단계 (우선순위 순)

### 1. 카카오 맵 API 테스트 (완료 ✅)
- [x] Android Studio SDK 문제 해결 완료
- [x] 카카오 맵 API 연동 상태 확인
- [x] API 키 설정 및 테스트 코드 작성
- [x] 실제 API 호출 테스트 수행
- [x] 전용 테스트 화면 구현 (`KakaoApiTestScreen`)
- [x] 홈 화면 및 설정 화면에 테스트 링크 추가

### 2. 실기기 테스트 (미룸)
- [ ] iPhone 실기기 연결 및 테스트
- [ ] Android 실기기 테스트
- [ ] 실제 GPS 위치 기반 테스트

### 2. 성능 최적화 & 버그 수정 (완료 ✅)
- [x] 메모리 사용량 최적화 - Provider 상태 관리 개선
- [x] API 응답 시간 개선 - HttpService 캐싱 구현  
- [x] 성능 모니터링 - 실시간 성능 확인 위젯 추가
- [x] 에러 핸들링 강화 - 전역 에러 처리 시스템 구현
- [x] 사용자 친화적 에러 메시지 - 재시도 메커니즘 포함

### 3. 네비게이션 개선 (완료 ✅)
- [x] 하단 네비게이션 바 구현 - 4개 주요 탭
- [x] 메인 스캐폴드 구조 설계 - IndexedStack 활용
- [x] 탭 전환 시 상태 유지 및 데이터 새로고침
- [x] 디버그 모드 전용 개발자 도구 접근

### 4. 고도화 기능 (현재 진행 중)
- [ ] 오프라인 모드 대응 - 네트워크 상태 감지 및 샘플 데이터 활용
- [ ] 사용자 리뷰 시스템
- [ ] 소셜 공유 기능
- [ ] 푸시 알림
- [ ] 개인화 추천 알고리즘

### 5. 배포 준비
- [ ] 앱 아이콘 최종 디자인
- [ ] 앱스토어 스크린샷 준비
- [ ] 개인정보처리방침 작성
- [ ] 앱스토어/플레이스토어 등록

## ⚠️ 중요 파일 관리 주의사항

### 🚫 절대 삭제하면 안 되는 파일들
```
*.iml                    # 모듈 설정 파일 (Android Studio 인식용)
.idea/                   # IDE 설정 파일
.metadata               # Flutter 프로젝트 메타데이터
pubspec.yaml           # Flutter 의존성 설정
pubspec.lock          # 버전 락 파일
```

### ✅ 안전하게 삭제 가능한 파일들
```
build/                 # 빌드 결과물 (자동 재생성)
.dart_tool/           # Dart 도구 캐시
*.backup              # 백업 파일
*.log                # 로그 파일
```

## 🛠 개발 환경 설정

### Flutter SDK 경로
```
/Users/hyunjoon/flutter
```

### 주요 명령어
```bash
# 의존성 설치
flutter pub get

# 앱 실행 (Android Studio 권장)
flutter run

# 빌드
flutter build apk        # Android
flutter build ios        # iOS
```

### API 키 설정 (필요시)
```dart
// lib/services/config_service.dart
setKakaoApiKey('실제_API_키');
```