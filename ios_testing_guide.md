# 📱 iPhone 실기기 테스트 가이드

## 개요
Android Studio에서 Flutter 앱을 실제 iPhone에 설치하여 테스트하는 방법을 안내합니다.

## 🔧 사전 준비사항

### 필수 도구
- [x] macOS 개발 환경
- [x] Xcode 설치 (`/Applications/Xcode.app/Contents/Developer`)
- [x] Android Studio
- [x] iPhone (iOS 14.0 이상 권장)
- [x] USB 케이블 (iPhone 연결용)

### Apple Developer 계정
#### 🆓 무료 계정 (개인 테스트용)
- Apple ID만 있으면 사용 가능
- 7일간 앱 유효 (이후 재설치 필요)
- 개인 기기에서만 테스트 가능

#### 💰 유료 계정 ($99/년)
- 1년간 무제한 테스트
- TestFlight 베타 테스트 가능
- 앱스토어 배포 가능

## 📱 iPhone 설정

### 1. 개발자 모드 활성화
1. **설정 > 개인정보 보호 및 보안 > 개발자 모드** 활성화
2. iPhone 재부팅 후 개발자 모드 확인

### 2. Mac과 연결
1. iPhone을 Mac에 USB로 연결
2. "이 컴퓨터를 신뢰하시겠습니까?" → **신뢰** 선택
3. iPhone에서 잠금해제 후 **신뢰** 재확인

## 🔨 Xcode 설정

### 1. Xcode 프로젝트 열기
```bash
# 프로젝트 루트에서 실행
open ios/Runner.xcworkspace
```

### 2. Bundle Identifier 변경
- 왼쪽 네비게이터: **Runner** 선택
- **Signing & Capabilities** 탭
- **Bundle Identifier** 를 고유한 값으로 변경
  ```
  예시: com.yourname.mechu
       com.example.mechu.yourname
  ```

### 3. Team 설정
- **Team** 드롭다운에서 Apple ID 선택
- 없다면 **Add Account...** 클릭하여 Apple ID 추가

### 4. 디바이스 선택
- Xcode 상단 툴바에서 시뮬레이터 대신 **실제 iPhone** 선택

## 🚀 앱 빌드 및 설치

### 방법 1: Android Studio 사용 (권장)
1. Android Studio에서 디바이스 드롭다운에서 **iPhone** 선택
2. **초록색 실행 버튼** 클릭
3. 첫 빌드는 5-10분 소요 (정상)

### 방법 2: Xcode 직접 사용
1. Xcode에서 **⌘ + R** 또는 **▶️ 버튼** 클릭
2. 빌드 및 설치 자동 진행

## 📲 iPhone에서 앱 신뢰 설정

앱 설치 후 필수 단계:

1. **설정 > 일반 > VPN 및 기기 관리**
2. **개발자 앱** 섹션에서 본인의 **Apple ID** 선택
3. **"[Apple ID] 신뢰"** 버튼 클릭
4. 확인 다이얼로그에서 **신뢰** 선택

## 🔄 개발 중 업데이트

### Hot Reload (빠른 업데이트)
- **⌘ + \\** : UI 변경사항 즉시 반영
- **⌘ + Shift + \\** : 앱 상태 초기화 후 재시작

### 전체 재빌드
1. Android Studio에서 **Stop** 버튼
2. 다시 **Run** 버튼 클릭

## 🚨 문제 해결

### 1. "Unable to install" 오류
```bash
# iOS 배포 타겟 확인
open ios/Podfile
# platform :ios, '11.0' 이상인지 확인
```

### 2. 코드 서명 오류
- Bundle Identifier를 더 고유한 값으로 변경
- Apple ID를 다시 추가해보기

### 3. 기기가 인식되지 않는 경우
```bash
# 연결된 기기 확인
xcrun devicectl list devices
```

### 4. 7일 후 앱 실행 안됨 (무료 계정)
- 정상적인 현상
- Xcode에서 다시 빌드하여 재설치

## ✅ 테스트 체크리스트

앱이 설치되면 다음 기능들을 실제 기기에서 테스트:

### 기본 기능
- [ ] 홈 화면 정상 로딩
- [ ] 앱 실행 속도 확인
- [ ] 메모리 사용량 체크

### 위치 기능
- [ ] GPS 위치 권한 요청
- [ ] 현재 위치 정보 표시
- [ ] 위치 기반 추천 동작

### 메뉴 추천
- [ ] 스와이프 추천 기능
- [ ] 메뉴 선택 및 음식점 검색
- [ ] 추천 결과 표시

### 데이터 관리
- [ ] 즐겨찾기 추가/제거
- [ ] 추천 이력 저장/불러오기
- [ ] 설정 저장 (앱 재시작 후 유지)

### UI/UX
- [ ] 터치 반응성
- [ ] 스크롤 부드러움
- [ ] 화면 전환 애니메이션
- [ ] 다크/라이트 테마 전환

### 네트워크
- [ ] API 호출 (카카오/네이버)
- [ ] 인터넷 연결 끊김 시 동작
- [ ] 로딩 상태 표시

## 📝 개발 팁

### 효율적인 테스트 방법
1. **주요 기능 우선**: 핵심 기능부터 테스트
2. **다양한 시나리오**: 정상/비정상 케이스 모두 확인
3. **성능 모니터링**: Xcode Instruments 활용
4. **배터리 영향**: 위치 서비스 사용량 확인

### 로그 확인
```bash
# iPhone 로그 실시간 확인
xcrun devicectl list devices
xcrun devicectl log stream --device [DEVICE_ID]
```

## 🔄 정기 재설치 (무료 계정)

### 매주 필요한 작업
1. iPhone에서 기존 앱 삭제
2. Xcode에서 다시 빌드
3. 새로 설치된 앱 신뢰 설정

### 자동화 스크립트 (선택사항)
```bash
#!/bin/bash
# rebuild_ios.sh
cd /Users/hyunjoon/StudioProjects/Mechu
open ios/Runner.xcworkspace
echo "Xcode에서 ⌘+R을 눌러 다시 빌드하세요."
```

---

**💡 참고**: 실제 기기 테스트는 시뮬레이터와 다른 성능과 동작을 보여주므로, 최종 배포 전 필수적으로 진행해야 합니다.

**🚀 다음 단계**: [Flutter 앱스토어 배포 가이드](flutter_deployment_guide.md)
