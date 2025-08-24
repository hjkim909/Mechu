import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/page_transitions.dart';
import 'home_screen.dart';
import 'recommendation_history_screen.dart';
import 'settings_screen.dart';
import 'kakao_api_test_screen.dart';

/// 메인 내비게이션 화면 - 하단 탭 바를 포함한 메인 스캐폴드
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  MainNavigationScreenState createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  /// 외부에서 탭 전환을 위한 public 메서드
  void switchToTab(int index) {
    if (index >= 0 && index < _rootScreens.length && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _refreshDataIfNeeded(index);
      _provideFeedback();
    }
  }

  // 각 탭별 Navigator Key
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // 홈
    GlobalKey<NavigatorState>(), // 이력
    GlobalKey<NavigatorState>(), // 즐겨찾기
    GlobalKey<NavigatorState>(), // 설정
  ];

  // 각 탭의 루트 화면들
  late final List<Widget> _rootScreens;
  
  @override
  void initState() {
    super.initState();
    _rootScreens = [
      const HomeScreen(showAppBar: false), // 홈 화면 (앱바 숨김)
      const RecommendationHistoryScreen(showAppBar: false), // 추천 이력
      const FavoriteScreen(), // 즐겨찾기 화면
      const SettingsScreen(showAppBar: false), // 설정 화면 (앱바 숨김)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        // 현재 탭의 Navigator에서 뒤로 가기 처리
        final currentNavigator = _navigatorKeys[_currentIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
          return false; // 앱 종료 방지
        }
        return true; // 앱 종료 허용
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _buildTabNavigators(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colorScheme.surface,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            iconSize: 24,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: '홈',
                tooltip: '메뉴 추천 홈',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: '이력',
                tooltip: '추천 이력',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline),
                activeIcon: const Icon(Icons.favorite),
                label: '즐겨찾기',
                tooltip: '즐겨찾기 음식점',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: '설정',
                tooltip: '앱 설정',
              ),
            ],
          ),
        ),
        // 디버그 모드에서만 표시되는 플로팅 액션 버튼
        floatingActionButton: kDebugMode ? _buildDebugFAB(context) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      ),
    );
  }

  // 각 탭별 Navigator 빌드
  List<Widget> _buildTabNavigators() {
    return List.generate(_rootScreens.length, (index) {
      return Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => _rootScreens[index],
            settings: routeSettings,
          );
        },
      );
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      // 같은 탭을 다시 누르면 해당 탭의 루트로 이동
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
      
      // 필요한 경우 데이터 새로고침
      _refreshDataIfNeeded(index);
    }
    
    // 탭 변경 시 햅틱 피드백
    _provideFeedback();
  }

  void _provideFeedback() {
    // 부드러운 햅틱 피드백
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS용 햅틱
    } else {
      // Android용 햅틱
    }
  }

  void _refreshDataIfNeeded(int index) {
    switch (index) {
      case 1: // 추천 이력
        context.read<RecommendationHistoryProvider>().refreshHistory();
        break;
      case 2: // 즐겨찾기
        context.read<FavoriteProvider>().refreshFavorites();
        break;
      case 3: // 설정
        // 설정 화면은 별도 새로고침 불필요
        break;
    }
  }

  // 디버그 모드 전용 플로팅 액션 버튼
  Widget _buildDebugFAB(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: "debug_tools",
      backgroundColor: Colors.black54,
      onPressed: () {
        _showDebugMenu(context);
      },
      child: const Icon(
        Icons.developer_mode,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  void _showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('카카오 API 테스트'),
              onTap: () {
                Navigator.pop(context);
                // 현재 탭의 Navigator를 사용하여 이동
                _navigatorKeys[_currentIndex].currentState?.push(
                  PageTransitions.slideFromRight(const KakaoApiTestScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('앱 정보'),
              subtitle: const Text('디버그 모드 실행 중'),
              onTap: () {
                Navigator.pop(context);
                _showAppInfo(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('메뉴 추천 앱 (Mechu)'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            Text('빌드: Debug'),
            Text('모드: 개발자 모드'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 즐겨찾기 화면 (임시 구현)
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteProvider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '즐겨찾기한 음식점이 없습니다',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '마음에 드는 음식점을 즐겨찾기에 추가해보세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteProvider.favorites.length,
            itemBuilder: (context, index) {
              final favorite = favoriteProvider.favorites[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.restaurant,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(favorite.restaurant.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(favorite.restaurant.category),
                      Text('평점: ${favorite.restaurant.rating} ⭐'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      favoriteProvider.removeFavorite(favorite.restaurant.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
