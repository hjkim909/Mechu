import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/page_transitions.dart';
import 'recommendation_result_screen.dart';

class SwipeRecommendationScreen extends StatefulWidget {
  final int numberOfPeople;

  const SwipeRecommendationScreen({
    super.key,
    required this.numberOfPeople,
  });

  @override
  State<SwipeRecommendationScreen> createState() => _SwipeRecommendationScreenState();
}

class _SwipeRecommendationScreenState extends State<SwipeRecommendationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardScaleAnimation;
  
  int _currentIndex = 0;
  bool _isLoading = false;
  List<MenuCategory> _recommendedMenus = [];

  // 메뉴 카테고리와 확률 가중치
  final Map<MenuCategory, double> _menuWeights = {
    MenuCategory(
      name: '김치찌개',
      icon: '🥘',
      description: '매콤하고 시원한 김치찌개',
      color: Colors.red.shade700,
    ): 0.20, // 20% 확률 (가장 높음)
    
    MenuCategory(
      name: '삼겹살',
      icon: '🥓',
      description: '직화구이 삼겹살',
      color: Colors.pink.shade600,
    ): 0.15, // 15% 확률
    
    MenuCategory(
      name: '치킨',
      icon: '🍗',
      description: '바삭한 치킨',
      color: Colors.orange.shade600,
    ): 0.15, // 15% 확률
    
    MenuCategory(
      name: '국밥',
      icon: '🍲',
      description: '따뜻한 국밥',
      color: Colors.brown.shade600,
    ): 0.12, // 12% 확률
    
    MenuCategory(
      name: '짜장면',
      icon: '🍜',
      description: '진한 춘장소스의 짜장면',
      color: Colors.brown.shade500,
    ): 0.10, // 10% 확률
    
    MenuCategory(
      name: '피자',
      icon: '🍕',
      description: '치즈 가득한 피자',
      color: Colors.yellow.shade700,
    ): 0.08, // 8% 확률
    
    MenuCategory(
      name: '라멘',
      icon: '🍲',
      description: '진한 돈코츠 라멘',
      color: Colors.amber.shade700,
    ): 0.07, // 7% 확률
    
    MenuCategory(
      name: '파스타',
      icon: '🍝',
      description: '크림/토마토 파스타',
      color: Colors.green.shade600,
    ): 0.05, // 5% 확률
    
    MenuCategory(
      name: '초밥',
      icon: '🍣',
      description: '신선한 회와 초밥',
      color: Colors.teal.shade600,
    ): 0.04, // 4% 확률
    
    MenuCategory(
      name: '햄버거',
      icon: '🍔',
      description: '수제 패티 햄버거',
      color: Colors.red.shade800,
    ): 0.04, // 4% 확률
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
    _generateRecommendedMenus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  /// 확률 기반 메뉴 추천 생성
  void _generateRecommendedMenus() {
    final random = Random();
    final List<MenuCategory> shuffledMenus = [];

    // 확률 가중치에 따라 메뉴 순서 결정
    final menuList = _menuWeights.keys.toList();
    
    // 첫 번째 메뉴: 가중치 기반 선택
    final firstMenu = _selectMenuByWeight(random);
    shuffledMenus.add(firstMenu);
    
    // 나머지 메뉴들: 첫 번째 메뉴 제외하고 섞기
    final remainingMenus = menuList.where((menu) => menu != firstMenu).toList();
    remainingMenus.shuffle(random);
    shuffledMenus.addAll(remainingMenus);

    setState(() {
      _recommendedMenus = shuffledMenus;
    });
  }

  /// 가중치 기반 메뉴 선택
  MenuCategory _selectMenuByWeight(Random random) {
    double totalWeight = _menuWeights.values.reduce((a, b) => a + b);
    double randomValue = random.nextDouble() * totalWeight;
    
    double currentWeight = 0.0;
    for (var entry in _menuWeights.entries) {
      currentWeight += entry.value;
      if (randomValue <= currentWeight) {
        return entry.key;
      }
    }
    
    // 폴백: 첫 번째 메뉴 반환
    return _menuWeights.keys.first;
  }

  /// 메뉴 선택 시 음식점 추천
  Future<void> _selectMenu(MenuCategory menu) async {
    // 햅틱 피드백
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final recommendationProvider = context.read<RecommendationProvider>();
      final locationProvider = context.read<LocationProvider>();
      final historyProvider = context.read<RecommendationHistoryProvider>();

      await recommendationProvider.getRecommendationsByCategory(
        location: locationProvider.currentLocation,
        category: menu.name,
      );

      if (mounted && recommendationProvider.hasRecommendations) {
        // 추천 이력 자동 저장
        final history = historyProvider.createHistoryFromRecommendation(
          location: locationProvider.currentLocation,
          selectedCategory: menu.name,
          numberOfPeople: widget.numberOfPeople,
          restaurants: recommendationProvider.recommendations,
          source: RecommendationSource.swipe,
        );
        
        // 이력 저장 (비동기로 실행, 실패해도 추천 결과는 보여줌)
        historyProvider.addHistory(history).catchError((error) {
          print('추천 이력 저장 실패: $error');
        });

        // 현재 위치를 UserLocation으로 변환
        final locationService = LocationService();
        final userLocation = await locationService.getLocationFromAddress(locationProvider.currentLocation) 
            ?? const UserLocation(latitude: 37.4979517, longitude: 127.0276188, address: '강남역');
        
        Navigator.of(context).push(
          PageTransitions.heroCard(
            RecommendationResultScreen(
              restaurants: recommendationProvider.recommendations,
              numberOfPeople: widget.numberOfPeople,
              userLocation: userLocation,
              selectedCategory: menu.name,
            ),
            heroTag: 'swipeToResult',
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('${menu.name} 음식점을 찾을 수 없습니다'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('음식점 검색 중 오류가 발생했습니다'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 새로운 추천 생성
  void _generateNewRecommendations() {
    HapticFeedback.lightImpact();
    _generateRecommendedMenus();
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return Column(
              children: [
                Text(
                  '${locationProvider.currentLocation} 추천',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.numberOfPeople}명을 위한',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateNewRecommendations,
            tooltip: '새로운 추천',
          ),
        ],
      ),
      body: _recommendedMenus.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 진행 표시기
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        '${_currentIndex + 1} / ${_recommendedMenus.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _recommendedMenus.length,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),

                // 스와이프 안내
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '좌우로 밀어서 다른 메뉴 보기',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // 메뉴 카드
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      HapticFeedback.selectionClick();
                    },
                    itemCount: _recommendedMenus.length,
                    itemBuilder: (context, index) {
                      final menu = _recommendedMenus[index];
                      final isFirst = index == 0;
                      
                      return Container(
                        margin: const EdgeInsets.all(20),
                        child: _buildMenuCard(menu, isFirst),
                      );
                    },
                  ),
                ),

                // 하단 버튼
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // 이전 버튼
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentIndex > 0
                              ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('이전'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // 선택 버튼
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading 
                              ? null 
                              : () => _selectMenu(_recommendedMenus[_currentIndex]),
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.restaurant_menu),
                          label: Text(_isLoading ? '검색 중...' : '이 메뉴로 선택'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // 다음 버튼
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentIndex < _recommendedMenus.length - 1
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('다음'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuCard(MenuCategory menu, bool isRecommended) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Hero(
      tag: 'menu-${menu.name}',
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                menu.color.withOpacity(0.1),
                menu.color.withOpacity(0.05),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 추천 배지
                if (isRecommended) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '오늘의 추천!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // 메뉴 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: menu.color.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: menu.color.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      menu.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 메뉴 이름
                Text(
                  menu.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: menu.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 메뉴 설명
                Text(
                  menu.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // 확률 표시 (첫 번째 메뉴만)
                if (isRecommended) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(_menuWeights[menu]! * 100).round()}% 확률로 추천됨',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 메뉴 카테고리 데이터 클래스
class MenuCategory {
  final String name;
  final String icon;
  final String description;
  final Color color;

  MenuCategory({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuCategory &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
} 