# Flutter 개발 에러 방지 체크리스트

## 🚨 새로운 화면(Screen) 개발 시 필수 체크리스트

### 1. Import 문 체크리스트 ✅

**필수 Import 순서:**
```dart
// 1. Flutter 패키지
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. 프로젝트 내부 모듈 (알파벳 순서)
import '../models/models.dart';          // ← 데이터 모델 (UserLocation, Restaurant 등)
import '../providers/providers.dart';    // ← 상태 관리
import '../services/services.dart';      // ← 비즈니스 로직
import 'other_screen.dart';             // ← 다른 화면들
```

### 2. 자주 누락되는 Import들 🔍

| 클래스/기능 | Import 위치 | 누락 시 에러 |
|-------------|-------------|--------------|
| `UserLocation` | `../models/models.dart` | `Couldn't find constructor 'UserLocation'` |
| `Restaurant` | `../models/models.dart` | `Couldn't find constructor 'Restaurant'` |
| `User` | `../models/models.dart` | `The getter 'User' isn't defined` |
| `UserProvider` | `../providers/providers.dart` | `The method 'read' isn't defined for the class` |
| `LocationService` | `../services/services.dart` | `Couldn't find constructor 'LocationService'` |
| `Provider/Consumer` | `package:provider/provider.dart` | `Consumer/context.read not found` |

### 3. Provider 패턴 사용 시 체크리스트 🔄

**반드시 포함할 것:**
- [ ] `import 'package:provider/provider.dart';`
- [ ] `import '../providers/providers.dart';`
- [ ] `Consumer<SomeProvider>` 또는 `context.read<SomeProvider>()`
- [ ] Provider 상태에 따른 로딩/에러 처리

**예시 코드:**
```dart
// ✅ 올바른 사용법
Consumer<RecommendationProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    return SomeWidget();
  },
)

// ❌ 잘못된 사용법 (import 누락)
Consumer<RecommendationProvider>( // Provider import 없으면 에러
  // ...
)
```

### 4. 화면 간 네비게이션 체크리스트 🔀

**필수 확인사항:**
- [ ] 이동할 화면 import 완료
- [ ] 필요한 매개변수 모두 전달
- [ ] nullable 매개변수 null 체크

**예시:**
```dart
// ✅ 올바른 네비게이션
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => RecommendationResultScreen(
      restaurants: provider.recommendations,
      numberOfPeople: widget.numberOfPeople,
      userLocation: userLocation,        // ← null이 아닌 실제 객체 전달
      selectedCategory: _selectedCategory,
    ),
  ),
);

// ❌ 잘못된 네비게이션
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => RecommendationResultScreen(
      userLocation: null,  // ← nullable이 아닌 필드에 null 전달 시 에러
    ),
  ),
);
```

## 🛠️ 일반적인 에러 해결법

### 에러 유형별 해결책

| 에러 메시지 | 원인 | 해결책 |
|-------------|------|--------|
| `Couldn't find constructor 'ClassName'` | 클래스 import 누락 | `../models/models.dart` 추가 |
| `The method 'read' isn't defined` | Provider import 누락 | `package:provider/provider.dart` 추가 |
| `Consumer/context.read not found` | Provider 패키지 누락 | `provider: ^6.1.1` 의존성 및 import 확인 |
| `The value 'null' can't be assigned` | nullable이 아닌 필드에 null 전달 | 실제 객체 생성하여 전달 |
| `Too many positional arguments` | 메서드 시그니처 불일치 | 실제 메서드 정의 확인 후 수정 |

### 디버깅 단계별 접근법

1. **에러 메시지 정확히 읽기** 📖
   - 어떤 클래스/메서드를 찾을 수 없는지 확인
   - 파일 경로와 라인 번호 확인

2. **Import 문 점검** 🔍
   - 필요한 모든 클래스가 import되었는지 확인
   - import 경로가 올바른지 확인

3. **실제 클래스/메서드 정의 확인** 📋
   - 해당 클래스가 실제로 존재하는지 확인
   - 메서드 시그니처가 올바른지 확인

4. **Provider 상태 확인** 🔄
   - Provider가 올바르게 주입되었는지 확인
   - Consumer 사용법이 올바른지 확인

## 📝 새 화면 개발 템플릿

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '화면 제목',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<SomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(
              child: Text('에러: ${provider.error}'),
            );
          }
          
          return YourActualContent();
        },
      ),
    );
  }
}
```

## 🎯 핵심 포인트

1. **Import는 개발의 기본** - 새 파일 만들 때 첫 번째로 확인
2. **Provider 패턴 일관성** - 모든 화면에서 동일한 패턴 사용
3. **에러 메시지를 친구로** - 에러 메시지가 정확한 해결책을 알려줌
4. **템플릿 활용** - 위 템플릿을 기반으로 새 화면 개발

---
*마지막 업데이트: 2024년 12월*
*작성자: Mechu Development Team* 