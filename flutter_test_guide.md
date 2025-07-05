# 메뉴 추천 Flutter 앱 테스트 가이드

## 🚀 앱 실행 준비

### 1. 필요한 설정
```bash
# 1. Flutter 의존성 설치
flutter pub get

# 2. JSON 직렬화 코드 생성
flutter packages pub run build_runner build

# 3. 디바이스 확인
flutter devices
```

### 2. 앱 실행
```bash
# iOS 시뮬레이터에서 실행
flutter run

# 특정 디바이스에서 실행
flutter run -d [device-id]
```

## 📱 구현된 기능 테스트

### ✅ 현재 작동하는 기능

1. **홈 화면**
   - 현재 위치 표시 (강남역 하드코딩)
   - 인원수 슬라이더 (1-10명)
   - "지금 추천받기!" 버튼
   - 로딩 상태 표시

2. **추천 서비스**
   - 시간대별 자동 식사 종류 결정
   - 위치 기반 음식점 필터링
   - 거리순 정렬
   - 8개 샘플 음식점 데이터

3. **추천 결과 화면**
   - 음식점 카드 리스트
   - 순위 표시 (1-3위 하이라이트)
   - 평점, 가격대, 영업상태 표시
   - 빈 결과 처리

### 🔧 테스트 시나리오

1. **기본 추천 플로우**
   ```
   홈 화면 → 인원수 선택 → 추천받기 버튼 → 로딩 → 결과 화면
   ```

2. **다양한 인원수 테스트**
   - 1명, 5명, 10명으로 설정하여 추천 테스트

3. **시간대별 추천 테스트**
   - 오전 (아침): breakfast 추천
   - 오후 (점심): lunch 추천
   - 저녁: dinner 추천

## 📊 샘플 데이터

### 포함된 음식점 (8개)
1. 맛있는 한식당 (한식, 4.5점, 보통가격)
2. 이탈리아 파스타 (양식, 4.2점, 비쌈)
3. 일본 라멘집 (일식, 4.7점, 보통가격) - 영업종료
4. 중국집 맛집 (중식, 4.3점, 보통가격)
5. 프리미엄 스테이크 (양식, 4.8점, 매우비쌈)
6. 분식집 추억 (분식, 4.0점, 저렴)
7. 치킨 맛있는집 (치킨, 4.4점, 보통가격)
8. 카페 브런치 (카페, 4.1점, 보통가격) - 영업종료

## 🛠 개발자 모드 테스트

### 서비스별 개별 테스트
```dart
// lib/utils/service_test.dart 파일 생성
import '../services/services.dart';
import '../utils/sample_data.dart';

void testServices() async {
  // 위치 서비스 테스트
  final locationService = LocationService();
  final location = await locationService.getCurrentLocation();
  print('현재 위치: ${location.address}');

  // 추천 서비스 테스트
  final recommendationService = RecommendationService();
  final recommendations = await recommendationService.getQuickRecommendations(
    userLocation: location,
    numberOfPeople: 2,
  );
  print('추천 음식점 수: ${recommendations.length}');

  // 사용자 서비스 테스트
  final userService = UserService();
  await userService.initialize();
  print('현재 사용자: ${userService.currentUser?.name}');
}
```

## 🚨 알려진 제한사항

1. **GPS 미구현**: 현재 강남역으로 하드코딩
2. **실제 API 미연결**: 모든 데이터가 시뮬레이션
3. **JSON 코드 생성 필요**: build_runner 실행 필요
4. **상세 화면 미구현**: 음식점 클릭 시 스낵바만 표시

## 📋 다음 개발 단계

1. **위치 설정 화면** - GPS 또는 수동 위치 선택
2. **기본 설정 화면** - 사용자 선호도 설정
3. **음식점 상세 화면** - 메뉴, 리뷰, 연락처 등
4. **Provider 상태 관리** - 앱 전체 상태 관리
5. **실제 API 연동** - 네이버/카카오 지도 API

## 💡 Tips

- **네트워크 지연 시뮬레이션**: 각 서비스에 의도적인 지연 추가됨
- **에러 처리**: try-catch로 안전한 에러 처리 구현
- **Material Design 3**: 최신 디자인 시스템 적용
- **반응형 UI**: 다양한 화면 크기 대응

실제 디바이스나 시뮬레이터에서 테스트해보세요! 🎉 